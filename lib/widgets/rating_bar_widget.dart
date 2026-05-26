import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Interactive star rating bar (1–5 stars).
class RatingBarWidget extends StatefulWidget {
  final double initialRating;
  final double itemSize;
  final bool readOnly;
  final ValueChanged<double>? onRatingChanged;

  const RatingBarWidget({
    super.key,
    this.initialRating = 0,
    this.itemSize = 32,
    this.readOnly = false,
    this.onRatingChanged,
  });

  @override
  State<RatingBarWidget> createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  void didUpdateWidget(RatingBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      _rating = widget.initialRating;
    }
  }

  void _onTap(int index) {
    if (widget.readOnly) return;
    final newRating = index + 1.0;
    setState(() => _rating = newRating);
    widget.onRatingChanged?.call(newRating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icon;
        if (i < _rating.floor()) {
          icon = Icons.star_rounded;
        } else if (i < _rating) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return GestureDetector(
          onTap: () => _onTap(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(icon, color: AppColors.star, size: widget.itemSize),
          ),
        );
      }),
    );
  }
}

/// Read-only compact star display used in book cards / headers.
class StarDisplay extends StatelessWidget {
  final double rating;
  final int count;
  final double starSize;
  final Color? textColor;

  const StarDisplay({
    super.key,
    required this.rating,
    this.count = 0,
    this.starSize = 14,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final IconData icon;
          if (i < rating.floor()) {
            icon = Icons.star_rounded;
          } else if (i < rating) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
          return Icon(icon, color: AppColors.star, size: starSize);
        }),
        const SizedBox(width: 4),
        Text(
          count > 0
              ? '${rating.toStringAsFixed(1)} (${_fmt(count)})'
              : rating.toStringAsFixed(1),
          style: TextStyle(color: color, fontSize: starSize * 0.85),
        ),
      ],
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}
