import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/native/native_bridge_service.dart';

class SosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final String label;

  const SosButton({
    super.key,
    required this.onTriggered,
    required this.label,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          NativeBridgeService.triggerNativeEmergencyFeedback();
          widget.onTriggered();
          _controller.reset();
          setState(() => _isHolding = false);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isHolding = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
      setState(() => _isHolding = false);
    }
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isHolding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulsating/progress ring
                  SizedBox(
                    width: 144,
                    height: 144,
                    child: CircularProgressIndicator(
                      value: _controller.value,
                      strokeWidth: 8,
                      backgroundColor: AppColors.sos.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sos),
                    ),
                  ),
                  // SOS Button Body
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sos.withOpacity(_isHolding ? 0.7 : 0.4),
                          blurRadius: _isHolding ? 24 : 14,
                          spreadRadius: _isHolding ? 4 : 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.sos,
                letterSpacing: 1.1,
              ),
        ),
      ],
    );
  }
}
