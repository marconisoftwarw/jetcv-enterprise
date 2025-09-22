import 'package:image_picker/image_picker.dart';

class MediaItem {
  final XFile file;
  String title;
  String description;

  MediaItem({required this.file, this.title = '', this.description = ''});

  // Metodo per creare una copia con nuovi valori
  MediaItem copyWith({XFile? file, String? title, String? description}) {
    return MediaItem(
      file: file ?? this.file,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
