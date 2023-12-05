import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:muffed/router/router.dart';
import 'package:muffed/theme/theme.dart';

final _log = Logger('NavigationBarItem');

class NavigationBarItem extends StatelessWidget {
  const NavigationBarItem({
    required this.relatedBranchIndex,
    required this.icon,
    IconData? selectedIcon,
    super.key,
  }) : selectedIcon = selectedIcon ?? icon;

  final IconData icon;
  final IconData selectedIcon;
  final int relatedBranchIndex;

  @override
  Widget build(BuildContext context) {
    final MNavigator navigator = MNavigator.of(context);

    return BlocBuilder<MNavigator, MNavigatorState>(
      builder: (context, state) {
        return Material(
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              IconButton(
                isSelected: MNavigator.of(context).state.currentBranchIndex ==
                    relatedBranchIndex,
                selectedIcon: Icon(
                  selectedIcon,
                  color: context.colorScheme.primary,
                ),
                icon: Icon(icon),
                onPressed: () {
                  _log.info('Branch $relatedBranchIndex pressed');
                  if (MNavigator.of(context).state.currentBranchIndex !=
                      relatedBranchIndex) {
                    _log.info('Switching to branch $relatedBranchIndex');
                    context.switchBranch(relatedBranchIndex);
                  } else if (MNavigator.of(context).state.canPop) {
                    _log.info('Popping branch $relatedBranchIndex');
                    context.pop();
                  }
                },
                visualDensity: VisualDensity.compact,
              ),
              _NavigationBarItemActions(
                pageActions: navigator
                    .state.branches[relatedBranchIndex].top.pageActions,
                showActions: MNavigator.of(context).state.currentBranchIndex ==
                    relatedBranchIndex,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavigationBarItemActions extends StatelessWidget {
  const _NavigationBarItemActions({this.pageActions, this.showActions = false});

  final PageActions? pageActions;
  final bool showActions;

  static const _animDur = Duration(milliseconds: 500);
  static const _animCurve = Curves.easeOutCubic;
  static const _animInterval = 200;

  List<Widget> attachAnimations(List<Widget> widgets) => List.generate(
        widgets.length,
        (index) => widgets[index]
            .animate(autoPlay: true)
            .slideY(
              duration: _animDur,
              curve: _animCurve,
              begin: 3,
              delay: Duration(milliseconds: _animInterval * index),
              end: 0,
            )
            .fadeIn(
              duration: _animDur,
              begin: 0,
              curve: _animCurve,
              delay: Duration(milliseconds: _animInterval * index),
            ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _animDur,
      alignment: Alignment.centerLeft,
      curve: Curves.easeInOutCubic,
      child: IntrinsicHeight(
        child: Builder(
          builder: (context) {
            if (showActions && pageActions != null) {
              return ListenableBuilder(
                listenable: pageActions!,
                builder: (context, child) {
                  return Row(
                    children: [
                      if (pageActions!.actions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            width: 2,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ).animate().fade(
                              duration: _animDur,
                              curve: _animCurve,
                              begin: 0,
                            ),
                      ...attachAnimations(pageActions!.actions),
                    ],
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
