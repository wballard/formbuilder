import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

/// A gradient button with custom styling
class GradientButton extends StatelessWidget {
  final WidgetPlacement placement;
  final String label;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.placement,
    required this.label,
    this.onPressed,
    this.gradientColors = const [Colors.blue, Colors.purple],
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An animated toggle switch
class AnimatedToggle extends StatefulWidget {
  final WidgetPlacement placement;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final String activeLabel;
  final String inactiveLabel;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedToggle({
    super.key,
    required this.placement,
    this.initialValue = false,
    this.onChanged,
    this.activeLabel = 'ON',
    this.inactiveLabel = 'OFF',
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle>
    with SingleTickerProviderStateMixin {
  late bool _value;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_value) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _value = !_value;
      if (_value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onChanged?.call(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey[200],
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color.lerp(
                          widget.inactiveColor.withValues(alpha: 0.3),
                          widget.activeColor.withValues(alpha: 0.3),
                          _animation.value,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _animation.value * (MediaQuery.of(context).size.width - 80),
                    top: 5,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          widget.inactiveColor,
                          widget.activeColor,
                          _animation.value,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _value ? widget.activeLabel : widget.inactiveLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _value ? widget.activeColor : widget.inactiveColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A card with hover effects
class HoverCard extends StatefulWidget {
  final WidgetPlacement placement;
  final Widget child;
  final Color? color;
  final double elevation;

  const HoverCard({
    super.key,
    required this.placement,
    required this.child,
    this.color,
    this.elevation = 2,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -4.0 : 0.0),
          child: Card(
            elevation: _isHovered ? widget.elevation * 2 : widget.elevation,
            color: widget.color,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A circular progress indicator with percentage
class CircularProgressWithText extends StatelessWidget {
  final WidgetPlacement placement;
  final double value;
  final String label;
  final Color? color;
  final double size;

  const CircularProgressWithText({
    super.key,
    required this.placement,
    required this.value,
    required this.label,
    this.color,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: progressColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: size / 4,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size / 8,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// An icon box with background
class IconBox extends StatelessWidget {
  final WidgetPlacement placement;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const IconBox({
    super.key,
    required this.placement,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.1);
    final fgColor = iconColor ?? Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: fgColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: fgColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rating widget with stars
class StarRating extends StatefulWidget {
  final WidgetPlacement placement;
  final int maxRating;
  final int initialRating;
  final ValueChanged<int>? onChanged;
  final double size;
  final Color? color;

  const StarRating({
    super.key,
    required this.placement,
    this.maxRating = 5,
    this.initialRating = 0,
    this.onChanged,
    this.size = 32,
    this.color,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _rating;
  int _hoverRating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final starColor = widget.color ?? Colors.amber;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.maxRating, (index) {
          final starIndex = index + 1;
          final isFilled = starIndex <= (_hoverRating > 0 ? _hoverRating : _rating);

          return MouseRegion(
            onEnter: (_) => setState(() => _hoverRating = starIndex),
            onExit: (_) => setState(() => _hoverRating = 0),
            child: GestureDetector(
              onTap: () {
                setState(() => _rating = starIndex);
                widget.onChanged?.call(starIndex);
              },
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                size: widget.size,
                color: starColor,
              ),
            ),
          );
        }),
      ),
    );
  }
}