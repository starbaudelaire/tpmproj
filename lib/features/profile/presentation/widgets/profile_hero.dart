import 'package:flutter/cupertino.dart';

import '../../../../shared/widgets/glass_card.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
    required this.name,
    required this.email,
    super.key,
  });

  final String name;
  final String email;

  void _showEditInfo(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Edit profil'),
        message: const Text(
          'Untuk demo TPM, foto profil ditampilkan sebagai avatar lokal. Upload foto bisa ditambahkan pada tahap polish berikutnya.',
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'J' : name.trim()[0].toUpperCase();

    return GlassCard(
      borderRadius: 26,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.systemOrange,
                  CupertinoColors.systemPurple,
                ],
              ),
              border: Border.all(
                color: CupertinoColors.white.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: Text(
              initial,
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navLargeTitleTextStyle
                  .copyWith(
                    color: CupertinoColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.trim().isEmpty ? 'Penjelajah Jogja' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .navTitleTextStyle
                      .copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.trim().isEmpty ? 'Local session active' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            color: CupertinoColors.systemGrey,
                            fontSize: 13,
                          ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure local account • Hive + SecureStorage',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            color: CupertinoColors.systemGrey2,
                            fontSize: 11,
                          ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(42, 42),
            onPressed: () => _showEditInfo(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withOpacity(0.08),
              ),
              child: const Icon(
                CupertinoIcons.pencil,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
