import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelance_project/auth/login.dart';
import 'package:freelance_project/providers/auth_provider.dart';
import 'package:freelance_project/providers/activities_provider.dart';
import 'package:freelance_project/dashboard/add_activity_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final activities = ref.watch(activitiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddActivitiesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User welcome section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: userData.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (data) => Text(
                'Welcome, ${data?['username'] ?? 'User'}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Activities list
          Expanded(
            child: activities.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (activitiesList) => ListView.builder(
                itemCount: activitiesList.length,
                itemBuilder: (context, index) {
                  final activity = activitiesList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: activity['userPhoto'] != null
                            ? NetworkImage(activity['userPhoto'])
                            : null,
                        child: activity['userPhoto'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(activity['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('By ${activity['username']}'),
                          Text('At ${activity['venue']}'),
                          Text(
                            'On ${DateFormat('MMM d, y - h:mm a').format(
                              DateTime.parse(activity['dateTime']),
                            )}',
                          ),
                          Text(
                              '${activity['minPeople']}-${activity['maxPeople']} people'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
