import 'package:equatable/equatable.dart';

enum ContentType {
  text,
  image,
  video,
  gif,
  url,
}

enum LemmySortType {
  active,
  hot,
  latest,
  old,
  topDay,
  topWeek,
  topMonth,
  topYear,
  topAll,
  mostComments,
  newComments,
  topHour,
  topSixHour,
  topTwelveHour,
}

Map<LemmySortType, String> lemmySortTypeEnumToApiCompatible = {
  LemmySortType.active : 'Active',
  LemmySortType.hot : 'Hot',
  LemmySortType.latest: 'New',
  LemmySortType.old : 'Old',
  LemmySortType.topDay : 'TopDay',
  LemmySortType.topWeek : 'TopWeek',
  LemmySortType.topMonth : "TopMonth",
  LemmySortType.topYear : "TopYear",
  LemmySortType.topAll : "TopAll",
  LemmySortType.mostComments : 'MostComments',
  LemmySortType.newComments : 'NewComments',
  LemmySortType.topHour : 'TopHour',
  LemmySortType.topSixHour : 'TopSixHour',
  LemmySortType.topTwelveHour: 'TopTwelveHour',
};

class LemmyPost extends Equatable {
  final int id;
  final String name;

  final String? url;
  final String? thumbnailUrl;
  final String? body;
  final ContentType? contentType;


  final DateTime timePublished;
  final bool nsfw;

  final int creatorId;
  final String creatorName;

  final int communityId;
  final String communityName;
  final String? communityIcon;

  final int commentCount;
  final int upVotes;
  final int downVotes;
  final int score;

  final bool read;
  final bool saved;

  const LemmyPost({
    this.body,
    this.url,
    this.thumbnailUrl,
    this.contentType,
    required this.id,
    required this.name,
    required this.timePublished,
    required this.nsfw,
    required this.creatorId,
    required this.creatorName,
    required this.communityId,
    required this.communityName,
    required this.communityIcon,
    required this.commentCount,
    required this.upVotes,
    required this.downVotes,
    required this.score,
    required this.read,
    required this.saved,
  });

  @override
  List<Object> get props => [id];


}