import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/registration_stepper.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/field.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/custom_dropdown.dart';
import 'package:driver_app/View/Screens/Auth_Screens/Register_Screen/components/primary_button.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedVehicleType = 'Car';
  String _selectedBrand = 'Toyota';
  String _selectedModel = 'Corolla';
  String _selectedColor = 'White';
  String _selectedYear = '2024';
  
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _vehicleIdController = TextEditingController();

  final List<String> _vehicleTypes = ['Car', 'Motorcycle', 'Van', 'Truck'];
  final List<String> _brands = ['Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes'];
  final List<String> _models = ['Corolla', 'Civic', 'Focus', '3 Series', 'C-Class'];
  final List<String> _colors = ['White', 'Black', 'Silver', 'Red', 'Blue'];
  final List<String> _years = ['2024', '2023', '2022', '2021', '2020'];

  @override
  void dispose() {
    _plateNumberController.dispose();
    _vehicleIdController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // TODO: Navigate to final registration screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle details saved!'),
          backgroundColor: theme.AppColors.primary,
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
                      const SizedBox(height: 24),
                      
                      // Vehicle Type
                      CustomDropdown(
                        label: 'Vehicle Type',
                        value: _selectedVehicleType,
                        items: _vehicleTypes,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Brand
                      CustomDropdown(
                        label: 'Brand',
                        value: _selectedBrand,
                        items: _brands,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Model
                      CustomDropdown(
                        label: 'Model',
                        value: _selectedModel,
                        items: _models,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedModel = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
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
                      const SizedBox(height: 16),
                      
                      // Year
                      CustomDropdown(
                        label: 'Year',
                        value: _selectedYear,
                        items: _years,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Plate Number
                      CustomTextField(
                        label: 'Plate Number',
                        hint: 'Enter plate number',
                        isRequired: true,
                        controller: _plateNumberController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _plateNumberController.clear(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Vehicle ID
                      CustomTextField(
                        label: 'Vehicle ID',
                        hint: 'Enter vehicle ID',
                        isRequired: true,
                        controller: _vehicleIdController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _vehicleIdController.clear(),
                        ),
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
