import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/player/player_controller.dart';
import '../widgets/image_widget.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(); // Inicialmente repite la animación

    // Observa el estado del botón para pausar o reanudar la animación
    Get.find<PlayerController>().buttonState.listen((state) {
      if (state == PlayButtonState.playing) {
        _controller?.repeat(); // Reanuda la rotación si está en estado de reproducción
      } else if (state == PlayButtonState.paused) {
        _controller?.stop(); // Pausa la rotación si está en pausa
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;

    return Obx(() {
      return Visibility(
        visible: playerController.isPlayerpanelTopVisible.value,
        child: Opacity(
          opacity: playerController.playerPaneOpacity.value,
          child: Container(
            height: playerController.playerPanelMinHeight.value,
            width: size.width,
            color: Theme.of(context).sliderTheme.inactiveTrackColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Album Art con animación de rotación
                      playerController.currentSong.value != null
                          ? AnimatedBuilder(
                              animation: _controller!,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _controller!.value * 2 * 3.1416, // Rotación completa
                                  child: ClipOval(
                                    child: ImageWidget(
                                      size: 50,
                                      song: playerController.currentSong.value!,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox(
                              height: 50,
                              width: 50,
                            ),
                      const SizedBox(width: 16),
                      // Song Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerController.currentSong.value?.title ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              playerController.currentSong.value?.artist ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Playback Controls
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded,
                                color: Colors.white),
                            onPressed: playerController.prev,
                          ),
                          _playButton(context, isWideScreen),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded,
                                color: Colors.white),
                            onPressed: playerController.next,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7.0),
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProgressBar(
                    progress: playerController.progressBarStatus.value.current,
                    total: playerController.progressBarStatus.value.total,
                    buffered: playerController.progressBarStatus.value.buffered,
                    onSeek: playerController.seek,
                    barHeight: 4.0,
                    thumbRadius: 7.0,
                    baseBarColor:
                        Theme.of(context).sliderTheme.inactiveTrackColor,
                    bufferedBarColor:
                        Theme.of(context).sliderTheme.valueIndicatorColor,
                    progressBarColor:
                        Theme.of(context).sliderTheme.activeTrackColor,
                    thumbColor: Theme.of(context).sliderTheme.thumbColor,
                    // Asegúrate de que la propiedad para ocultar el tiempo esté configurada correctamente
                    timeLabelLocation: TimeLabelLocation
                        .none, // Ejemplo de propiedad para ocultar el tiempo
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _playButton(BuildContext context, bool isWideScreen) {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      if (buttonState == PlayButtonState.loading) {
        return const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.0,
        );
      }

      if (buttonState == PlayButtonState.paused) {
        return IconButton(
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
          ),
          iconSize: 30.0,
          onPressed: controller.play,
        );
      } else {
        return IconButton(
          icon: const Icon(
            Icons.pause_rounded,
            color: Colors.white,
          ),
          iconSize: 30.0,
          onPressed: controller.pause,
        );
      }
    });
  }
}
