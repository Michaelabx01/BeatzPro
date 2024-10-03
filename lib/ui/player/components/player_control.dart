import 'package:BeatzPro/ui/utils/theme_controller.dart';
import 'package:BeatzPro/ui/widgets/Custombar_personalisation.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '../../widgets/animation_playbutton.dart';
import '../../widgets/loader.dart';
import '../player_controller.dart';

class PlayerControlWidget extends StatelessWidget {
  const PlayerControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 5),
                        id: "Current Song",
                        child: Text(
                          playerController.currentSong.value != null
                              ? playerController.currentSong.value!.title
                              : "NA",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.labelMedium!,
                        ),
                      );
                    }),
                    const SizedBox(
                      height: 10,
                    ),
                    GetX<PlayerController>(builder: (controller) {
                      return Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 5),
                        id: "Current Song artists",
                        child: Text(
                          playerController.currentSong.value != null
                              ? controller.currentSong.value!.artist!
                              : "NA",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    }),
                  ]),
            ),
            SizedBox(
              width: 55,
              child: IconButton(
                  onPressed: playerController.toggleFavourite,
                  icon: Obx(() => Icon(
                        playerController.isCurrentSongFav.isFalse
                            ? Icons.favorite_border_rounded
                            : Icons.favorite_rounded,
                        color:
                            Theme.of(context).primaryColor.withLightness(0.5),
                      ))),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        GetX<PlayerController>(builder: (controller) {
          return CustomProgressBar(
            // Aquí se usa la barra de progreso personalizada
            currentSliderValue: controller
                    .progressBarStatus.value.current.inSeconds
                    .toDouble() /
                60,
            maxValue:
                controller.progressBarStatus.value.total.inSeconds.toDouble() /
                    60,
            onChanged: (value) {
              controller.seek(Duration(seconds: (value * 60).toInt()));
            },
          );
        }),
        // GetX<PlayerController>(builder: (controller) {
        //   return ProgressBar(
        //     baseBarColor: Theme.of(context).sliderTheme.inactiveTrackColor,
        //     bufferedBarColor: Theme.of(context).sliderTheme.valueIndicatorColor,
        //     progressBarColor: Theme.of(context).sliderTheme.activeTrackColor,
        //     thumbColor: Theme.of(context).sliderTheme.thumbColor,
        //     timeLabelTextStyle: Theme.of(context).textTheme.titleMedium,
        //     progress: controller.progressBarStatus.value.current,
        //     total: controller.progressBarStatus.value.total,
        //     buffered: controller.progressBarStatus.value.buffered,
        //     onSeek: controller.seek,
        //   );
        // }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: playerController.toggleShuffleMode,
                icon: Obx(() => Icon(
                      Ionicons.shuffle,
                      color: playerController.isShuffleModeEnabled.value
                          ? Theme.of(context).primaryColor.withLightness(0.5)
                          : Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .color!
                              .withOpacity(0.2),
                    ))),
            _previousButton(playerController, context),
            CircleAvatar(
                radius: 35,
                child: _playButton(context)), // Pasar el contexto aquí
            _nextButton(playerController, context),
            Obx(() {
              return IconButton(
                onPressed: playerController.toggleLoopMode,
                icon: Icon(
                  Icons.all_inclusive,
                  color: playerController.isLoopModeEnabled.value
                      ? Theme.of(context).primaryColor.withLightness(0.5)
                      : Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .color!
                              .withOpacity(0.2),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  // Pasar el contexto a esta función
  Widget _playButton(BuildContext context) {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      bool isPlaying = buttonState == PlayButtonState.playing;

      return PlayButton(
        isPlaying: isPlaying,
        playIcon: Icon(Icons.play_arrow,
            color: Theme.of(context).primaryColor.withLightness(0.5), size: 40),
        pauseIcon: Icon(Icons.pause,
            color: Theme.of(context).primaryColor.withLightness(0.5), size: 40),
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

  Widget _previousButton(
      PlayerController playerController, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.skip_previous_rounded,
        color: Theme.of(context).primaryColor.withLightness(0.5),
      ),
      iconSize: 30,
      onPressed: playerController.prev,
    );
  }
}

// También aquí
Widget _nextButton(PlayerController playerController, BuildContext context) {
  return Obx(() {
    final isLastSong = playerController.currentQueue.isEmpty ||
        (playerController.isShuffleModeEnabled.isFalse &&
            (playerController.currentQueue.last.id ==
                playerController.currentSong.value?.id));
    return IconButton(
      icon: Icon(
        Icons.skip_next_rounded,
        color: Theme.of(context).primaryColor.withLightness(0.5),
      ),
      iconSize: 30,
      onPressed: isLastSong ? null : playerController.next,
    );
  });
}
