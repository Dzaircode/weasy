import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;

class RegistrationStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const RegistrationStepper({
    Key? key,
    required this.currentStep,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: theme.AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Image.asset(
            'images/logo.png',
            width: 120,
            height: 40,
          ),
          const SizedBox(height: 30),
          
          // Stepper
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              final isLast = index == steps.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    // Step Circle
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isCompleted || isCurrent
                                  ? theme.AppColors.white
                                  : theme.AppColors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : _getStepIcon(index),
                              color: isCompleted || isCurrent
                                  ? theme.AppColors.black
                                  : theme.AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            steps[index],
                            style: TextStyle(
                              color: theme.AppColors.white,
                              fontSize: 12,
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 30),
                          color: isCompleted
                              ? theme.AppColors.white
                              : theme.AppColors.white.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.person;
      case 1:
        return Icons.two_wheeler;
      case 2:
        return Icons.app_registration;
      default:
        return Icons.circle;
    }
  }
}