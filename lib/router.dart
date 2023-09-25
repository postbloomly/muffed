import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/comment_screen/comment_screen.dart';
import 'package:muffed/community_screen/community_screen.dart';
import 'package:muffed/dynamic_navigation_bar/bloc/bloc.dart';
import 'package:muffed/dynamic_navigation_bar/dynamic_navigation_bar.dart';
import 'package:muffed/home_page/home_page.dart';
import 'package:muffed/inbox_page/inbox_page.dart';
import 'package:muffed/profile_page/login_page/login_page.dart';
import 'package:muffed/profile_page/profile_page.dart';
import 'package:muffed/repo/server_repo.dart';
import 'package:muffed/search_dialog/search_screen.dart';
import 'package:muffed/settings_page/content_filters/content_filters.dart';
import 'package:muffed/settings_page/defaults/defaults.dart';
import 'package:muffed/settings_page/settings_page.dart';
import 'package:muffed/settings_page/theme/theme.dart';
import 'package:muffed/user_screen/user_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      restorationScopeId: 'indexStack',
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return Scaffold(
          bottomNavigationBar: DynamicNavigationBar(
            onItemTapped: (index, currentContext) {
              if (index == navigationShell.currentIndex) {
                if (currentContext != null) {
                  if (currentContext.canPop()) {
                    Navigator.pop(currentContext);
                  }
                }
              } else {
                context
                    .read<DynamicNavigationBarBloc>()
                    .add(GoneToNewMainPage(index));

                navigationShell.goBranch(
                  index,
                  initialLocation: false,
                );
              }
            },
          ),
          body: navigationShell,
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) {
                return MaterialPage(child: HomePage());
              },
              routes: [
                GoRoute(
                  path: 'content',
                  builder: (context, state) {
                    return CommentScreen(state.extra as LemmyPost);
                  },
                ),
                GoRoute(
                  path: 'community',
                  builder: (context, state) {
                    return CommunityScreen(
                      communityId: int.parse(state.uri.queryParameters['id']!),
                    );
                  },
                ),
                GoRoute(
                  path: 'search',
                  builder: (context, state) {
                    return SearchScreen(
                      searchQuery: state.uri.queryParameters['query'],
                      //initialState: state.extra as SearchState?,
                    );
                  },
                ),
                GoRoute(
                  path: 'person',
                  builder: (context, state) {
                    return UserScreen(
                      userId: (state.uri.queryParameters['id'] != null)
                          ? int.parse(state.uri.queryParameters['id']!)
                          : null,
                      username: state.uri.queryParameters['username'],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/inbox',
              pageBuilder: (context, state) {
                return const MaterialPage(child: InboxPage());
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) {
                return const ProfilePage();
              },
              routes: [
                GoRoute(
                  path: 'login',
                  builder: (context, state) {
                    return LoginPage();
                  },
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) {
                    return SettingsPage();
                  },
                  routes: [
                    GoRoute(
                      path: 'look',
                      builder: (context, state) {
                        return const SettingsThemePage();
                      },
                    ),
                    GoRoute(
                        path: 'contentfilters',
                        builder: (context, state) {
                          return const ContentFiltersPage();
                        }),
                    GoRoute(
                      path: 'defaults',
                      builder: (context, state) {
                        return const DefaultsSettingsPage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
