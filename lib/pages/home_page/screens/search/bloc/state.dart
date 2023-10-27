part of 'bloc.dart';

final class SearchState extends Equatable {
  ///
  const SearchState({
    this.searchQuery = '',
    this.loadedSearchQuery = '',
    this.sortType = LemmySortType.topAll,
    this.loadedSortType = LemmySortType.topAll,
    this.errorMessage,
    this.isLoading = false,
    this.pagesLoaded = 0,

    // communities
    this.communities = const [],

    // comments
    this.comments = const [],

    // posts
    this.posts = const [],

    // persons
    this.persons = const [],
  });

  final String searchQuery;
  final String loadedSearchQuery;
  final LemmySortType sortType;
  final LemmySortType loadedSortType;
  final String? errorMessage;

  final bool isLoading;
  final int pagesLoaded;

  // communities
  final List<LemmyCommunity> communities;

  // persons
  final List<LemmyPerson> persons;

  // posts
  final List<LemmyPost> posts;

  // comments
  final List<LemmyComment> comments;

  @override
  List<Object?> get props => [
        searchQuery,
        loadedSearchQuery,
        sortType,
        loadedSortType,
        errorMessage,
        isLoading,
        pagesLoaded,
        communities,
        persons,
        posts,
        comments,
      ];

  SearchState copyWith({
    String? searchQuery,
    String? loadedSearchQuery,
    LemmySortType? sortType,
    LemmySortType? loadedSortType,
    String? errorMessage,
    bool? isLoading,
    int? pagesLoaded,

    // communities
    List<LemmyCommunity>? communities,

    // persons
    List<LemmyPerson>? persons,

    // posts
    List<LemmyPost>? posts,

    // comments
    List<LemmyComment>? comments,
  }) {
    return SearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      loadedSearchQuery: loadedSearchQuery ?? this.loadedSearchQuery,
      sortType: sortType ?? this.sortType,
      loadedSortType: loadedSortType ?? this.loadedSortType,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      pagesLoaded: pagesLoaded ?? this.pagesLoaded,
      communities: communities ?? this.communities,
      persons: persons ?? this.persons,
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
    );
  }
}