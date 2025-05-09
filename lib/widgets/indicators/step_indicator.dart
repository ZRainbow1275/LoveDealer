import 'package:flutter/material.dart';
import '../../app/theme/color_theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepTitles;
  final double lineWidth;
  final double circleSize;
  final Color activeColor;
  final Color inactiveColor;
  final Color completeColor;
  final bool showStepNumbers;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles,
    this.lineWidth = 3.0,
    this.circleSize = 32.0,
    this.activeColor = ColorTheme.primaryColor,
    this.inactiveColor = ColorTheme.timelineInactive,
    this.completeColor = ColorTheme.primaryColor,
    this.showStepNumbers = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        // 奇数索引是步骤点，偶数索引是连接线
        if (index % 2 == 0) {
          final stepIndex = index ~/ 2;
          return _buildStep(stepIndex);
        } else {
          final lineIndex = index ~/ 2;
          return _buildLine(lineIndex);
        }
      }),
    );
  }

  Widget _buildStep(int index) {
    bool isActive = index == currentStep - 1;
    bool isComplete = index < currentStep - 1;
    Color color = isActive 
        ? activeColor 
        : isComplete 
            ? completeColor 
            : inactiveColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isComplete
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.0,
                  )
                : showStepNumbers
                    ? Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
          ),
        ),
        if (stepTitles != null && stepTitles!.length > index) ...[
          const SizedBox(height: 4.0),
          Text(
            stepTitles![index],
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: isActive || isComplete ? FontWeight.bold : FontWeight.normal,
              color: isActive || isComplete ? activeColor : inactiveColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLine(int index) {
    bool isActive = index < currentStep - 1;
    return Expanded(
      child: Container(
        height: lineWidth,
        color: isActive ? completeColor : inactiveColor,
      ),
    );
  }
} 