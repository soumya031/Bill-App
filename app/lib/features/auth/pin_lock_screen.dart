import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session.dart';
import '../../theme/stitch_theme.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});
  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String pin = '';
  bool get _full => pin.length == 4;

  void _press(String digit) {
    if (_full) return;
    setState(() => pin += digit);
    if (_full) {
      Future.delayed(const Duration(milliseconds: 150), () async {
        if (!mounted) return;
        final session = context.read<Session>();
        if (session.verifyPin(pin)) {
          session.unlock();
        } else {
          if (mounted) {
            setState(() => pin = '');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Wrong PIN'), backgroundColor: StitchColors.error));
          }
        }
      });
    }
  }

  void _back() {
    if (pin.isEmpty) return;
    setState(() => pin = pin.substring(0, pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: StitchColors.primary, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.lock_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 18),
            const Text('App locked', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Enter your PIN to continue',
                style: TextStyle(color: StitchColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? StitchColors.primary : Colors.transparent,
                    border: Border.all(color: filled ? StitchColors.primary : StitchColors.outlineStrong, width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 36),
            _padRow(['1', '2', '3']),
            _padRow(['4', '5', '6']),
            _padRow(['7', '8', '9']),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Row(children: [
                const Spacer(),
                _padKey('0'),
                const Spacer(),
                _backKey(),
                const Spacer(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _padRow(List<String> keys) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: keys.map((k) => _padKey(k)).toList()),
      );

  Widget _padKey(String digit) => InkWell(
        onTap: () => _press(digit),
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Center(
            child: Text(digit,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          ),
        ),
      );

  Widget _backKey() => InkWell(
        onTap: _back,
        borderRadius: BorderRadius.circular(24),
        child: const SizedBox(
          width: 72,
          height: 72,
          child: Center(child: Icon(Icons.backspace_outlined, color: StitchColors.textSecondary, size: 24)),
        ),
      );
}