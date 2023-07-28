import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:muffed/repo/server_repo.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

part 'event.dart';

part 'state.dart';

/// The bloc for the content screen
class ContentScreenBloc extends Bloc<ContentScreenEvent, ContentScreenState> {
  /// Initialize
  ContentScreenBloc({required this.repo, required this.postId})
      : super(ContentScreenState(status: ContentScreenStatus.initial)) {
    on<InitializeEvent>((event, emit) async {
      emit(ContentScreenState(status: ContentScreenStatus.loading));

      try {
        List<LemmyComment> comments =
            await repo.lemmyRepo.getComments(postId, page: 1);

        emit(
          ContentScreenState(
            status: ContentScreenStatus.success,
            comments: comments,
            pagesLoaded: 1,
          ),
        );
      } catch (err) {
        emit(
          state.copyWith(
            status: ContentScreenStatus.failure,
            errorMessage: err.toString(),
          ),
        );
      }
    });
    on<ReachedNearEndOfScroll>(
      (event, emit) async {
        if (!state.reachedEnd) {
          print('[ContentScreenBloc] loading page ${state.pagesLoaded + 1}');

          emit(state.copyWith(isLoadingMore: true));

          List<LemmyComment> comments = await repo.lemmyRepo
              .getComments(postId, page: state.pagesLoaded + 1);

          if (comments.isEmpty) {
            emit(state.copyWith(reachedEnd: true));

            print('[ContentScreenBloc] end reached');
          } else {
            emit(
              state.copyWith(
                isLoadingMore: false,
                pagesLoaded: state.pagesLoaded + 1,
                comments: [...state.comments ?? [], ...comments],
              ),
            );

            print('[ContentScreenBloc] loaded page ${state.pagesLoaded}');
          }
        }
      },
      transformer: droppable(),
    );
    on<UserCommented>((event, emit) async {
      emit(state.copyWith(createdCommentGettingPosted: true));

      try {
        await repo.lemmyRepo.createComment(event.comment, postId, null);
        emit(state.copyWith(createdCommentGettingPosted: false));
        event.onSuccess();
      } catch (err) {
        emit(
          state.copyWith(
            createCommentErrorMessage: err.toString(),
            isLoadingMore: false,
          ),
        );
      }
    });
  }

  final ServerRepo repo;
  final int postId;
}
