  import 'package:BeatzPro/ui/utils/theme_controller.dart';
  import 'package:carousel_animations/carousel_animations.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '/models/quick_picks.dart';
  import '../player/player_controller.dart';
  import 'image_widget.dart';
  import 'songinfo_bottom_sheet.dart';

class QuickPicksWidget extends StatefulWidget {
  const QuickPicksWidget({super.key, required this.content, required ScrollController scrollController});
  final QuickPicks content;

  @override
  _QuickPicksWidgetState createState() => _QuickPicksWidgetState();
}

class _QuickPicksWidgetState extends State<QuickPicksWidget> {
  final PlayerController playerController = Get.find<PlayerController>();
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;
  String _username = 'Usuario'; // Nombre por defecto del usuario

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Cargar el nombre de usuario guardado cuando se inicie el widget
  }

  // Cargar el nombre de usuario desde SharedPreferences
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Usuario'; // Si no existe, usar 'Usuario'
      _usernameController.text = _username;
    });
  }

  // Guardar el nombre de usuario en SharedPreferences
  Future<void> _saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 20.0),
      height: 400,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.content.title.toLowerCase().removeAllWhitespace.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onLongPress: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .primaryColor
                        .withLightness(0.3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withLightness(0.2),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(8),
                  child: _isEditing
                      ? SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _usernameController,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                            onSubmitted: (value) {
                              setState(() {
                                _username = value;
                                _isEditing = false;
                              });
                              _saveUsername(value); // Guardar el nombre de usuario
                            },
                            autofocus: true,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Usuario',
                            ),
                          ),
                        )
                      : Text(
                          _username, // Mostrar el nombre guardado o por defecto
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                final song = widget.content.songList[index];
                return GestureDetector(
                  onTap: () {
                    playerController.pushSongToQueue(song);
                  },
                  onLongPress: () {
                    showModalBottomSheet(
                      constraints: const BoxConstraints(maxWidth: 500),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0)),
                      ),
                      isScrollControlled: true,
                      context: playerController
                          .homeScaffoldkey.currentState!.context,
                      barrierColor: Colors.black.withOpacity(0.6),
                      builder: (context) => SongInfoBottomSheet(song),
                    ).whenComplete(() => Get.delete<SongInfoController>());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [Theme.of(context).primaryColor, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: ImageWidget(
                            song: song,
                            size: 150,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          song.title,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          song.artist.toString(),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[400],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: widget.content.songList.length,
              pagination: const SwiperPagination(
                alignment: Alignment.bottomCenter,
                builder: DotSwiperPaginationBuilder(
                  activeColor: Colors.transparent,
                  color: Colors.transparent,
                  size: 8.0,
                  activeSize: 12.0,
                ),
              ),
              autoplay: true,
              autoplayDelay: 3000,
              autoplayDisableOnInteraction: true,
              loop: true,
              viewportFraction: 0.75,
              scale: 0.85,
              fade: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
