import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/membership_provider.dart';

class GoldGuard extends StatelessWidget {
  final Widget child;
  final String featureName;

  const GoldGuard({
    super.key,
    required this.child,
    this.featureName = "This feature",
  });

  @override
  Widget build(BuildContext context) {
    final membership = context.watch<MembershipProvider>();

    if (membership.isActive) {
      return child;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: Column(
        children: [
          const Icon(Icons.lock, size: 32),
          const SizedBox(height: 8),
          Text("$featureName requires Gold Membership"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/membership");
            },
            child: const Text("Upgrade to Gold"),
          ),
        ],
      ),
    );
  }
}
