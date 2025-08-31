import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatelessWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark 
                  ? [
                      const Color(0xFF0D1117),
                      const Color(0xFF161B22),
                      const Color(0xFF21262D),
                    ]
                  : [
                      const Color(0xFFF1F8E9),
                      const Color(0xFFE8F5E8),
                      const Color(0xFFDCEDC8),
                    ],
            ),
          ),
        ),
        ...List.generate(6, (index) => _AnimatedBubble(index: index)),
        ...List.generate(4, (index) => _AnimatedLeaf(index: index)),
        child,
      ],
    );
  }
}

class _AnimatedBubble extends StatelessWidget {
  final int index;

  const _AnimatedBubble({required this.index});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = math.Random(index);
    
    return Positioned(
      left: random.nextDouble() * size.width,
      top: random.nextDouble() * size.height,
      child: Container(
        width: 20 + random.nextDouble() * 40,
        height: 20 + random.nextDouble() * 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF66BB6A) 
              : const Color(0xFF81C784))
              .withOpacity(0.1 + random.nextDouble() * 0.2),
          border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF4CAF50) 
                : const Color(0xFF66BB6A))
                .withOpacity(0.3),
            width: 1,
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            duration: Duration(seconds: 3 + random.nextInt(4)),
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.2, 1.2),
          )
          .then()
          .scale(
            duration: Duration(seconds: 3 + random.nextInt(4)),
            begin: const Offset(1.2, 1.2),
            end: const Offset(0.8, 0.8),
          ),
    );
  }
}

class _AnimatedLeaf extends StatelessWidget {
  final int index;

  const _AnimatedLeaf({required this.index});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = math.Random(index + 10);
    
    return Positioned(
      left: random.nextDouble() * size.width,
      top: random.nextDouble() * size.height,
      child: Transform.rotate(
        angle: random.nextDouble() * 2 * math.pi,
        child: Icon(
          Icons.eco,
          size: 20 + random.nextDouble() * 20,
          color: (Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF66BB6A) 
              : const Color(0xFF4CAF50))
              .withOpacity(0.1 + random.nextDouble() * 0.2),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(
            duration: Duration(seconds: 8 + random.nextInt(8)),
            begin: 0,
            end: 2 * math.pi,
          )
          .moveY(
            duration: Duration(seconds: 4 + random.nextInt(4)),
            begin: 0,
            end: 20 + random.nextDouble() * 40,
          )
          .then()
          .moveY(
            duration: Duration(seconds: 4 + random.nextInt(4)),
            begin: 20 + random.nextDouble() * 40,
            end: 0,
          ),
    );
  }
}