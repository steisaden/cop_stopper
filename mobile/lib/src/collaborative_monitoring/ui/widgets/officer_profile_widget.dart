import 'package:flutter/material.dart';
import 'package:mobile/src/collaborative_monitoring/models/officer_profile.dart';

class OfficerProfileWidget extends StatelessWidget {
  final OfficerProfile officerProfile;

  const OfficerProfileWidget({Key? key, required this.officerProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${officerProfile.name}'),
          Text('Badge Number: ${officerProfile.badgeNumber}'),
          Text('Department: ${officerProfile.department}'),
          const SizedBox(height: 16),
          const Text('Encounters:'),
          if (officerProfile.encounters.isEmpty)
            const Text('No encounters reported yet.')
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: officerProfile.encounters.length,
              itemBuilder: (context, index) {
                final encounter = officerProfile.encounters[index];
                return ListTile(
                  title: Text(encounter.description),
                  subtitle: Text(encounter.date.toString()),
                );
              },
            ),
        ],
      ),
    );
  }
}
