import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../screens/Settings/settings_screen_controller.dart';
import '/models/artist.dart';
import '../../models/album.dart';
import '../../models/playlist.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    super.key,
    this.song,
    this.playlist,
    this.album,
    this.artist,
    required this.size,
    this.isPlayerArtImage = false,
  });
  final MediaItem? song;
  final Playlist? playlist;
  final Album? album;
  final bool isPlayerArtImage;
  final Artist? artist;
  final double size;

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(); // Repite la animación indefinidamente
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  double getAngle() {
    return _controller!.value * 2 * 3.1416; // Rotación completa (360 grados)
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.song != null
        ? widget.song!.artUri.toString()
        : widget.playlist != null
            ? widget.playlist!.thumbnailUrl
            : widget.album != null
                ? widget.album!.thumbnailUrl
                : widget.artist != null
                    ? widget.artist!.thumbnailUrl
                    : "";
    String cacheKey = widget.song != null
        ? "${widget.song!.id}_song"
        : widget.playlist != null
            ? "${widget.playlist!.playlistId}_playlist"
            : widget.album != null
                ? "${widget.album!.browseId}_album"
                : widget.artist != null
                    ? "${widget.artist!.browseId}_artist"
                    : "";

    return CircularPercentIndicator(
      radius: widget.size / 2, // Ajustar el tamaño del indicador según el tamaño de la imagen
      percent: 0.75, // Puedes cambiar este valor para reflejar el porcentaje deseado
      progressColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      center: AnimatedBuilder(
        animation: _controller!,
        builder: (_, child) {
          return Transform.rotate(
            angle: getAngle(),
            child: child,
          );
        },
        child: GetPlatform.isWeb
            ? ClipOval( // Hace la imagen redonda en la web
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                  width: widget.size,
                  height: widget.size,
                ),
              )
            : Container(
                height: widget.size,
                width: widget.size,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, // Siempre circular
                ),
                child: ClipOval( // Hace la imagen redonda en móvil
                  child: CachedNetworkImage(
                    height: widget.size,
                    width: widget.size,
                    memCacheHeight: (widget.song != null && !widget.isPlayerArtImage) ? 140 : null,
                    cacheKey: cacheKey,
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      // Si la miniatura existe en el almacenamiento de la aplicación
                      if (widget.song != null) {
                        final imgFile = File(
                            "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${widget.song!.id}.png");
                        if (imgFile.existsSync()) {
                          return ClipOval(
                            child: Image.file(
                              imgFile,
                              height: widget.size,
                              width: widget.size,
                              cacheHeight:
                                  (widget.song != null && !widget.isPlayerArtImage) ? 140 : null,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      }
                      return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                              "assets/icons/${widget.song != null ? "song" : widget.artist != null ? "artist" : "album"}.png"));
                    },
                    progressIndicatorBuilder: ((_, __, ___) => Shimmer.fromColors(
                        baseColor: Colors.grey[500]!,
                        highlightColor: Colors.grey[300]!,
                        enabled: true,
                        direction: ShimmerDirection.ltr,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Siempre circular
                            color: Colors.white54,
                          ),
                        ))),
                  ),
                ),
              ),
      ),
    );
  }
}
