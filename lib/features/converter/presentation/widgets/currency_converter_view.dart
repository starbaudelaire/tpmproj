import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyConverterView extends ConsumerStatefulWidget {
  const CurrencyConverterView({required this.rates, super.key});

  final Map<String, double> rates;

  @override
  ConsumerState<CurrencyConverterView> createState() =>
      _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends ConsumerState<CurrencyConverterView> {
  final _controller = TextEditingController(text: '1');
  String from = 'USD';
  String to = 'IDR';

  @override
  Widget build(BuildContext context) {
    final input = double.tryParse(_controller.text) ?? 0;
    final result = input / widget.rates[from]! * widget.rates[to]!;
    return Column(
      children: [
        CupertinoTextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    setState(() => from = from == 'USD' ? 'IDR' : 'USD'),
                child: Text(from),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() {
                final previous = from;
                from = to;
                to = previous;
              }),
              child: const Icon(CupertinoIcons.arrow_2_circlepath),
            ),
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    setState(() => to = to == 'EUR' ? 'IDR' : 'EUR'),
                child: Text(to),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(result.toStringAsFixed(2)),
      ],
    );
  }
}
