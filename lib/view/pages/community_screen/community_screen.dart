import 'package:equatable/equatable.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:muffed/domain/global_state/bloc.dart';
import 'package:muffed/domain/server_repo.dart';
import 'package:muffed/shorthands.dart';
import 'package:muffed/view/pages/community_screen/bloc/bloc.dart';
import 'package:muffed/view/pages/community_screen/community_info_screen.dart';
import 'package:muffed/view/widgets/content_scroll_view/bloc/bloc.dart';
import 'package:muffed/view/widgets/content_scroll_view/content_scroll_view.dart';
import 'package:muffed/view/widgets/image.dart';
import 'package:muffed/view/widgets/markdown_body.dart';
import 'package:muffed/view/widgets/muffed_avatar.dart';
import 'package:muffed/view/widgets/muffed_page.dart';
import 'package:muffed/view/widgets/popup_menu/popup_menu.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Defines the community screen and parameters in go router
class CommunityScreenRouterDefinition extends GoRoute {
  CommunityScreenRouterDefinition({super.routes})
      : super(
          name: 'communityScreen',
          path: 'communityScreen',
          builder: (context, state) {
            final qp = state.uri.queryParameters;

            final communityId = qp['communityId']?.parseInt();
            final communityName = state.uri.queryParameters['communityName'];

            final data = state.extra! as CommunityScreenRouter;
            return CommunityScreen(
              communityId: communityId,
              communityName: communityName,
              community: data.community,
            );
          },
        );
}

/// Provides a clean and typed interface for navigating to the community screen
class CommunityScreenRouter extends CommunityScreenRouterDefinition {
  CommunityScreenRouter({
    this.communityId,
    this.communityName,
    this.community,
  })  : assert(
          communityId != null || communityName != null || community != null,
          'No community defined.',
        ),
        super();

  void go(BuildContext context) {
    context.goNamed(
      super.name!,
      queryParameters: {
        if (communityId != null) 'communityId': communityId.toString(),
        if (communityName != null) 'communityName': communityName,
      },
      extra: this,
    );
  }

  void push(BuildContext context) {
    context.pushNamed(
      super.name!,
      queryParameters: {
        if (communityId != null) 'communityId': communityId.toString(),
        if (communityName != null) 'communityName': communityName,
      },
      extra: this,
    );
  }

  final int? communityId;
  final String? communityName;
  final LemmyCommunity? community;
}

/// Defines the method for retrieving the community posts and retrieves them
/// when called.
class CommunityScreenContentRetriever extends ContentRetriever
    with EquatableMixin {
  const CommunityScreenContentRetriever({
    required this.sortType,
    required this.context,
    this.communityId,
    this.communityName,
  }) : assert(
          communityId != null || communityName != null,
          'No community defined',
        );

  final LemmySortType sortType;
  final BuildContext context;
  final int? communityId;
  final String? communityName;

  @override
  Future<List<Object>> call({required int page}) {
    return context.read<ServerRepo>().lemmyRepo.getPosts(
          page: page,
          communityId: communityId,
          sortType: sortType,
        );
  }

  @override
  List<Object?> get props => [sortType, context, communityId];

  CommunityScreenContentRetriever copyWith({
    LemmySortType? sortType,
    BuildContext? context,
    int? communityId,
  }) {
    return CommunityScreenContentRetriever(
      sortType: sortType ?? this.sortType,
      context: context ?? this.context,
      communityId: communityId ?? this.communityId,
    );
  }
}

/// Displays a specified community and its posts
class CommunityScreen extends StatelessWidget {
  /// initialize
  CommunityScreen({
    int? communityId,
    String? communityName,
    this.community,
    super.key,
  })  : communityId = communityId ?? community?.id,
        communityName = communityName ?? community?.name,
        assert(
          communityId != null || communityName != null || community != null,
          'No community defined',
        );

  /// The community ID
  final int? communityId;

  /// The community name
  final String? communityName;

