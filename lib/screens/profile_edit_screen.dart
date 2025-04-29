// lib/screens/profile_edit_screen.dart
// MODIFIED: Replaced image upload with predefined avatar selection

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart'; // REMOVED image_picker
import 'package:supabase_flutter/supabase_flutter.dart';

// --- NEW: Define Predefined Avatar URLs ---
// TODO: Replace with your actual hosted image URLs
// Example URLs (replace with your actual URLs hosted publicly, e.g., in Supabase Storage)
const List<String> predefinedAvatarUrls = [
  'https://srmirwkdbcktvlyflvdi.supabase.co/storage/v1/object/sign/profile-pictures/defaults/avatar1.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2IyNjNiMmY4LThhZGEtNDRkNi04MjIyLTcxYTZiNDk3MTE2NyJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3R1cmVzL2RlZmF1bHRzL2F2YXRhcjEucG5nIiwiaWF0IjoxNzQ1ODI1MDA3LCJleHAiOjE3NzczNjEwMDd9.YvUEMs0HNb7Qe1yDj42WCmB_tX-6EvCXirR21164M2Y',
  'https://srmirwkdbcktvlyflvdi.supabase.co/storage/v1/object/sign/profile-pictures/defaults/avatar2.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2IyNjNiMmY4LThhZGEtNDRkNi04MjIyLTcxYTZiNDk3MTE2NyJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3R1cmVzL2RlZmF1bHRzL2F2YXRhcjIucG5nIiwiaWF0IjoxNzQ1ODI0OTg2LCJleHAiOjE3NzczNjA5ODZ9.WwKtVu7S7144SvtXnaCyVUQkW6yCwetLG7C_5ehXInE',
  'https://srmirwkdbcktvlyflvdi.supabase.co/storage/v1/object/sign/profile-pictures/defaults/avatar3.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2IyNjNiMmY4LThhZGEtNDRkNi04MjIyLTcxYTZiNDk3MTE2NyJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3R1cmVzL2RlZmF1bHRzL2F2YXRhcjMucG5nIiwiaWF0IjoxNzQ1ODI0OTczLCJleHAiOjE3NzczNjA5NzN9.1q8mMd67nAyKauDS-Du1CQ5fxGL8ei3UoIMIjZm4aI0',
  'https://srmirwkdbcktvlyflvdi.supabase.co/storage/v1/object/sign/profile-pictures/defaults/avatar4.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2IyNjNiMmY4LThhZGEtNDRkNi04MjIyLTcxYTZiNDk3MTE2NyJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3R1cmVzL2RlZmF1bHRzL2F2YXRhcjQucG5nIiwiaWF0IjoxNzQ1ODI1MDc0LCJleHAiOjE3NzczNjEwNzR9.Y-4PnaIjPcxG4SSG-90TK-KW416oOvXiZY3NqVpQRmg',
  'https://srmirwkdbcktvlyflvdi.supabase.co/storage/v1/object/sign/profile-pictures/defaults/avatar5.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2IyNjNiMmY4LThhZGEtNDRkNi04MjIyLTcxYTZiNDk3MTE2NyJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3R1cmVzL2RlZmF1bHRzL2F2YXRhcjUucG5nIiwiaWF0IjoxNzQ1ODI0OTE1LCJleHAiOjE3NzczNjA5MTV9.So_HWptkKjIhWdcGExzWc8nloOJ3KYH05jIk-tAsLsk',
  'https://srmirwkdbcktvlyflvdi.supabase.co/storage/v1/object/sign/profile-pictures/defaults/avatar6.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5X2IyNjNiMmY4LThhZGEtNDRkNi04MjIyLTcxYTZiNDk3MTE2NyJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3R1cmVzL2RlZmF1bHRzL2F2YXRhcjYucG5nIiwiaWF0IjoxNzQ1ODI1MTM5LCJleHAiOjE3NzczNjExMzl9.DNCJHMQN7XolQ99t9RCrPZNcmuX4P41t8nBZGw7DbdM',
  // Add more URLs as needed
];
// Make sure these images exist at the specified URLs and the bucket policy allows public reads.

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>(); // For password change form

  bool _isLoading = true;
  // bool _isUploading = false; // REMOVED image upload loading state
  bool _isSavingPassword = false;
  bool _isSavingAvatar = false; // NEW: Loading state for saving avatar choice

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  String? _userId;
  String _email = '';
  String _fullName = '';
  String _phoneNo = '';
  String _registerNo = '';
  String _department = '';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _userId = _supabase.auth.currentUser?.id;
    _email = _supabase.auth.currentUser?.email ?? '';
    if (_userId != null) {
      _fetchProfile();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: User not found."),
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data =
          await _supabase
              .from('profiles')
              .select(
                'full_name, phone_no, register_no, department, avatar_url',
              )
              .eq('user_id', _userId!)
              .single();

      if (mounted) {
        setState(() {
          _fullName = (data['full_name'] ?? '').toString();
          _phoneNo = (data['phone_no'] ?? '').toString();
          _registerNo = (data['register_no'] ?? '').toString();
          _department = (data['department'] ?? '').toString();
          _avatarUrl = data['avatar_url']?.toString();
        });
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.code == 'PGRST116'
                  ? "Profile data not found."
                  : "Error fetching profile: ${error.message}",
            ),
            backgroundColor:
                error.code == 'PGRST116' ? Colors.orange : Colors.red,
          ),
        );
      }
      // Handle profile not found - maybe stay on page or redirect?
      print('Error fetching profile (Postgrest): ${error.message}');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Unexpected error fetching profile: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- REMOVED _uploadAvatar() function ---

  // --- NEW: Show Dialog for Avatar Selection ---
  Future<void> _showAvatarSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an Avatar'),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 10.0,
          ),
          content: SizedBox(
            width: double.maxFinite, // Use available width
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: predefinedAvatarUrls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Adjust columns as needed
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final url = predefinedAvatarUrls[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _updateSelectedAvatar(
                      url,
                    ); // Update and save the selected avatar
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(url),
                    // Optional: Add loading/error handling for grid images
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // --- NEW: Update and Save Selected Avatar ---
  Future<void> _updateSelectedAvatar(String newUrl) async {
    if (_userId == null) return; // Should not happen if logged in

    setState(() {
      _isSavingAvatar = true; // Show saving indicator on main avatar
      _avatarUrl = newUrl; // Update UI immediately
    });

    try {
      await _supabase
          .from('profiles')
          .update({'avatar_url': newUrl})
          .eq('user_id', _userId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Avatar updated!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      print('Error saving avatar: ${error.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update avatar: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
        // Optional: Revert _avatarUrl if save fails?
        // await _fetchProfile(); // Re-fetch to revert visual change
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAvatar = false; // Hide saving indicator
        });
      }
    }
  }

  // --- Change Password (Keep as is) ---
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New passwords do not match."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSavingPassword = true;
    });

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      }
    } on AuthException catch (error) {
      print('Password Change Error: ${error.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update password: ${error.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Unexpected Password Change Error: ${error.toString()}');
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
          _isSavingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme
    final colorScheme = theme.colorScheme; // Get color scheme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        leading:
            GoRouter.of(context).canPop()
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => GoRouter.of(context).pop(),
                )
                : null,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // --- Profile Header ---
                  Center(
                    child: Stack(
                      alignment: Alignment.center, // Center stack items
                      children: [
                        // --- Display current avatar or placeholder ---
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              colorScheme.secondaryContainer, // Use theme color
                          backgroundImage:
                              (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                  ? NetworkImage(_avatarUrl!)
                                  : null, // Or a placeholder AssetImage
                          child:
                              (_avatarUrl == null || _avatarUrl!.isEmpty)
                                  ? Icon(
                                    Icons.person_outline,
                                    size: 60,
                                    color:
                                        colorScheme
                                            .onSecondaryContainer, // Use theme color
                                  )
                                  : null,
                        ),
                        // --- Loading indicator while saving new avatar ---
                        if (_isSavingAvatar)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        // --- Button to open avatar selection ---
                        // Positioned slightly offset for better visibility
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 22, // Slightly larger circle
                            backgroundColor:
                                colorScheme.surface, // Contrasting background
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  colorScheme.primary, // Use theme color
                              child: IconButton(
                                tooltip: 'Choose Avatar',
                                icon: const Icon(
                                  Icons
                                      .collections_outlined, // Icon for selection
                                  color: Colors.white, // Use theme onPrimary
                                  size: 20,
                                ),
                                onPressed:
                                    _isSavingAvatar
                                        ? null
                                        : _showAvatarSelectionDialog, // Disable while saving
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _fullName.isNotEmpty ? _fullName : 'N/A',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ), // Use theme color
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Personal Information (Read-Only - Keep as is) ---
                  Text(
                    'Personal Information',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Divider(height: 20),
                  _buildReadOnlyInfoRow('Full Name:', _fullName),
                  _buildReadOnlyInfoRow('Email:', _email),
                  _buildReadOnlyInfoRow('Phone No:', _phoneNo),
                  _buildReadOnlyInfoRow('Register No:', _registerNo),
                  _buildReadOnlyInfoRow('Department:', _department),
                  const SizedBox(height: 30),

                  // --- Change Password Section (Keep as is, maybe style button) ---
                  Text('Change Password', style: theme.textTheme.titleLarge),
                  const Divider(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextFormField( // Current password - uncomment if needed by your RLS/Policies
                        //   controller: _currentPasswordController,
                        //   decoration: const InputDecoration(labelText: 'Enter current password', border: OutlineInputBorder()),
                        //   obscureText: true,
                        //   validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        // ),
                        // const SizedBox(height: 15),
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Enter new password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _confirmNewPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm new password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  colorScheme.primary, // Use theme color
                              foregroundColor:
                                  colorScheme.onPrimary, // Use theme color
                            ),
                            onPressed:
                                _isSavingPassword ? null : _changePassword,
                            child:
                                _isSavingPassword
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Save New Password'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
    );
  }

  // Helper widget for read-only info (Keep as is)
  Widget _buildReadOnlyInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ), // Use theme color
          ),
        ],
      ),
    );
  }
}
