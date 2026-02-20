import 'dart:io';
import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'components/registration_stepper.dart';
import 'components/field.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/primary_button.dart';
import 'components/image_uploader.dart';

class DriverInformationScreen extends StatefulWidget {
  const DriverInformationScreen({Key? key}) : super(key: key);

  @override
  State<DriverInformationScreen> createState() => _DriverInformationScreenState();
}

class _DriverInformationScreenState extends State<DriverInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _licenseImage;
  
  final TextEditingController _licenseNumController = TextEditingController();
  final TextEditingController _licenseDateController = TextEditingController();

  @override
  void dispose() {
    _licenseNumController.dispose();
    _licenseDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: theme.AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _licenseDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog or navigate to home
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Registration Complete!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.AppColors.black,
            ),
          ),
          content: const Text(
            'Your registration has been submitted successfully. We will review your information and get back to you soon.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to home or login screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: theme.AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Header
            const RegistrationStepper(
              currentStep: 2,
              steps: ['Personal', 'Vehicle', 'Register'],
            ),
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Informations',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Driver License NUM
                      CustomTextField(
                        label: 'Driver License NUM',
                        hint: '1234567890',
                        isRequired: true,
                        controller: _licenseNumController,
                        keyboardType: TextInputType.number,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _licenseNumController.clear(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // License Date
                      CustomTextField(
                        label: 'License Date',
                        hint: '01/01/2000',
                        isRequired: true,
                        controller: _licenseDateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Picture of NID
                      ImageUploadWidget(
                        title: 'Picture of NID',
                        subtitle: 'Picture should be both NID & Clear',
                        height: 200,
                        onImageSelected: (file) {
                          setState(() {
                            _licenseImage = file;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Continue Button
                      PrimaryButton(
                        text: 'Continue',
                        onPressed: _handleContinue,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 20),
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