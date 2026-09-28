import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Pantalla d'introducció: el text s'escriu lletra a lletra i es pot saltar.
/// Es tanca (pop) quan el jugador prem «Endavant».
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.text});
  final String text;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  static const _tick = Duration(milliseconds: 28);
  Timer? _timer;
  int _shown = 0;

  bool get _done => _shown >= widget.text.length;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_tick, (_) {
      setState(() => _shown++);
      if (_done) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _skip() {
    _timer?.cancel();
    setState(() => _shown = widget.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _done ? null : _skip,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                  children: [
                    const Icon(
                      Icons.history_edu,
                      size: 48,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      // Els lectors de pantalla llegeixen el text sencer.
                      label: widget.text,
                      child: ExcludeSemantics(
                        child: Text(
                          widget.text.substring(
                            0,
                            _shown.clamp(0, widget.text.length),
                          ),
                          style: text.bodyLarge?.copyWith(
                            height: 1.5,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // El botó queda fix a baix: la intro és llarga.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _done
                    ? FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Endavant'),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.center,
                        ),
                        onPressed: _skip,
                        child: const Text('Salta'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
