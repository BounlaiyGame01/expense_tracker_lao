import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'screens/root_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'Expense Tracker Lao',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppLoader(),
      ),
    );
  }
}

/// Shows a simple splash/loading state while the app connects to MySQL and
/// loads categories, then hands off to RootScreen. If the connection fails,
/// shows the actual error instead of spinning forever.
class _AppLoader extends StatelessWidget {
  const _AppLoader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, color: AppColors.expense, size: 56),
                const SizedBox(height: 16),
                const Text('Could not connect to the database',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.read<AppState>().init(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.primaryBlue, size: 56),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppColors.primaryBlue),
            ],
          ),
        ),
      );
    }
    return const RootScreen();
  }
}