  /// The community object which contains the community information.
  ///
  /// If this is set to null the information will be loaded from the API.
  /// Setting the value will mean the community information can be shown
  /// instantly
  final LemmyCommunity? community;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CommunityScreenBloc>(
          create: (context) => CommunityScreenBloc(
            communityId: communityId,
            community: community,
            communityName: communityName,
            repo: context.read<ServerRepo>(),
          )..add(InitialiseCommunityScreen()),
        ),
        BlocProvider<ContentScrollBloc>(
          create: (context) => ContentScrollBloc(
            retrieveContent: CommunityScreenContentRetriever(
              sortType: LemmySortType.hot,
              context: context,
              communityId: communityId,
            ),
          )..add(Initialise()),
        ),
      ],
      child: BlocBuilder<CommunityScreenBloc, CommunityScreenState>(
        builder: (context, state) {
          final blocContext = context;

          final communityBloc =
              BlocProvider.of<CommunityScreenBloc>(blocContext);
          final contentScrollBloc =
              BlocProvider.of<ContentScrollBloc>(blocContext);

          return Scaffold(
            body: MuffedPage(
              isLoading: state.isLoading,
              error: state.errorMessage,
              child: ContentScrollView(
                contentScrollBloc: BlocProvider.of<ContentScrollBloc>(
                  context,
                ),
                headerSlivers: [
                  SliverPersistentHeader(
                    delegate: _TopBarDelegate(
                      community: state.community,
                      bloc: communityBloc,
                    ),
                    pinned: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBarDelegate extends SliverPersistentHeaderDelegate {
  _TopBarDelegate({
    required this.bloc,
    LemmyCommunity? community,
  })  : usingPlaceholder = community == null,
        community = community ?? LemmyCommunity.placeHolder();

  final LemmyCommunity community;

  final bool usingPlaceholder;

  final CommunityScreenBloc bloc;

  double get headerMaxHeight => 400;

  double get headerMinHeight => 90;

  double get bannerEnd => 0.5;

  @override
  double get maxExtent => headerMaxHeight;

  @override
  double get minExtent => headerMinHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final fractionScrolled = shrinkOffset / headerMaxHeight;

    final placeholderBanner = ExtendedImage.asset(
      'assets/placeholder_banner.jpeg',
      height: (headerMaxHeight - shrinkOffset) * bannerEnd,
      width: double.maxFinite,
      fit: BoxFit.cover,
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Skeletonizer(
        key: ValueKey(usingPlaceholder),
        enabled: usingPlaceholder,
        ignoreContainers: true,
        child: Material(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.surface,
          elevation: 5,
          child: Stack(
            children: [
              Opacity(
                opacity: 1 - fractionScrolled,
                child: Stack(
                  children: [
                    // banner
                    if (!usingPlaceholder)
                      ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height),
                          );
                        },
                        blendMode: BlendMode.dstIn,
                        child: (community.banner != null)
                            ? SizedBox(
                                height: (headerMaxHeight - shrinkOffset) *
                                    bannerEnd,
                                child: MuffedImage(
                                  width: double.maxFinite,
                                  fit: BoxFit.cover,
                                  imageUrl: community.banner!,
                                ),
                              )
                            : placeholderBanner,
                      ),
                    // sizes to the height the the header
                    SizedBox(
                      height: headerMaxHeight - shrinkOffset,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // sizes from bottom up to the fraction chosen
                          // of the header
                          SizedBox(
                            height: (headerMaxHeight - shrinkOffset) *
                                (1 - (bannerEnd - 0.05)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // title
                                  Row(
                                    children: [
                                      MuffedAvatar(
                                        url: community.icon,
                                        radius: 34,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              community.title,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            Text(
                                              community.tag,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                                  ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: community.subscribers
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .outline,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: ' members',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .outline,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ⋅ ',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .outline,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: community
                                                        .usersActiveDay
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .outline,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: ' active',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .outline,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (community.description != null)
                                    Builder(
                                      builder: (context) {
                                        // gets only the first paragraph
                                        final matches = RegExp(
                                          r'^.*?\n',
                                          dotAll: true,
                                        ).firstMatch(community.description!);

                                        final text = matches?.group(0) ??
                                            community.description!;

                                        return MuffedMarkdownBody(
                                          maxHeight: 104,
                                          data: text,
                                        );
                                      },
                                    ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (context) =>
                                                  CommunityInfoScreen(
                                                bloc: bloc,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('See community info'),
                                      ),
                                      if (context
                                          .read<GlobalBloc>()
                                          .isLoggedIn())
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<CommunityScreenBloc>()
                                                .add(ToggledSubscribe());
                                          },
                                          style: (community.subscribed ==
                                                  LemmySubscribedType
                                                      .notSubscribed)
                                              ? TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                )
                                              : TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .outline,
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .outlineVariant,
                                                ),
                                          child: (community.subscribed ==
                                                  LemmySubscribedType
                                                      .subscribed)
                                              ? const Text('Unsubscribe')
                                              : (community.subscribed ==
                                                      LemmySubscribedType
                                                          .notSubscribed)
                                                  ? const Text('Subscribe')
                                                  : const Text('Pending'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: headerMaxHeight - shrinkOffset,
                width: double.maxFinite,
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Skeleton.keep(
                              child: IconButton(
                                onPressed: () {
                                  context.pop();
                                },
                                icon: const Icon(Icons.arrow_back),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Opacity(
                              opacity:
                                  Curves.easeInCirc.transform(fractionScrolled),
                              child: Row(
                                children: [
                                  MuffedAvatar(url: community.icon, radius: 16),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    community.title,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
