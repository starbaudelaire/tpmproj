import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../data/currency_remote_datasource.dart';
import 'widgets/currency_converter_view.dart';
import 'widgets/time_converter_view.dart';

final currencyRatesProvider = FutureProvider<Map<String, double>>(
  (ref) => CurrencyRemoteDataSource(dio: getIt(), prefs: getIt()).fetchRates(),
);

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  String mode = 'currency';

  @override
  Widget build(BuildContext context) {
    final rates = ref.watch(currencyRatesProvider);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Converter')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppSegmentedControl<String>(
              groupValue: mode,
              children: const {
                'currency': Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Currency'),
                ),
                'time': Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Time'),
                ),
              },
              onValueChanged: (value) => setState(() => mode = value),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: mode == 'currency'
                  ? rates.when(
                      data: (value) => CurrencyConverterView(rates: value),
                      loading: () => const CupertinoActivityIndicator(),
                      error: (_, __) =>
                          const Text('Data mungkin tidak terkini'),
                    )
                  : const TimeConverterView(),
            ),
          ],
        ),
      ),
    );
  }
}
