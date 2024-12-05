import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelance_project/dashboard/home.dart';

class Activities extends ConsumerStatefulWidget {
  const Activities({super.key});

  @override
  ConsumerState<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends ConsumerState<Activities> {
  final List<Map<String, dynamic>> popularSports = [
    {'name': 'Football', 'icon': Icons.sports_soccer},
    {'name': 'Badminton', 'icon': Icons.sports_tennis},
    {'name': 'Table Tennis', 'icon': Icons.sports_tennis},
    {'name': 'Basketball', 'icon': Icons.sports_basketball},
    {'name': 'Cricket', 'icon': Icons.sports_cricket},
    {'name': 'Volleyball', 'icon': Icons.sports_volleyball},
  ];

  final Set<String> selectedSports = {};
  bool _isLoading = false;

  Future<void> _saveActivities() async {
    if (selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one sport')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Save each selected sport as an activity
      for (final sport in selectedSports) {
        await FirebaseFirestore.instance.collection('activities').add({
          'userId': user.uid,
          'username': user.displayName ?? 'Anonymous',
          'userPhoto': user.photoURL,
          'sport': sport,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What Sports do you play?'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveActivities,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text(
                    'Next',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a sport',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular Sports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: popularSports.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final sport = popularSports[index];
                  final isSelected = selectedSports.contains(sport['name']);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedSports.remove(sport['name']);
                        } else {
                          selectedSports.add(sport['name']);
                        }
                      });
                    },
                    child: Card(
                      elevation: 2,
                      color: isSelected ? Colors.blue.shade100 : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: isSelected
                            ? const BorderSide(color: Colors.blue, width: 2)
                            : BorderSide.none,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            sport['icon'],
                            size: 40,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sport['name'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.blue : null,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
