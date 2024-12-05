import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelance_project/dashboard/home.dart';

class AddActivitiesScreen extends ConsumerStatefulWidget {
  const AddActivitiesScreen({super.key});

  @override
  ConsumerState<AddActivitiesScreen> createState() =>
      _AddActivitiesScreenState();
}

class _AddActivitiesScreenState extends ConsumerState<AddActivitiesScreen> {
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _guysController = TextEditingController();
  final _ladiesController = TextEditingController();
  DateTime? selectedDateTime;
  bool isCourtBooked = false;
  bool isPayBeforeJoin = false;
  bool isRestrictBySkillLevel = false;
  int minPeople = 2;
  int maxPeople = 5;
  String selectedSkillLevel = 'Intermediate';
  String selectedGameType = 'Single';
  String selectedActivityType = 'Social';
  bool _isLoading = false;

  Future<void> _saveActivity() async {
    if (_titleController.text.isEmpty ||
        _venueController.text.isEmpty ||
        selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('activities').add({
        'userId': user.uid,
        'username': user.displayName ?? 'Anonymous',
        'userPhoto': user.photoURL,
        'title': _titleController.text,
        'dateTime': selectedDateTime!.toIso8601String(),
        'venue': _venueController.text,
        'minPeople': minPeople,
        'maxPeople': maxPeople,
        'guysFee': double.tryParse(_guysController.text) ?? 0,
        'ladiesFee': double.tryParse(_ladiesController.text) ?? 0,
        'isCourtBooked': isCourtBooked,
        'isPayBeforeJoin': isPayBeforeJoin,
        'isRestrictBySkillLevel': isRestrictBySkillLevel,
        'skillLevel': selectedSkillLevel,
        'gameType': selectedGameType,
        'activityType': selectedActivityType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Activities'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveActivity,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title*',
                prefixIcon: Icon(Icons.list),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date & Time*',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDateTime != null
                      ? selectedDateTime!.toString()
                      : 'Select Date and Time',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue*',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildNumberField('Min people', minPeople),
                const SizedBox(width: 16), // Spacing between fields
                _buildNumberField('Max people', maxPeople),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _guysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Guys RM',
                      prefixIcon: Icon(Icons.male),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _ladiesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ladies RM',
                      prefixIcon: Icon(Icons.female),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitch('Court booked', isCourtBooked, (value) {
              setState(() {
                isCourtBooked = value;
              });
            }),
            _buildSwitch('Pay before join', isPayBeforeJoin, (value) {
              setState(() {
                isPayBeforeJoin = value;
              });
            }),
            _buildSwitch('Restrict by skill level', isRestrictBySkillLevel,
                (value) {
              setState(() {
                isRestrictBySkillLevel = value;
              });
            }),
            const SizedBox(height: 16),
            _buildSkillLevelButtons(),
            const SizedBox(height: 16),
            _buildGameTypeButtons(),
            const SizedBox(height: 16),
            _buildActivityTypeButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, int initialValue) {
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            if (label == 'Min people') {
              minPeople = int.tryParse(value) ?? initialValue;
            } else {
              maxPeople = int.tryParse(value) ?? initialValue;
            }
          });
        },
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildSkillLevelButtons() {
    return Wrap(
      spacing: 8,
      children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
        final isSelected = selectedSkillLevel == level;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedSkillLevel = level;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          child: Text(level),
        );
      }).toList(),
    );
  }

  Widget _buildGameTypeButtons() {
    return Wrap(
      spacing: 8,
      children: ['Single', 'Double', 'Social'].map((type) {
        final isSelected = selectedGameType == type;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedGameType = type;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          child: Text(type),
        );
      }).toList(),
    );
  }

  Widget _buildActivityTypeButtons() {
    return Wrap(
      spacing: 8,
      children: ['Social', 'Training', 'Competition'].map((type) {
        final isSelected = selectedActivityType == type;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedActivityType = type;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : null,
            foregroundColor: isSelected ? Colors.white : null,
          ),
          child: Text(type),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _guysController.dispose();
    _ladiesController.dispose();
    super.dispose();
  }
}
