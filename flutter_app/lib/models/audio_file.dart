import 'package:json_annotation/json_annotation.dart';

part 'audio_file.g.dart';

@JsonSerializable()
class AudioFile {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'file_name')
  final String fileName;
  @JsonKey(name: 'file_size')
  final int? fileSize;
  final int? duration;
  @JsonKey(name: 'transcript_text')
  final String? transcriptText;
  @JsonKey(name: 'processing_status')
  final String processingStatus;
  @JsonKey(name: 'recipe_id')
  final String? recipeId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const AudioFile({
    required this.id,
    required this.userId,
    required this.fileName,
    this.fileSize,
    this.duration,
    this.transcriptText,
    required this.processingStatus,
    this.recipeId,
    required this.createdAt,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) => _$AudioFileFromJson(json);
  Map<String, dynamic> toJson() => _$AudioFileToJson(this);

  bool get isProcessing => processingStatus == 'processing';
  bool get isCompleted => processingStatus == 'completed';
  bool get isFailed => processingStatus == 'failed';
  bool get isUploaded => processingStatus == 'uploaded';

  String get durationString {
    if (duration == null) return '알 수 없음';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes}분 ${seconds}초';
  }

  String get fileSizeString {
    if (fileSize == null) return '알 수 없음';
    final kb = fileSize! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  AudioFile copyWith({
    String? id,
    String? userId,
    String? fileName,
    int? fileSize,
    int? duration,
    String? transcriptText,
    String? processingStatus,
    String? recipeId,
    DateTime? createdAt,
  }) {
    return AudioFile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      transcriptText: transcriptText ?? this.transcriptText,
      processingStatus: processingStatus ?? this.processingStatus,
      recipeId: recipeId ?? this.recipeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}