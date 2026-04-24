import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/glass_card.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0x22FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.person_fill),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: const Icon(CupertinoIcons.pencil),
          ),
        ],
      ),
    );
  }
}
