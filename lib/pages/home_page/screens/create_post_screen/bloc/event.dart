part of 'bloc.dart';

abstract class CreatePostEvent {}

class Initalize extends CreatePostEvent {}

class PreviewToggled extends CreatePostEvent {}

class PostSubmitted extends CreatePostEvent {
  PostSubmitted({required this.title, this.body, this.url});

  final String title;
  final String? body;
  final String? url;
}

class BodyImageToUploadSelected extends CreatePostEvent {
  BodyImageToUploadSelected({required this.filePath});

  final String filePath;
}

class UploadedBodyImageRemoved extends CreatePostEvent {
  UploadedBodyImageRemoved({required this.id});

  final int id;
}

class UrlAdded extends CreatePostEvent {
  UrlAdded({required this.url});

  final String url;
}

class UrlRemoved extends CreatePostEvent {}

class ImageToUploadSelected extends CreatePostEvent {
  ImageToUploadSelected({required this.filePath});

  final String filePath;
}

class ImageRemoved extends CreatePostEvent {}
