import 'package:flutter/material.dart';

class NotificationBell extends StatefulWidget {
  final int unreadCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? badgeColor;
  final Color? iconColor;
  final double? badgeSize;
  final String? tooltip;

  const NotificationBell({
    Key? key,
    this.unreadCount = 0,
    this.onTap,
    this.onLongPress,
    this.badgeColor,
    this.iconColor,
    this.badgeSize,
    this.tooltip,
  }) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(NotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation if unread count changed from 0 to >0
    if (oldWidget.unreadCount == 0 && widget.unreadCount > 0) {
      _playAnimation();
    }
  }

  void _playAnimation() {
    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            children: [
              GestureDetector(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                child: Icon(
                  Icons.notifications,
                  color: widget.iconColor ?? Colors.grey[700],
                  size: 28,
                ),
              ),
              if (widget.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: widget.badgeColor ?? Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    constraints: BoxConstraints(
                      minWidth: widget.badgeSize ?? 18,
                      minHeight: widget.badgeSize ?? 18,
                    ),
                    child: Text(
                      widget.unreadCount > 99
                          ? '99+'
                          : widget.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}