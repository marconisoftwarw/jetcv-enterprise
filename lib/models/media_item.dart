import 'package:image_picker/image_picker.dart';

class MediaItem {
  final XFile file;
  String title;
  String description;
  String? type; // 'image', 'video', 'audio'

  MediaItem({
    required this.file,
    this.title = '',
    this.description = '',
    this.type,
  });

  // Metodo per creare una copia con nuovi valori
  MediaItem copyWith({
    XFile? file,
    String? title,
    String? description,
    String? type,
  }) {
    return MediaItem(
      file: file ?? this.file,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }
}
