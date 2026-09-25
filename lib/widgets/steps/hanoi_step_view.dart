import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/puzzle.dart';
import 'step_view.dart';

/// Joc de Hanoi: toca una agulla per agafar-ne el disc de dalt i una altra
/// per deixar-lo-hi.
class HanoiStepView extends StatefulWidget {
  const HanoiStepView({
    super.key,
    required this.step,
    required this.onSubmit,
    required this.onReject,
  });

  final HanoiStep step;
  final SubmitAnswer onSubmit;
  final RejectAction onReject;

  @override
  State<HanoiStepView> createState() => _HanoiStepViewState();
}

class _HanoiStepViewState extends State<HanoiStepView> {
  late List<List<int>> _pegs = widget.step.initial;
  final List<HanoiMove> _moves = [];
  int? _selected;

  void _reset() => setState(() {
    _pegs = widget.step.initial;
    _moves.clear();
    _selected = null;
  });

  void _tapPeg(int peg) {
    final from = _selected;
    if (from == null) {
      if (_pegs[peg].isNotEmpty) setState(() => _selected = peg);
      return;
    }
    if (from == peg) {
      setState(() => _selected = null);
      return;
    }
    final move = (from, peg);
    if (!HanoiStep.isLegal(_pegs, move)) {
      setState(() => _selected = null);
      widget.onReject('No pots posar un disc gran sobre un de més petit.');
      return;
    }
    setState(() {
      _pegs[peg].add(_pegs[from].removeLast());
      _moves.add(move);
      _selected = null;
    });
    if (widget.step.isDone(_pegs)) {
      final n = _moves.length;
      if (n == widget.step.minMoves) {
        widget.onSubmit(List<HanoiMove>.of(_moves));
      } else {
        widget.onReject(
          'Ho has aconseguit en $n; el mínim és 2ⁿ−1 = ${widget.step.minMoves}. '
          'Torna-ho a provar.',
        );
        _reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final discs = widget.step.discs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Moviments: ${_moves.length}  ·  mínim: ${widget.step.minMoves}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, box) {
            final pegWidth = box.maxWidth / 3;
            return Row(
              children: [
                for (var p = 0; p < 3; p++)
                  Semantics(
                    button: true,
                    label: 'Agulla ${p + 1}, ${_pegs[p].length} discos',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _tapPeg(p),
                      child: Container(
                        width: pegWidth,
                        height: 40.0 + discs * 22,
                        decoration: BoxDecoration(
                          color: _selected == p
                              ? AppColors.gold.withValues(alpha: 0.15)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 6,
                              color: AppColors.chalk.withValues(alpha: 0.4),
                            ),
                            Container(
                              height: 4,
                              color: AppColors.chalk.withValues(alpha: 0.4),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                for (final d in _pegs[p].reversed)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    height: 20,
                                    width:
                                        (pegWidth - 12) *
                                        (0.3 + 0.7 * d / discs),
                                    decoration: BoxDecoration(
                                      color: Color.lerp(
                                        AppColors.domino,
                                        AppColors.gold,
                                        d / discs,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(alignment: Alignment.center),
          onPressed: _moves.isEmpty ? null : _reset,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Torna a començar'),
        ),
      ],
    );
  }
}
