import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:radio_app/widgets/about_section.dart';

class Player extends StatefulWidget {
  const Player({
    super.key,
    required this.percentageOpen,
    required this.title,
    required this.listener,
    required this.imageURL,
    required this.icon,
    required this.onTab,
    this.metadata,
    required this.onNext, // Kept for compatibility but not used
    required this.onPrevious, // Kept for compatibility but not used
    required this.timer,
  });

  final double percentageOpen;
  final String title;
  final String listener;
  final String imageURL;
  final IconData icon;
  final Future<void> Function() onTab;
  final List<String>? metadata;
  final VoidCallback onNext; // Not used
  final VoidCallback onPrevious; // Not used
  final String timer;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  String imageUrl = '';
  String metaTitle = '';
  String metaDescription = '';

  @override
  void initState() {
    super.initState();
    _updateMetadata();
  }

  @override
  void didUpdateWidget(Player oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update metadata when widget properties change
    if (widget.metadata != oldWidget.metadata ||
        widget.imageURL != oldWidget.imageURL) {
      _updateMetadata();
    }
  }

  void _updateMetadata() {
    final meta = widget.metadata;
    if (meta != null && meta.length >= 3) {
      final candidateImage = meta[2].trim();
      setState(() {
        //metaTitle = meta[0];
        metaDescription = meta[1];
        // Fallback to widget image when metadata image is empty.
        imageUrl = candidateImage.isNotEmpty ? candidateImage : widget.imageURL;
      });
    } else {
      setState(() {
        metaTitle = '';
        metaDescription = '';
        imageUrl = widget.imageURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    double heights = MediaQuery.of(context).size.height;
    double widths = MediaQuery.of(context).size.width;
    final imageSize = min(widths * 0.85, heights * 0.45);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: heights ),
      child: Container(
        color: Colors.grey.shade200,
        child: Stack(
          children: <Widget>[
            // Collapsed mini player (visible when percentageOpen is low)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: max(0, 1 - (widget.percentageOpen * 4)),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.music_note,
                                          color: Colors.white),
                                    );
                                  },
                                )
                              : Image.network(
                                  imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.music_note,
                                          color: Colors.white),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.listener,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade400.withValues(alpha: 0.3),
                          ),
                          child: IconButton(
                            icon: Icon(widget.icon),
                            onPressed: widget.onTab,
                            color: Colors.grey.shade800,
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Expanded player (visible when percentageOpen is high)
            Opacity(
              opacity: widget.percentageOpen > 0.3
                  ? min(1, max(0, widget.percentageOpen - 0.3) * 1.5)
                  : 0,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Container(
                  height: heights,
                  color: Colors.grey.shade200,
                  child: Column(
                    children: [
                      SizedBox(height: heights * 0.01),

                      // Album Art with border
                      Container(
                        width: imageSize,
                        height: imageSize,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF2A2A2A),
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                    );
                                  },
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF2A2A2A),
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Song Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Like/Dislike buttons commented out - not needed
                            /*IconButton(
                              icon: const Icon(Icons.thumb_down_outlined),
                              onPressed: () {},
                              color: Colors.grey.shade700,
                              iconSize: 28,
                            ),*/
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: Colors.grey.shade900,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.listener,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (metaTitle.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      metaTitle,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            /*IconButton(
                              icon: const Icon(Icons.thumb_up_outlined),
                              onPressed: () {},
                              color: Colors.grey.shade700,
                              iconSize: 28,
                            ),*/
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.timer,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '--:--',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Control Buttons - Only Play/Pause
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Shuffle button commented out - not needed
                            /*IconButton(
                              icon: const Icon(Icons.shuffle),
                              onPressed: () {},
                              color: Colors.grey.shade700,
                              iconSize: 30,
                            ),*/
                            // Previous button commented out - single station only
                            /*IconButton(
                              icon: const Icon(Icons.skip_previous),
                              onPressed: widget.onPrevious,
                              color: Colors.grey.shade800,
                              iconSize: 40,
                            ),*/
                            // Main play/pause button
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: widget.onTab,
                                icon: Icon(
                                  widget.icon,
                                  size: 32,
                                  color: Colors.grey.shade900,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            // Next button commented out - single station only
                            /*IconButton(
                              icon: const Icon(Icons.skip_next),
                              onPressed: widget.onNext,
                              color: Colors.grey.shade800,
                              iconSize: 40,
                            ),*/
                            // Repeat button commented out - not needed
                            /*IconButton(
                              icon: const Icon(Icons.repeat),
                              onPressed: () {},
                              color: Colors.grey.shade700,
                              iconSize: 30,
                            ),*/
                          ],
                        ),
                      ),
                      SizedBox(height: heights * 0.02),
                      AboutSection()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
