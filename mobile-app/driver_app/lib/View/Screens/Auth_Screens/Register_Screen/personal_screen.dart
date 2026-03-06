import 'dart:io';
import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/registration_stepper.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/field.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/custom_dropdown.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/primary_button.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/image_uploader.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/vehicule_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  File? _nidImage;
  
  String _selectedGender = 'Male';
  String _selectedWilaya = '31 - Oran';
  String _selectedDaira = 'Daira';
  
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _wilayas = [
    '31 - Oran',
    '16 - Algiers',
    '09 - Blida',
    '13 - Tlemcen',
  ];
  final List<String> _dairas = ['Daira', 'Another Daira'];

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VehicleDetailsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Header
            const RegistrationStepper(
              currentStep: 0,
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
                        'Personal Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Take your photo
                      RichText(
                        text: TextSpan(
                          text: 'Take your photo',
                          style: TextStyle(
                            color: theme.AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: theme.AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ImageUploadWidget(
                          title: 'Profile Photo',
                          subtitle: 'Upload your photo',
                          isCircular: true,
                          onImageSelected: (file) {
                            setState(() {
                              _profileImage = file;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Gender
                      CustomDropdown(
                        label: 'Gender',
                        value: _selectedGender,
                        items: _genders,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Last Name
                      CustomTextField(
                        label: 'Last Name',
                        hint: 'Last name',
                        isRequired: true,
                        controller: _lastNameController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _lastNameController.clear(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // First Name
                      CustomTextField(
                        label: 'First Name',
                        hint: 'First name',
                        isRequired: true,
                        controller: _firstNameController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _firstNameController.clear(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Picture of NID
                      ImageUploadWidget(
                        title: 'Picture of NID',
                        subtitle: 'Picture should be both NID & Clear',
                        height: 180,
                        onImageSelected: (file) {
                          setState(() {
                            _nidImage = file;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Date of Birth
                      CustomTextField(
                        label: 'Date of Birth',
                        hint: 'DD/MM/YYYY',
                        isRequired: true,
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      CustomTextField(
                        label: 'Email',
                        hint: 'weasy@email.xvy',
                        isRequired: true,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _emailController.clear(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Address
                      CustomTextField(
                        label: 'Address',
                        hint: 'Address',
                        isRequired: true,
                        controller: _addressController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _addressController.clear(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Wilaya
                      CustomDropdown(
                        label: 'Wilaya',
                        value: _selectedWilaya,
                        items: _wilayas,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedWilaya = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Daira
                      CustomDropdown(
                        label: 'Daira',
                        value: _selectedDaira,
                        items: _dairas,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedDaira = value!;
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