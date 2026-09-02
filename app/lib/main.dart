import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/session.dart';
import 'data/repositories.dart';
import 'sync/sync_engine.dart';
import 'features/auth/auth_flow.dart';
import 'features/auth/pin_lock_screen.dart';
import 'features/shell/app_shell.dart';
import 'theme/stitch_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Repository.instance.session.load();
  runApp(const BillApp());
}

class BillApp extends StatelessWidget {
  const BillApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Repository.instance.session),
        ChangeNotifierProvider.value(value: SyncEngine.instance),
      ],
      child: MaterialApp(
        title: 'Stitch Bill',
        debugShowCheckedModeBanner: false,
        theme: buildStitchTheme(),
        home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});
  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    if (session.locked) return const PinLockScreen();
    if (session.businessId == null) return const AuthFlow();
    return const AppShell();
  }
}