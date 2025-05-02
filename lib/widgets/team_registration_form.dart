// lib/widgets/team_registration_form.dart
import 'package:flutter/material.dart';
import '../models/event.dart';
// Import Supabase client/service if needed for validation/submission later
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../services/supabase_service.dart';

class TeamRegistrationForm extends StatefulWidget {
  final Event event;

  const TeamRegistrationForm({required this.event, super.key});

  @override
  State<TeamRegistrationForm> createState() => _TeamRegistrationFormState();
}

class _TeamRegistrationFormState extends State<TeamRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  // Store controllers for member fields
  late List<TextEditingController> _memberControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with minimum required member fields + current user
    // Assuming current user is always the first member/leader
    _memberControllers = List.generate(
      widget.event.minTeamSize, // Start with minimum members
      (index) => TextEditingController(),
    );
    // TODO: Pre-fill first controller with current user's details (e.g., regNo) if possible/needed
    // final currentUserRegNo = Supabase.instance.client.auth.currentUser?.userMetadata?['register_no'];
    // if (currentUserRegNo != null && _memberControllers.isNotEmpty) {
    //   _memberControllers[0].text = currentUserRegNo;
    // }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- Dynamic Member Field Management ---
  void _addMemberField() {
    if (_memberControllers.length < widget.event.maxTeamSize) {
      setState(() {
        _memberControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum team size is ${widget.event.maxTeamSize}'),
        ),
      );
    }
  }

  void _removeMemberField(int index) {
    // Prevent removing below minimum or the first field (leader/current user)
    if (_memberControllers.length > widget.event.minTeamSize && index > 0) {
      // Make sure to dispose the controller being removed
      final removedController = _memberControllers.removeAt(index);
      removedController.dispose();
      setState(() {});
    } else if (index == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot remove the team leader.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum team size is ${widget.event.minTeamSize}'),
        ),
      );
    }
  }

  // --- Form Submission Logic ---
  Future<void> _submitTeamRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }

    setState(() {
      _isLoading = true;
    });

    final teamName = _teamNameController.text.trim();
    final memberDetails =
        _memberControllers
            .map((controller) => controller.text.trim())
            .where((detail) => detail.isNotEmpty) // Only non-empty details
            .toList();

    print('--- Submitting Team Registration ---');
    print('Event ID: ${widget.event.id}');
    print('Team Name: $teamName');
    print('Members: $memberDetails');

    // --- TODO: Backend Integration ---
    // 1. Define Supabase Tables:
    //    - `teams` (team_id PK, event_id FK, team_name, created_at, created_by_user_id FK)
    //    //    - `team_members` (id PK, team_id FK, user_id FK or member_identifier TEXT)
    // 2. Create SupabaseService Method:
    //    `Future<void> registerTeamForEvent(String eventId, String teamName, List<String> memberIdentifiers)`
    //    - This method should:
    //      - Check if team name is unique for the event (optional).
    //      - Create a row in the `teams` table.
    //      - Validate member identifiers (e.g., check if regNo/email exists in `profiles`).
    //      - Create rows in `team_members` table linking users/identifiers to the new team_id.
    //      - Handle potential errors (duplicate team name, invalid members, registration limit reached).
    // 3. Call the service method here:
    try {
      // Placeholder for backend call simulation
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call

      // --- Example call (uncomment and implement service method) ---
      // final userId = Supabase.instance.client.auth.currentUser!.id;
      // await SupabaseService().registerTeamForEvent(widget.event.id, teamName, memberDetails, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Team "$teamName" registered successfully! (Backend TODO)',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the bottom sheet/dialog on success

        // TODO: Optionally update MyEventsNotifier or trigger a data refresh
        // Provider.of<MyEventsNotifier>(context, listen: false).registerEvent(widget.event); // Simple version
      }
    } catch (e) {
      print('Error during team registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
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
    // --- End Backend Integration Placeholder ---
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      // Padding for content inside the modal sheet
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        // Adjust bottom padding to avoid keyboard overlap
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Allow content to scroll if keyboard appears
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fit content vertically
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Team Registration: ${widget.event.eventName}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Team Size: ${widget.event.minTeamSize} - ${widget.event.maxTeamSize} members',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Team Name
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group_work),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a team name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Team Members Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Team Members (${_memberControllers.length})',
                    style: theme.textTheme.titleMedium,
                  ),
                  // Only show Add button if max size not reached
                  if (_memberControllers.length < widget.event.maxTeamSize)
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Add Member',
                      onPressed: _addMemberField,
                    ),
                ],
              ),
              const Divider(),

              // Dynamic Member Fields List
              ListView.builder(
                shrinkWrap: true, // Important inside SingleChildScrollView
                physics:
                    const NeverScrollableScrollPhysics(), // List shouldn't scroll independently here
                itemCount: _memberControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _memberControllers[index],
                            // Disable first field if pre-filled with current user
                            // readOnly: index == 0 && _memberControllers[0].text.isNotEmpty,
                            decoration: InputDecoration(
                              labelText: 'Member ${index + 1} (Reg No / Email)',
                              // Hint text or prefix icon if needed
                              // prefixIcon: Icon(Icons.person_outline),
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ), // Adjust padding
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter member ${index + 1} details';
                              }
                              // TODO: Add more specific validation (RegNo format, email format?)
                              return null;
                            },
                          ),
                        ),
                        // Show Remove button only if allowed
                        if (_memberControllers.length >
                                widget.event.minTeamSize &&
                            index > 0)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Remove Member',
                            onPressed: () => _removeMemberField(index),
                          ),
                        // Add SizedBox if remove button isn't shown, to maintain alignment
                        if (!(_memberControllers.length >
                                widget.event.minTeamSize &&
                            index > 0))
                          const SizedBox(width: 48), // Width of an IconButton
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _submitTeamRegistration,
                    child: const Text('Register Team'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
