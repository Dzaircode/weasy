import 'dart:io';
import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'components/registration_stepper.dart';
import 'components/field.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/custom_dropdown.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/primary_button.dart';
import 'components/image_uploader.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/driver_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _vehicleImage;
  
  String _selectedVehicleType = 'Car';
  String _selectedBrand = 'Toyota';
  String _selectedModel = 'Seinna 2025 V1';
  String _selectedColor = 'Red';
  
  final TextEditingController _matriculeController = TextEditingController();
  
  bool _isPhotosGenuine = false;
  bool _isInfoAccurate = false;

  final List<String> _brands = ['Toyota', 'Honda', 'Mercedes', 'BMW'];
  final List<String> _models = ['Seinna 2025 V1', 'Model 2', 'Model 3'];
  final List<String> _colors = ['Red', 'Black', 'White', 'Blue', 'Silver'];

  @override
  void dispose() {
    _matriculeController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      if (!_isPhotosGenuine || !_isInfoAccurate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please confirm checkboxes'),
            backgroundColor: theme.AppColors.primary,
          ),
        );
        return;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverInformationScreen(),
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
              currentStep: 1,
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
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.AppColors.black,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Choose your vehicle
                      RichText(
                        text: TextSpan(
                          text: 'Choose your vehicle',
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
                      SizedBox(height: 12),
                      
                      // Vehicle Type Grid
                      Row(
                        children: [
                          Expanded(
                            child: _VehicleTypeCard(
                              label: 'Car',
                              icon: '🚗',
                              isSelected: _selectedVehicleType == 'Car',
                              onTap: () {
                                setState(() {
                                  _selectedVehicleType = 'Car';
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _VehicleTypeCard(
                              label: 'Motorcycle',
                              icon: '🏍️',
                              isSelected: _selectedVehicleType == 'Motorcycle',
                              onTap: () {
                                setState(() {
                                  _selectedVehicleType = 'Motorcycle';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _VehicleTypeCard(
                              label: 'Scooter',
                              icon: '🛵',
                              isSelected: _selectedVehicleType == 'Scooter',
                              onTap: () {
                                setState(() {
                                  _selectedVehicleType = 'Scooter';
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _VehicleTypeCard(
                              label: 'Micro-van',
                              icon: '🚐',
                              isSelected: _selectedVehicleType == 'Micro-van',
                              onTap: () {
                                setState(() {
                                  _selectedVehicleType = 'Micro-van';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      // Vehicle Brand
                      CustomDropdown(
                        label: 'Vehicle Brand',
                        value: _selectedBrand,
                        items: _brands,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Vehicle Model
                      CustomDropdown(
                        label: 'Vehicle Model',
                        value: _selectedModel,
                        items: _models,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedModel = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Vehicle Matricule
                      CustomTextField(
                        label: 'Vehicle Matricule',
                        hint: '09876 543 21',
                        isRequired: true,
                        controller: _matriculeController,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () => _matriculeController.clear(),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Picture of Vehicle
                      ImageUploadWidget(
                        title: 'Picture of Vehicle',
                        subtitle: 'Pictures of the vehicle wide & Clear',
                        height: 200,
                        onImageSelected: (file) {
                          setState(() {
                            _vehicleImage = file;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Color
                      CustomDropdown(
                        label: 'Color',
                        value: _selectedColor,
                        items: _colors,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedColor = value!;
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      
                      // Checkboxes
                      CheckboxListTile(
                        value: _isPhotosGenuine,
                        onChanged: (value) {
                          setState(() {
                            _isPhotosGenuine = value!;
                          });
                        },
                        title: Text(
                          'I confirm that all uploaded photos are genuine and unaltered.',
                          style: TextStyle(fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: theme.AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        value: _isInfoAccurate,
                        onChanged: (value) {
                          setState(() {
                            _isInfoAccurate = value!;
                          });
                        },
                        title: Text(
                          'I attest that all the informations provided are accurate',
                          style: TextStyle(fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: theme.AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      SizedBox(height: 24),
                      
                      // Continue Button
                      PrimaryButton(
                        text: 'Continue',
                        onPressed: _handleContinue,
                        width: double.infinity,
                      ),
                      SizedBox(height: 20),
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

class _VehicleTypeCard extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  icon,
                  style: TextStyle(fontSize: 32),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.AppColors.primary : Colors.grey[300],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: theme.AppColors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}