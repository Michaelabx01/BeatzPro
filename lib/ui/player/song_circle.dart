import 'package:beatzpro/ui/player/player_controller.dart';
import 'package:beatzpro/ui/widgets/loader.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/songinfo_bottom_sheet.dart';

class SongCircleContainer extends StatelessWidget {
  const SongCircleContainer({
    Key? key,
    required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();

    // Define the size of the container and the image
    double containerSize = 350;  // Adjust this size as needed
    double imageRadius = 150;    // Adjust this size as needed

    return GestureDetector(
      onTap: () {
        // Toggle lyrics display when the image is tapped
        playerController.showLyrics();
      },
      onLongPress: () {
        // Show Song Info Bottom Sheet when the image is long-pressed
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
          ),
          isScrollControlled: true,
          builder: (context) => SongInfoBottomSheet(
            playerController.currentSong.value!,
            calledFromPlayer: true,
          ),
        ).whenComplete(() => Get.delete<SongInfoController>());
      },
      child: SizedBox(
        height: containerSize + 30,  // Adjust height to fit larger image and space
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: containerSize,
              width: containerSize,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).bottomSheetTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              top: 20,
              child: CircularSoftButton(
                padding: 0,
                radius: imageRadius,
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(300),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: containerSize,
              width: containerSize,
              padding: const EdgeInsets.all(10),
              child: Transform.rotate(
                angle: -3.1416 / 2,  // Rotate the progress indicator to start from the right side
                child: Obx(() {
                  return CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey.withOpacity(.1),
                    value: playerController.progressBarStatus.value.current.inSeconds /
                        playerController.progressBarStatus.value.total.inSeconds,
                    strokeWidth: 7,
                    strokeCap: StrokeCap.round,
                  );
                }),
              ),
            ),
            // Display lyrics when the image is tapped
            Obx(
              () => playerController.showLyricsflag.isTrue
                  ? InkWell(
                      onTap: () {
                        playerController.showLyrics();
                      },
                      child: Container(
                        height: containerSize,
                        width: containerSize,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(190),
                        ),
                        child: Stack(
                          children: [
                            Obx(
                              () => playerController.isLyricsLoading.isTrue
                                  ? const Center(
                                      child: LoadingIndicator(),  // Custom loading widget
                                    )
                                  : Center(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: containerSize / 3.5),
                                        child: LyricsReader(
                                          lyricUi: playerController.lyricUi,
                                          position: playerController.progressBarStatus.value.current.inMilliseconds,
                                          playing: playerController.buttonState.value == PlayButtonState.playing,
                                          model: LyricsModelBuilder.create()
                                              .bindLyricToMain(playerController.lyrics['synced'].toString())
                                              .getModel(),
                                          emptyBuilder: () => Text(
                                            'No lyrics available',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(250),
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
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              bottom: 7,
              child: GestureDetector(
                onTap: () {
                  if (playerController.buttonState.value == PlayButtonState.paused) {
                    playerController.play();
                  } else {
                    playerController.pause();
                  }
                },
                child: CircleAvatar(
                  radius: 42,  // Slightly increased size for the play/pause button
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Obx(() {
                    return AnimatedSwitcher(
                      switchInCurve: Curves.easeInOutBack,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        playerController.buttonState.value == PlayButtonState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        key: ValueKey<bool>(playerController.buttonState.value == PlayButtonState.playing),
                        size: 24,  // Slightly increased icon size
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularSoftButton extends StatelessWidget {
  double? radius;
  final Widget? icon;
  final Color lightColor;
  final double? padding;
  final double? circularRadius;

  CircularSoftButton({
    Key? key,
    this.radius,
    this.icon,
    this.lightColor = Colors.white,
    this.padding,
    this.circularRadius,
  }) : super(key: key) {
    if (radius == null || radius! <= 0) radius = 32;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding ?? radius! / 2),
      child: Stack(
        children: <Widget>[
          Container(
            width: radius! * 2,
            height: radius! * 2,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.circular(circularRadius ?? radius!),
              boxShadow: [
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(8, 6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: lightColor,
                  offset: const Offset(-8, -6),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          Positioned.fill(child: icon ?? Container()),
        ],
      ),
    );
  }
}
