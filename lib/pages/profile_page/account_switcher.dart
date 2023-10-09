import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/global_state/bloc.dart';

/// Shows a bottom dialog that allows a user to switch accounts
void showAccountSwitcher(BuildContext context) {
  final globalBloc = context.read<GlobalBloc>();
  showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    builder: (context) {
      return BlocBuilder<GlobalBloc, GlobalState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...List.generate(state.lemmyAccounts.length, (index) {
                return ListTile(
                  selected: state.lemmySelectedAccount == index,
                  title: Text(
                    state.lemmyAccounts[index].userName,
                  ),
                  leading: const Icon(Icons.account_circle),
                  trailing: IconButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirm Removal'),
                            content: Text(
                                'Are you sure you want to remove ${globalBloc.state.lemmyAccounts[index].userName}'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  globalBloc.add(
                                    UserRequestsAccountRemoval(
                                      index,
                                    ),
                                  );
                                  context.pop();
                                },
                                child: const Text('Remove'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.remove_circle),
                  ),
                  onTap: () {
                    context.pop();
                    globalBloc.add(
                      UserRequestsLemmyAccountSwitch(
                        index,
                      ),
                    );
                  },
                );
              }),
              ListTile(
                title: const Text('Anonymous'),
                selected: !globalBloc.isLoggedIn(),
                leading: const Icon(Icons.security),
                onTap: () {
                  context.pop();
                  globalBloc.add(
                    UserRequestsLemmyAccountSwitch(-1),
                  );
                },
              ),
              ListTile(
                title: const Text('Add Account'),
                leading: const Icon(Icons.add),
                onTap: () {
                  context
                    ..pop()
                    ..go('/profile/login');
                },
              ),
            ],
          );
        },
      );
    },
  );
}