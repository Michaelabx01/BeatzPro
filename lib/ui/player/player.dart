import 'dart:io';
import 'dart:ui';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newton_particles/newton_particles.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../widgets/buttonplay_animation.dart';
import '../widgets/custom_lyricui.dart';
import '../widgets/loader.dart';
import '../../utils/helper.dart';
import '../widgets/up_next_queue.dart';
import '/ui/player/player_controller.dart';
import '../screens/Settings/settings_screen_controller.dart';
import '/ui/utils/theme_controller.dart';
import '/ui/widgets/marqwee_widget.dart';
import '/ui/widgets/songinfo_bottom_sheet.dart';
import '../widgets/image_widget.dart';
import '../widgets/sliding_up_panel.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20), // Customize the duration as needed
      vsync: this,
    )..repeat(); // This will repeat the animation infinitely
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final ThemeController themeController = Get.find<ThemeController>();
    double playerArtImageSize = size.width - ((size.height < 750) ? 90 : 60);
    playerArtImageSize = playerArtImageSize > 350 ? 350 : playerArtImageSize;

    return Scaffold(
      body: SlidingUpPanel(
        minHeight: 65 + Get.mediaQuery.padding.bottom,
        maxHeight: size.height,
        isDraggable: !GetPlatform.isDesktop,
        collapsed: InkWell(
          onTap: () {
            if (GetPlatform.isDesktop) {
              playerController.homeScaffoldkey.currentState!.openEndDrawer();
            }
          },
          child: Container(
            color: Theme.of(context).bottomSheetTheme.modalBarrierColor,
            child: Column(
              children: [
                SizedBox(
                  height: 65,
                  child: Center(
                    child: Icon(
                      color: Theme.of(context).textTheme.titleMedium!.color,
                      Icons.keyboard_arrow_up_rounded,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
          playerController.scrollController = sc;
          return Stack(
            children: [
              UpNextQueue(
                onReorderEnd: onReorderEnd,
                onReorderStart: onReorderStart,
              ),
              Positioned(
                bottom: 60,
                right: 15,
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: FittedBox(
                    child: FloatingActionButton(
                      focusElevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      elevation: 0,
                      onPressed: playerController.shuffleQueue,
                      child: const Icon(Icons.shuffle),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        body: Stack(
          children: [
            Obx(
              () => SizedBox.expand(
                child: playerController.currentSong.value != null
                    ? CachedNetworkImage(
                        errorWidget: (context, url, error) {
                          final imgFile = File(
                            "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${playerController.currentSong.value!.id}.png");
                          if (imgFile.existsSync()) {
                            themeController.setTheme(FileImage(imgFile));
                            return Image.file(imgFile, cacheHeight: 200);
                          }
                          return const SizedBox.shrink();
                        },
                        memCacheHeight: 200,
                        imageBuilder: (context, imageProvider) {
                          Get.find<SettingsScreenController>().themeModetype.value ==
                                  ThemeType.dynamic
                              ? themeController.setTheme(imageProvider)
                              : null;
                          return Image(
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                          );
                        },
                        imageUrl: playerController.currentSong.value!.artUri.toString(),
                        cacheKey: "${playerController.currentSong.value!.id}_song",
                      )
                    : Container(),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.90),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                children: [
                  Obx(
                    () => playerController.showLyricsflag.value
                        ? SizedBox(
                            height: size.height < 750 ? 30 : 70,
                          )
                        : SizedBox(
                            height: size.height < 750 ? 80 : 120,
                          ),
                  ),
                  Obx(
                    () => playerController.showLyricsflag.value
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ToggleSwitch(
                              minWidth: 90.0,
                              cornerRadius: 20.0,
                              activeBgColors: [
                                [Theme.of(context).primaryColor.withLightness(0.4)],
                                [Theme.of(context).primaryColor.withLightness(0.4)],
                              ],
                              activeFgColor: Colors.white,
                              inactiveBgColor: Theme.of(context).colorScheme.secondary,
                              inactiveFgColor: Colors.white,
                              initialLabelIndex: playerController.lyricsMode.value,
                              totalSwitches: 2,
                              labels: ['synced'.tr, 'plain'.tr],
                              radiusStyle: true,
                              onToggle: playerController.changeLyricsMode,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                    () => playerController.currentSong.value != null
                        ? Stack(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Stack(
                                  key: ValueKey(playerController.currentSong.value),
                                  children: [
                                    Obx(() => Opacity(
                                          opacity: playerController.showLyricsflag.isTrue
                                              ? 0.0
                                              : 1.0,
                                          child: RippleAnimation(
                                            color: Theme.of(context).primaryColor.withLightness(0.4),
                                            minRadius: playerArtImageSize / 2 + 10,
                                            repeat: true,
                                            ripplesCount: 6,
                                            child: AnimatedBuilder(
                                              animation: _controller!,
                                              builder: (context, child) {
                                                return Transform.rotate(
                                                  angle: _controller!.value * 2 * 3.1416,
                                                  child: child,
                                                );
                                              },
                                              child: InkWell(
                                                key: ValueKey(playerController.currentSong.value),
                                                onLongPress: () {
                                                  showModalBottomSheet(
                                                    constraints: const BoxConstraints(maxWidth: 500),
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.vertical(
                                                        top: Radius.circular(10.0),
                                                      ),
                                                    ),
                                                    isScrollControlled: true,
                                                    context: playerController.homeScaffoldkey.currentState!.context,
                                                    barrierColor: Colors.transparent.withAlpha(100),
                                                    builder: (context) => SongInfoBottomSheet(
                                                      playerController.currentSong.value!,
                                                      calledFromPlayer: true,
                                                    ),
                                                  ).whenComplete(() => Get.delete<SongInfoController>());
                                                },
                                                onTap: () {
                                                  playerController.showLyrics();
                                                },
                                                child: Container(
                                                  height: playerArtImageSize,
                                                  width: playerArtImageSize,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ImageWidget(
                                                    size: playerArtImageSize,
                                                    song: playerController.currentSong.value!,
                                                    isPlayerArtImage: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                    Obx(
                                      () => playerController.showLyricsflag.isTrue
                                          ? Stack(
                                              children: [
                                                Positioned.fill(
                                                  child:
                                                   Newton(
                                                    activeEffects: [
                                                      RainEffect(
                                                        particleConfiguration: ParticleConfiguration(
                                                          shape: CircleShape(),
                                                          size: const Size(5, 5),
                                                          color: const SingleParticleColor(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        effectConfiguration: const EffectConfiguration(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    playerController.showLyrics();
                                                  },
                                                  child: Container(
                                                    height: playerArtImageSize * 1.2,
                                                    width: playerArtImageSize * 1.2,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Obx(
                                                          () => playerController.isLyricsLoading.isTrue
                                                              ? const Center(child: LoadingIndicator())
                                                              : playerController.lyricsMode.toInt() == 1
                                                                  ? Center(
                                                                      child: SingleChildScrollView(
                                                                        physics: const BouncingScrollPhysics(),
                                                                        padding: EdgeInsets.symmetric(
                                                                          horizontal: 0,
                                                                          vertical: playerArtImageSize / 3.5,
                                                                        ),
                                                                        child: Obx(
                                                                          () => Text(
                                                                            playerController.lyrics["plainLyrics"] == "NA"
                                                                                ? "lyricsNotAvailable".tr
                                                                                : playerController.lyrics["plainLyrics"],
                                                                            textAlign: TextAlign.center,
                                                                            style: Theme.of(context)
                                                                                .textTheme
                                                                                .titleMedium!
                                                                                .copyWith(
                                                                                  fontSize: 20,
                                                                                  color: Theme.of(context)
                                                                                      .primaryColor
                                                                                      .withLightness(0.4),
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : IgnorePointer(
                                                                      child: LyricsReader(
                                                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                                                        lyricUi: CustomLyricUI(
                                                                          primaryColor: Theme.of(context)
                                                                              .primaryColor
                                                                              .withLightness(0.2),
                                                                          highlightColor: Theme.of(context)
                                                                              .primaryColor
                                                                              .withLightness(0.4),
                                                                          fontSize: 25,
                                                                          highlightFontSize: 28,
                                                                        ),
                                                                        position: playerController
                                                                            .progressBarStatus
                                                                            .value
                                                                            .current
                                                                            .inMilliseconds,
                                                                        model: LyricsModelBuilder.create()
                                                                            .bindLyricToMain(playerController.lyrics['synced'].toString())
                                                                            .getModel(),
                                                                        emptyBuilder: () => Center(
                                                                          child: Text(
                                                                            "syncedLyricsNotAvailable".tr,
                                                                            style: Theme.of(context)
                                                                                .textTheme
                                                                                .titleMedium!
                                                                                .copyWith(
                                                                                  fontSize: 20,
                                                                                  color: Theme.of(context).primaryColor.withLightness(0.4),
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                        ),
                                                        IgnorePointer(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(15),
                                                              gradient: LinearGradient(
                                                                begin: Alignment.topCenter,
                                                                end: Alignment.bottomCenter,
                                                                colors: [
                                                                  Theme.of(context)
                                                                      .primaryColor
                                                                      .withOpacity(0.90),
                                                                  Colors.transparent,
                                                                  Colors.transparent,
                                                                  Colors.transparent,
                                                                  Theme.of(context)
                                                                      .primaryColor
                                                                      .withOpacity(0.90),
                                                                ],
                                                                stops: const [0, 0.2, 0.5, 0.8, 1],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Expanded(child: Container()),
                  Obx(() {
                    return MarqueeWidget(
                      child: Text(
                        playerController.currentSong.value != null
                            ? playerController.currentSong.value!.title
                            : "NA",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  GetX<PlayerController>(builder: (controller) {
                    return MarqueeWidget(
                      child: Text(
                        playerController.currentSong.value != null
                            ? controller.currentSong.value!.artist!
                            : "NA",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  GetX<PlayerController>(builder: (controller) {
                    return ProgressBar(
                      baseBarColor: Theme.of(context).sliderTheme.inactiveTrackColor,
                      bufferedBarColor: Theme.of(context).sliderTheme.valueIndicatorColor,
                      progressBarColor: Theme.of(context).sliderTheme.activeTrackColor,
                      thumbColor: Theme.of(context).sliderTheme.thumbColor,
                      timeLabelTextStyle: Theme.of(context).textTheme.titleMedium,
                      progress: controller.progressBarStatus.value.current,
                      total: controller.progressBarStatus.value.total,
                      buffered: controller.progressBarStatus.value.buffered,
                      onSeek: controller.seek,
                    );
                  }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: playerController.toggleFavourite,
                        icon: Obx(() => Icon(
                              playerController.isCurrentSongFav.isFalse
                                  ? Icons.favorite_border_rounded
                                  : Icons.favorite_rounded,
                              color: Theme.of(context).textTheme.titleMedium!.color,
                            )),
                      ),
                      _previousButton(playerController, context),
                      CircleAvatar(radius: 35, child: _playButton()),
                      _nextButton(playerController, context),
                      Obx(() {
                        return IconButton(
                          onPressed: playerController.toggleLoopMode,
                          icon: Icon(
                            Icons.all_inclusive,
                            color: playerController.isLoopModeEnabled.value
                                ? Theme.of(context).textTheme.titleLarge!.color
                                : Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.2),
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(
                    height: 90 + Get.mediaQuery.padding.bottom,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playButton() {
  return GetX<PlayerController>(builder: (controller) {
    final buttonState = controller.buttonState.value;
    bool isPlaying = buttonState == PlayButtonState.playing;

    return PlayButton(
      isPlaying: isPlaying,
      playIcon: const Icon(Icons.play_arrow, color: Colors.black, size: 40),
      pauseIcon: const Icon(Icons.pause, color: Colors.black, size: 40),
      onPressed: () {
        if (buttonState == PlayButtonState.paused) {
          controller.play(); // Cambiar a estado de reproducción
        } else if (buttonState == PlayButtonState.playing) {
          controller.pause(); // Cambiar a estado de pausa
        }
      },
    );
  });
}

  Widget _previousButton(PlayerController playerController, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.skip_previous_rounded,
        color: Theme.of(context).textTheme.titleMedium!.color,
      ),
      iconSize: 30,
      onPressed: playerController.prev,
    );
  }

  Widget _nextButton(PlayerController playerController, BuildContext context) {
    return Obx(() {
      final isLastSong = playerController.currentQueue.isEmpty ||
          (playerController.currentQueue.last.id == playerController.currentSong.value?.id);
      return IconButton(
        icon: Icon(
          Icons.skip_next_rounded,
          color: Theme.of(context).textTheme.titleMedium!.color,
        ),
        iconSize: 30,
        onPressed: isLastSong ? null : playerController.next,
      );
    });
  }
}