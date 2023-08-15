import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/components/popup_menu/popup_menu.dart';
import 'package:muffed/components/snackbars.dart';
import 'package:muffed/content_view/post_view/card.dart';
import 'package:muffed/dynamic_navigation_bar/dynamic_navigation_bar.dart';
import 'package:muffed/repo/server_repo.dart';
import 'package:muffed/utils/time.dart';

import 'bloc/bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.searchQuery, this.initialState});

  final String? searchQuery;

  final SearchState? initialState;

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(
      text: searchQuery,
    );

    final communitiesScrollController = ScrollController();
    final personsScrollController = ScrollController();
    final postsScrollController = ScrollController();
    final commentsScrollController = ScrollController();

    return BlocProvider(
      create: (context) {
        // if search query if not null or empty add search query changed event
        // in order to search for the search query
        if (searchQuery != null && searchQuery != '') {
          return SearchBloc(
            repo: context.read<ServerRepo>(),
            initialState: initialState,
          )..add(SearchQueryChanged(searchQuery: searchQuery!));
        } else {
          return SearchBloc(
            repo: context.read<ServerRepo>(),
            initialState: initialState,
          );
        }
      },
      child: BlocConsumer<SearchBloc, SearchState>(
        listenWhen: (previous, current) {
          if (previous.loadedSortType != current.loadedSortType ||
              previous.loadedSearchQuery != current.loadedSearchQuery) {
            try {
              communitiesScrollController.jumpTo(0);
              personsScrollController.jumpTo(0);
              postsScrollController.jumpTo(0);
            } catch (err) {}
          }

          if (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          showErrorSnackBar(context, text: state.errorMessage!);
        },
        builder: (context, state) {
          /// Used to tell weather the search bar is focused or not
          final textFocusNode = FocusNode();

          final blocContext = context;

          return SetPageInfo(
            indexOfRelevantItem: 0,
            actions: [
              MuffedPopupMenuButton(
                icon: Icon(Icons.sort),
                items: [
                  BlocProvider.value(
                    value: BlocProvider.of<SearchBloc>(blocContext),
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        return MuffedPopupMenuItem(
                          title: 'Hot',
                          isSelected: state.sortType == LemmySortType.hot,
                          onTap: () => context.read<SearchBloc>().add(
                                SortTypeChanged(
                                  LemmySortType.hot,
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<SearchBloc>(blocContext),
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        return MuffedPopupMenuItem(
                          title: 'Active',
                          isSelected: state.sortType == LemmySortType.active,
                          onTap: () => context.read<SearchBloc>().add(
                                SortTypeChanged(
                                  LemmySortType.active,
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<SearchBloc>(blocContext),
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        return MuffedPopupMenuItem(
                          title: 'Latest',
                          isSelected: state.sortType == LemmySortType.latest,
                          onTap: () => context.read<SearchBloc>().add(
                                SortTypeChanged(
                                  LemmySortType.latest,
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<SearchBloc>(blocContext),
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        return MuffedPopupMenuItem(
                          title: 'Old',
                          isSelected: state.sortType == LemmySortType.old,
                          onTap: () => context.read<SearchBloc>().add(
                                SortTypeChanged(
                                  LemmySortType.old,
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<SearchBloc>(blocContext),
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        return MuffedPopupMenuExpandableItem(
                          title: 'Top',
                          isSelected: state.sortType == LemmySortType.topAll ||
                              state.sortType == LemmySortType.topDay ||
                              state.sortType == LemmySortType.topHour ||
                              state.sortType == LemmySortType.topMonth ||
                              state.sortType == LemmySortType.topSixHour ||
                              state.sortType == LemmySortType.topTwelveHour ||
                              state.sortType == LemmySortType.topWeek ||
                              state.sortType == LemmySortType.topYear,
                          items: [
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'All Time',
                                    isSelected:
                                        state.sortType == LemmySortType.topAll,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topAll,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Year',
                                    isSelected:
                                        state.sortType == LemmySortType.topYear,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topYear,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Month',
                                    isSelected: state.sortType ==
                                        LemmySortType.topMonth,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topMonth,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Week',
                                    isSelected:
                                        state.sortType == LemmySortType.topWeek,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topWeek,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Day',
                                    isSelected:
                                        state.sortType == LemmySortType.topDay,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topDay,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Twelve Hours',
                                    isSelected: state.sortType ==
                                        LemmySortType.topTwelveHour,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topTwelveHour,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Six Hours',
                                    isSelected: state.sortType ==
                                        LemmySortType.topSixHour,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topSixHour,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Hour',
                                    isSelected:
                                        state.sortType == LemmySortType.topHour,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.topHour,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<SearchBloc>(blocContext),
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        return MuffedPopupMenuExpandableItem(
                          title: 'Comments',
                          isSelected:
                              state.sortType == LemmySortType.mostComments ||
                                  state.sortType == LemmySortType.newComments,
                          items: [
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(blocContext),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'Most Comments',
                                    isSelected: state.sortType ==
                                        LemmySortType.mostComments,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.mostComments,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                            BlocProvider.value(
                              value: BlocProvider.of<SearchBloc>(
                                blocContext,
                              ),
                              child: BlocBuilder<SearchBloc, SearchState>(
                                builder: (context, state) {
                                  return MuffedPopupMenuItem(
                                    title: 'New Comments',
                                    isSelected: state.sortType ==
                                        LemmySortType.newComments,
                                    onTap: () => context.read<SearchBloc>().add(
                                          SortTypeChanged(
                                            LemmySortType.newComments,
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
            child: Scaffold(
              body: SafeArea(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(
                            text: 'Communities',
                          ),
                          Tab(
                            text: 'People',
                          ),
                          Tab(
                            text: 'Posts',
                          ),
                          Tab(
                            text: 'Comments',
                          ),
                        ],
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            NotificationListener(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo.metrics.pixels >=
                                    scrollInfo.metrics.maxScrollExtent - 50) {
                                  context.read<SearchBloc>().add(
                                        ReachedNearEndOfPage(),
                                      );
                                }
                                return true;
                              },
                              child: TabBarView(
                                children: [
                                  // communities
                                  ListView.builder(
                                    controller: communitiesScrollController,
                                    itemCount: state.communities.length,
                                    itemBuilder: (context, index) {
                                      return _LemmyCommunityCard(
                                        community: state.communities[index],
                                      );
                                    },
                                  ),
                                  ListView.builder(
                                    controller: personsScrollController,
                                    itemCount: state.persons.length,
                                    itemBuilder: (context, index) {
                                      return _LemmyPersonCard(
                                        person: state.persons[index],
                                      );
                                    },
                                  ),
                                  // posts
                                  ListView.builder(
                                    controller: postsScrollController,
                                    itemCount: state.posts.length,
                                    itemBuilder: (context, index) {
                                      return CardLemmyPostItem(
                                        state.posts[index],
                                      );
                                    },
                                  ),

                                  Placeholder(),
                                ],
                              ),
                            ),
                            if (state.isLoading)
                              const Align(
                                alignment: Alignment.topCenter,
                                child: LinearProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                      TextField(
                        focusNode: textFocusNode,
                        controller: textController,
                        onChanged: (query) {
                          context.read<SearchBloc>().add(
                                SearchQueryChanged(
                                  searchQuery: query,
                                ),
                              );
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.search),
                          ),
                          prefixIcon: IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                if (textFocusNode.hasFocus) {
                                  textFocusNode.unfocus();
                                } else {
                                  context.pop();
                                }
                              },
                              icon: Icon(Icons.arrow_back)),
                          hintText: 'Search',
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LemmyCommunityCard extends StatelessWidget {
  const _LemmyCommunityCard({super.key, required this.community});

  final LemmyCommunity community;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          context.push('/home/community?id=${community.id}');
        },
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            image: (community.banner != null)
                ? DecorationImage(
                    image: CachedNetworkImageProvider(
                      community.banner!,
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.5,
                  )
                : null,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: (community.icon != null)
                          ? CachedNetworkImage(imageUrl: community.icon!)
                          : SvgPicture.asset(
                              'assets/logo.svg',
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Flexible(
                    child: Text(
                      community.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: Text('Age'),
                    value: Text(formattedPostedAgo(community.published)),
                  ),
                  _InfoChip(
                    label: Text('Posts'),
                    value: Text(community.posts.toString()),
                  ),
                  _InfoChip(
                    label: Text('Subscribers'),
                    value: Text(community.subscribers.toString()),
                  ),
                  _InfoChip(
                    label: Text('Hot Rank'),
                    value: Text(community.hotRank.toString()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LemmyPersonCard extends StatelessWidget {
  const _LemmyPersonCard({required this.person, super.key});

  final LemmyPerson person;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            image: (person.banner != null)
                ? DecorationImage(
                    image: CachedNetworkImageProvider(
                      person.banner!,
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.5,
                  )
                : null,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: (person.avatar != null)
                          ? CachedNetworkImage(imageUrl: person.avatar!)
                          : SvgPicture.asset(
                              'assets/logo.svg',
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Flexible(
                    child: Text(
                      person.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: Text('Age'),
                    value: Text(formattedPostedAgo(person.published)),
                  ),
                  _InfoChip(
                    label: Text('Post Score'),
                    value: Text(person.postScore.toString()),
                  ),
                  _InfoChip(
                    label: Text('Comment Score'),
                    value: Text(person.commentScore.toString()),
                  ),
                  _InfoChip(
                    label: Text('Post Count'),
                    value: Text(person.postCount.toString()),
                  ),
                  _InfoChip(
                    label: Text('Comment Count'),
                    value: Text(person.commentCount.toString()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    super.key,
    required this.label,
    required this.value,
  });

  final Widget label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      elevation: 2,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.labelMedium!,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: label,
            ),
            Container(
              //color: Theme.of(context).colorScheme.outline,
              width: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: value,
            ),
          ],
        ),
      ),
    );
  }
}
