import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/special_event_service.dart';
import '../../core/services/storage_service.dart';

import '../../shared/widgets/codex/codex_header.dart';
import '../../shared/widgets/codex/event_seal_stamp.dart';
import '../../shared/widgets/codex/footer_marginalia.dart';
import '../../shared/widgets/codex/grain_overlay.dart';
import '../../shared/widgets/codex/index_tile.dart';
import '../../shared/widgets/codex/kanji_backdrop.dart';
import '../../shared/widgets/codex/magic_aura_circle.dart';
import '../../shared/widgets/codex/mantra_block.dart';
import '../../shared/widgets/codex/scanline_overlay.dart';
import '../../shared/widgets/codex/spine_label.dart';

import '../about/app_info_screen.dart';
import '../collection/collection_screen.dart';
import '../scanner/scanner_screen_v2.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  final SpecialEventService _eventService = SpecialEventService.instance;
  Timer? _eventTimer;

  @override
  void initState() {
    super.initState();
    _eventService.updateEventStatus();
    _eventTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _eventService.updateEventStatus());
      }
    });
  }

  @override
  void dispose() {
    _eventTimer?.cancel();
    super.dispose();
  }

  void _push(Widget destination) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(fade),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final event = _eventService.currentEvent;
    final remaining = _eventService.getEventRemainingMinutes();
    final collected = StorageService.instance.getAllScannedObjects().length;

    return Scaffold(
      backgroundColor: AppColors.inkDeeper,
      body: Stack(
        children: [
          // Layer 0 — atmosphere
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.3, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFF14110B),
                    AppColors.inkBlack,
                    AppColors.inkDeeper,
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Layer 1 — backdrop kanji (animated in)
          const Positioned.fill(child: KanjiBackdrop())
              .animate()
              .fadeIn(duration: 1200.ms, curve: Curves.easeOut),

          // Layer 2 — scanlines
          const Positioned.fill(child: ScanlineOverlay()),

          // Layer 3 — magic circle (right edge, partially clipped)
          Positioned(
            top: mq.padding.top + 110,
            right: -90,
            child: const MagicAuraCircle(size: 320)
                .animate()
                .fadeIn(duration: 900.ms, delay: 200.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 1200.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),

          // Layer 4 — main content
          SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SpineLabel()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideX(begin: -0.6, end: 0, duration: 700.ms),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 18, 0, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CodexHeader(collectedCount: collected)
                            .animate()
                            .fadeIn(duration: 700.ms, delay: 100.ms)
                            .slideY(begin: -0.04, end: 0, duration: 800.ms),
                        const SizedBox(height: 24),
                        const MantraBlock()
                            .animate()
                            .fadeIn(duration: 700.ms, delay: 600.ms),
                        const SizedBox(height: 22),
                        if (event != null && event.type != SpecialEventType.none) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: EventSealStamp(
                              event: event,
                              remainingMinutes: remaining,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 1100.ms)
                              .slideX(begin: -0.1, end: 0, duration: 600.ms)
                              .scale(
                                begin: const Offset(0.96, 0.96),
                                end: const Offset(1, 1),
                                duration: 600.ms,
                              ),
                          const SizedBox(height: 22),
                        ] else
                          const SizedBox(height: 8),

                        // Action tiles — staircase offsets
                        _StaircaseColumn(
                          children: [
                            IndexTile(
                              index: '01',
                              kanji: '視',
                              label: 'SCAN',
                              subLabel: '開　眼',
                              description: 'Decode the veil before you.',
                              tone: TileTone.primary,
                              onPressed: () => _push(const ScannerScreenV2()),
                            ),
                            IndexTile(
                              index: '02',
                              kanji: '蔵',
                              label: 'CODEX',
                              subLabel: '神器図鑑',
                              description: 'Witness the truths thou hast collected.',
                              tone: TileTone.secondary,
                              onPressed: () => _push(const CollectionScreen()),
                            ),
                            IndexTile(
                              index: '03',
                              kanji: '識',
                              label: 'ARCANUM',
                              subLabel: '起源覚書',
                              description: 'Acknowledge the origin of this rite.',
                              tone: TileTone.tertiary,
                              onPressed: () => _push(const AppInfoScreen()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const FooterMarginalia()
                            .animate()
                            .fadeIn(duration: 700.ms, delay: 1500.ms),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Layer 5 — grain (above everything, non-interactive)
          const Positioned.fill(
            child: GrainOverlay(opacity: 0.07, density: 2200),
          ).animate().fadeIn(duration: 600.ms),
        ],
      ),
    );
  }
}

class _StaircaseColumn extends StatelessWidget {
  final List<Widget> children;
  const _StaircaseColumn({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Padding(
            padding: EdgeInsets.only(
              left: i * 14.0,
              right: (children.length - 1 - i) * 6.0,
            ),
            child: children[i]
                .animate()
                .fadeIn(
                  duration: 600.ms,
                  delay: (1200 + i * 140).ms,
                )
                .slideY(
                  begin: 0.18,
                  end: 0,
                  duration: 700.ms,
                  delay: (1200 + i * 140).ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
          if (i < children.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
