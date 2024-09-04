import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase import
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'firebase_options.dart'; // Importar las opciones generadas de Firebase
import '/utils/get_localization.dart';
import '/services/downloader.dart';
import '/services/piped_service.dart';
import 'ui/screens/firebase/screen/login_screen.dart';
import 'utils/app_link_controller.dart';
import '/services/audio_handler.dart';
import '/services/music_service.dart';
import '/ui/home.dart'; // Pantalla principal (Home)
import '/ui/player/player_controller.dart';
import 'ui/screens/Settings/settings_screen_controller.dart';
import '/ui/utils/theme_controller.dart';
import 'ui/screens/Home/home_screen_controller.dart';
import 'ui/screens/Library/library_controller.dart';
import 'utils/house_keeping.dart';
import 'utils/system_tray.dart';
import 'utils/update_check_flag_file.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Hive y otras configuraciones
  await initHive();
  _setAppInitPrefs();
  startApplicationServices();
  startHouseKeeping();

  // Inicializar AudioHandler
  Get.put<AudioHandler>(await initAudioService(), permanent: true);

  // Configuración del sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Ejecutar la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!GetPlatform.isDesktop) Get.put(AppLinksController());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.resumed") {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else if (msg == "AppLifecycleState.detached") {
        await Get.find<AudioHandler>().customAction("saveSession");
      }
      return null;
    });
    return GetX<ThemeController>(builder: (controller) {
      return GetMaterialApp(
          title: 'BeatzPro',
          theme: controller.themedata.value,
          home: AuthenticationWrapper(), // Cambiado para redirigir al login o home
          debugShowCheckedModeBanner: false,
          translations: Languages(),
          locale: Locale(
              Hive.box("AppPrefs").get('currentAppLanguageCode') ?? "en"),
          fallbackLocale: const Locale("en"),
          builder: (context, child) {
            final scale = MediaQuery.of(context)
                .textScaler
                .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: scale),
              child: child!,
            );
          });
    });
  }
}

// Clase para manejar la redirección basada en el estado de autenticación
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Mostramos un indicador de carga mientras verificamos
        }
        if (snapshot.hasData) {
          return Home(); // Usuario autenticado, ir a Home
        }
        return LoginScreen(); // Usuario no autenticado, ir a Login 
      },
    );
  }
}

Future<void> startApplicationServices() async {
  Get.lazyPut(() => PipedServices(), fenix: true);
  Get.lazyPut(() => MusicServices(true), fenix: true);
  Get.lazyPut(() => ThemeController(), fenix: true);
  Get.lazyPut(() => PlayerController(), fenix: true);
  Get.lazyPut(() => HomeScreenController(), fenix: true);
  Get.lazyPut(() => LibrarySongsController(), fenix: true);
  Get.lazyPut(() => LibraryPlaylistsController(), fenix: true);
  Get.lazyPut(() => LibraryAlbumsController(), fenix: true);
  Get.lazyPut(() => LibraryArtistsController(), fenix: true);
  Get.lazyPut(() => SettingsScreenController(), fenix: true);
  Get.lazyPut(() => Downloader(), fenix: true);
  if (GetPlatform.isDesktop) {
    Get.put(DesktopSystemTray());
  }
}

initHive() async {
  String applicationDataDirectoryPath;
  if (GetPlatform.isDesktop) {
    applicationDataDirectoryPath =
        "${(await getApplicationSupportDirectory()).path}/db";
  } else {
    applicationDataDirectoryPath =
        (await getApplicationDocumentsDirectory()).path;
  }
  await Hive.initFlutter(applicationDataDirectoryPath);
  await Hive.openBox("SongsCache");
  await Hive.openBox("SongDownloads");
  await Hive.openBox('SongsUrlCache');
  await Hive.openBox("AppPrefs");
}

void _setAppInitPrefs() {
  final appPrefs = Hive.box("AppPrefs");
  if (appPrefs.isEmpty) {
    appPrefs.putAll({
      'themeModeType': 0,
      "cacheSongs": false,
      "skipSilenceEnabled": false,
      'streamingQuality': 1,
      'themePrimaryColor': 4278199603,
      'discoverContentType': "QP",
      'newVersionVisibility': updateCheckFlag,
      "cacheHomeScreenData": true
    });
  }
}
