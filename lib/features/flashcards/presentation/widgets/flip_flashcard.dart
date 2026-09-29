import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/flashcard.dart';

class FlipFlashcard extends StatefulWidget {
  const FlipFlashcard({
    super.key,
    required this.card,
    this.height = 410,
    this.showAnswerSignal = 0,
    this.tapEnabled = true,
    this.onTap,
  });

  final Flashcard card;
  final double height;
  final int showAnswerSignal;
  final bool tapEnabled;
  final VoidCallback? onTap;

  @override
  State<FlipFlashcard> createState() => _FlipFlashcardState();
}

class _FlipFlashcardState extends State<FlipFlashcard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showingBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 430),
    );
  }

  @override
  void didUpdateWidget(covariant FlipFlashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _controller.value = 0;
      _showingBack = false;
    } else if (oldWidget.showAnswerSignal != widget.showAnswerSignal) {
      flip();
    }
  }

  Future<void> flip() async {
    if (_controller.isAnimating) return;
    HapticFeedback.selectionClick();
    if (_showingBack) {
      await _controller.reverse();
    } else {
      await _controller.forward();
    }
    if (mounted) setState(() => _showingBack = !_showingBack);
  }

  void _handleTap() {
    widget.onTap?.call();
    if (widget.tapEnabled) flip();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.tapEnabled || widget.onTap != null ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final showingFront = angle <= math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0014)
              ..rotateY(angle),
            child: showingFront
                ? _CardFace(
                    key: const ValueKey('front'),
                    card: widget.card,
                    isAnswer: false,
                    height: widget.height,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      key: const ValueKey('back'),
                      card: widget.card,
                      isAnswer: true,
                      height: widget.height,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    super.key,
    required this.card,
    required this.isAnswer,
    required this.height,
  });

  final Flashcard card;
  final bool isAnswer;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isAnswer ? const Color(0xFFFFF1CB) : Colors.white;
    final accent = isAnswer ? AppTheme.orange : AppTheme.purple;

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF242338).withValues(alpha: 0.09),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  card.category.isEmpty ? 'General' : card.category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAnswer ? Icons.lightbulb_rounded : Icons.touch_app_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            isAnswer ? 'ANSWER' : 'QUESTION',
            style: theme.textTheme.bodyMedium?.copyWith(
              letterSpacing: 1.8,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAnswer ? card.answer : card.question,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 27,
              height: 1.28,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.flip_camera_android_rounded,
                color: AppTheme.mutedInk,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                isAnswer ? 'Tap to see question' : 'Tap to flip',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
