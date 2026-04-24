import 'package:flutter/cupertino.dart';

import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/segmented_control.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String type = 'Bug';
  final controller = TextEditingController();
  int rating = 4;
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Feedback')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppSegmentedControl<String>(
              groupValue: type,
              children: const {
                'Bug': Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Bug'),
                ),
                'Ide': Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Ide'),
                ),
              },
              onValueChanged: (value) => setState(() => type = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                5,
                (index) => CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => rating = index + 1),
                  child: Icon(
                    index < rating
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: controller,
              maxLines: 5,
              placeholder: 'Ceritakan masukanmu...',
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: submitted
                  ? const Text('Terima kasih, feedback berhasil dikirim.')
                  : GlassButton(
                      label: 'Submit',
                      filled: true,
                      onPressed: () => setState(() => submitted = true),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
