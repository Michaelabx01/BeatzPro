import 'package:beatzpro/ui/widgets/marqwee_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beatzpro/ui/player/player_controller.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'image_widget.dart';
import 'songinfo_bottom_sheet.dart';

class UpNextQueue extends StatelessWidget {
  const UpNextQueue({
    super.key,
    this.onReorderEnd,
    this.onReorderStart,
    this.isQueueInSlidePanel = true,
  });

  final void Function(int)? onReorderStart;
  final void Function(int)? onReorderEnd;
  final bool isQueueInSlidePanel;

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Theme.of(context).primaryColorDark, Colors.black],
          center: const Alignment(-0.5, -0.6),
          radius: 1.5,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Obx(() {
        return ReorderableListView.builder(
          scrollController: isQueueInSlidePanel ? playerController.scrollController : null,
          onReorder: playerController.onReorder,
          onReorderStart: onReorderStart,
          onReorderEnd: onReorderEnd,
          itemCount: playerController.currentQueue.length,
          padding: EdgeInsets.only(
            top: isQueueInSlidePanel ? 55 : 0,
            bottom: Get.mediaQuery.padding.bottom,
          ),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final homeScaffoldContext = playerController.homeScaffoldkey.currentContext!;
            final isSelected = playerController.currentSongIndex.value == index;

            return GestureDetector(
              key: Key('item_$index'), // Clave única para cada elemento
              onHorizontalDragUpdate: (details) {
                if (details.primaryDelta! > 0) {
                  // Acción al deslizar hacia la derecha (por ejemplo, reproducir la siguiente canción)
                  playerController.seekByIndex((index + 1) % playerController.currentQueue.length);
                } else if (details.primaryDelta! < 0) {
                  // Acción al deslizar hacia la izquierda (por ejemplo, reproducir la canción anterior)
                  playerController.seekByIndex((index - 1) % playerController.currentQueue.length);
                }
              },
              onTap: () {
                playerController.seekByIndex(index);
              },
              onLongPress: () {
                showModalBottomSheet(
                  constraints: const BoxConstraints(maxWidth: 500),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  isScrollControlled: true,
                  context: playerController.homeScaffoldkey.currentState!.context,
                  barrierColor: Colors.transparent.withAlpha(100),
                  builder: (context) => SongInfoBottomSheet(
                    playerController.currentQueue[index],
                    calledFromQueue: true,
                  ),
                ).whenComplete(() => Get.delete<SongInfoController>());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(homeScaffoldContext).colorScheme.secondary.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(homeScaffoldContext).colorScheme.secondary.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: ImageWidget(
                      size: 55,
                      song: playerController.currentQueue[index],
                    ),
                  ),
                  title: MarqueeWidget(
                    child: Text(
                      playerController.currentQueue[index].title,
                      maxLines: 1,
                      style: Theme.of(homeScaffoldContext).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(homeScaffoldContext).colorScheme.onSecondary
                                : Theme.of(homeScaffoldContext).textTheme.titleMedium!.color,
                          ),
                    ),
                  ),
                  subtitle: Text(
                    playerController.currentQueue[index].artist ?? '',
                    maxLines: 1,
                    style: Theme.of(homeScaffoldContext).textTheme.bodySmall!.copyWith(
                          color: isSelected
                              ? Theme.of(homeScaffoldContext).colorScheme.onSecondary.withOpacity(0.7)
                              : Theme.of(homeScaffoldContext).textTheme.bodySmall!.color,
                        ),
                  ),
                  trailing: ReorderableDragStartListener(
                    enabled: !GetPlatform.isDesktop,
                    index: index,
                    child: SizedBox(
                      width: 40, // Establecer un ancho fijo para el widget
                      child: isSelected
                          ? const MiniMusicVisualizer(
                              color: Colors.red,
                              radius: 20.0,
                              width: 3,
                              height: 20,
                              animate: true,
                            )
                          : Text(
                              playerController.currentQueue[index].extras!['length'] ?? '',
                              style: Theme.of(homeScaffoldContext).textTheme.titleSmall,
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
