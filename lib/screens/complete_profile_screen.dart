// lib/screens/complete_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regNoController = TextEditingController();

  String? _userId;
  String? _selectedDepartment;
  String? _selectedCampus; // <-- NEW: State variable for selected campus

  final List<String> _departmentOptions = [
    'Computer Science', 'Commerce', 'Business Administration', 'Electronics',
    'Mechanical Engineering', 'Civil Engineering', 'Biotechnology',
    'Arts & Humanities', 'Sciences', 'Law',
    // Add others
  ];

  // --- NEW: List of campus options ---
  final List<String> _campusOptions = [
    'Delhi NCR',
    'Bangalore Central',
    'Bangalore Kengeri',
    'Bangalore Bannerghatta',
    'Pune Lavasa',
    // Add other campuses
  ];

  @override
  void initState() {
    super.initState();
    _userId = _supabase.auth.currentUser?.id;
    _nameController.text =
        _supabase.auth.currentUser?.userMetadata?['full_name'] ?? '';

    if (_userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: Not logged in."),
              backgroundColor: Colors.red,
            ),
          );
          context.goNamed('login');
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _regNoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // --- UPDATED: Validate form including campus dropdown ---
    if (!_formKey.currentState!.validate()) {
      return; // Stops if any field (including dropdowns) is invalid
    }
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: User session not found."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Redundant checks as validator handles this, but safe to keep
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your department."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedCampus == null) {
      // <-- Check campus selection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your campus."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final profileData = {
      'user_id': _userId!,
      'full_name': _nameController.text.trim(),
      'phone_no': _phoneController.text.trim(),
      'register_no': _regNoController.text.trim(),
      'department': _selectedDepartment,
      'campus': _selectedCampus, // <-- ADD selected campus
      'updated_at': DateTime.now().toIso8601String(),
      // avatar_url might be set here if completing profile includes avatar selection
    };

    try {
      // Upsert logic (Update if exists, Insert if not)
      await _supabase.from('profiles').upsert(profileData); // Use upsert

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        context.goNamed('home'); // Navigate after successful save
      }
    } on PostgrestException catch (error) {
      print('--- ERROR saving profile (Postgrest): ${error.message} ---');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Database Error: ${error.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('--- ERROR saving profile (Generic): ${error.toString()} ---');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Please provide your details',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 30),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Please enter your full name'
                              : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 15),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Please enter your phone number'
                              : null,
                ),
                const SizedBox(height: 15),

                // Register Number
                TextFormField(
                  controller: _regNoController,
                  decoration: const InputDecoration(
                    labelText: 'Register Number',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Please enter your register number'
                              : null,
                ),
                const SizedBox(height: 15),

                // Department Dropdown (Keep as is)
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select your department'),
                  items:
                      _departmentOptions.map((String department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                  onChanged:
                      (String? newValue) =>
                          setState(() => _selectedDepartment = newValue),
                  validator:
                      (value) =>
                          value == null
                              ? 'Please select your department'
                              : null,
                ),
                const SizedBox(height: 15), // Spacing
                // --- NEW: Campus Dropdown ---
                DropdownButtonFormField<String>(
                  value: _selectedCampus, // Bind to state variable
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Campus', // Label for the dropdown
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select your campus'), // Placeholder text
                  items:
                      _campusOptions.map((String campus) {
                        // Create items from list
                        return DropdownMenuItem<String>(
                          value: campus,
                          child: Text(campus),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    // Update state on change
                    setState(() {
                      _selectedCampus = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null
                              ? 'Please select your campus'
                              : null, // Validation
                ),

                // --- End Campus Dropdown ---
                const SizedBox(height: 30),

                // Save Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _saveProfile,
                      child: const Text('Save Profile & Continue'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
