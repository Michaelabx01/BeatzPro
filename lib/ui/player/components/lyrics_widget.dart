import 'package:BeatzPro/ui/utils/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/custom_lyrics.dart';
import '../../widgets/loader.dart';
import '../player_controller.dart';

class LyricsWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const LyricsWidget({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    return Obx(
      () => playerController.isLyricsLoading.isTrue
          ? const Center(
              child: LoadingIndicator(),
            )
          : playerController.lyricsMode.toInt() == 1
              ? Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: padding,
                    child: Obx(
                      () => TextSelectionTheme(
                        data: Theme.of(context).textSelectionTheme,
                        child: SelectableText(
                          playerController.lyrics["plainLyrics"] == "NA"
                              ? "lyricsNotAvailable".tr
                              : playerController.lyrics["plainLyrics"],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.acme(
                            textStyle: Theme.of(context)
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
                    ),
                  ),
                )
              : IgnorePointer(
                  child: LyricsReader(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    lyricUi: CustomLyricUI(
                      primaryColor:
                          Theme.of(context).primaryColor.withLightness(0.2),
                      highlightColor:
                          Theme.of(context).primaryColor.withLightness(0.4),
                      fontSize: 25,
                      highlightFontSize: 28,
                    ),
                    position: playerController
                        .progressBarStatus.value.current.inMilliseconds,
                    model: LyricsModelBuilder.create()
                        .bindLyricToMain(
                            playerController.lyrics['synced'].toString())
                        .getModel(),
                    emptyBuilder: () => Center(
                      child: Text(
                        "syncedLyricsNotAvailable".tr,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withLightness(0.4),
                                ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
