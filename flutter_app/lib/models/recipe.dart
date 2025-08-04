import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'recipe.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class RecipeIngredient {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String amount;
  @HiveField(2)
  final String? notes;

  const RecipeIngredient({
    required this.name,
    required this.amount,
    this.notes,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => 
      _$RecipeIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 1)
class RecipeStep {
  @HiveField(0)
  final int step;
  @HiveField(1)
  final String instruction;
  @HiveField(2)
  final String? time;
  @HiveField(3)
  final String? temperature;
  @HiveField(4)
  final String? tips;

  const RecipeStep({
    required this.step,
    required this.instruction,
    this.time,
    this.temperature,
    this.tips,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) => 
      _$RecipeStepFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 2)
class Recipe {
  @HiveField(0)
  final String id;
  @JsonKey(name: 'user_id')
  @HiveField(1)
  final String userId;
  @JsonKey(name: 'source_audio_id')
  @HiveField(2)
  final String? sourceAudioId;
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final List<RecipeIngredient>? ingredients;
  @HiveField(6)
  final List<RecipeStep>? steps;
  @HiveField(7)
  final String? tips;
  @HiveField(8)
  final String? servings;
  @JsonKey(name: 'cooking_time')
  @HiveField(9)
  final String? cookingTime;
  @HiveField(10)
  final String? difficulty;
  @HiveField(11)
  final String? category;
  @JsonKey(name: 'image_url')
  @HiveField(12)
  final String? imageUrl;
  @JsonKey(name: 'created_at')
  @HiveField(13)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  @HiveField(14)
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.userId,
    this.sourceAudioId,
    required this.title,
    this.description,
    this.ingredients,
    this.steps,
    this.tips,
    this.servings,
    this.cookingTime,
    this.difficulty,
    this.category,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  int get totalSteps => steps?.length ?? 0;
  int get totalIngredients => ingredients?.length ?? 0;

  String get difficultyDisplay {
    switch (difficulty?.toLowerCase()) {
      case '쉬움':
        return '⭐ 쉬움';
      case '보통':
        return '⭐⭐ 보통';
      case '어려움':
        return '⭐⭐⭐ 어려움';
      default:
        return '⭐⭐ 보통';
    }
  }

  String get categoryDisplay {
    return category ?? '기타';
  }

  Recipe copyWith({
    String? id,
    String? userId,
    String? sourceAudioId,
    String? title,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
    String? tips,
    String? servings,
    String? cookingTime,
    String? difficulty,
    String? category,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sourceAudioId: sourceAudioId ?? this.sourceAudioId,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
      servings: servings ?? this.servings,
      cookingTime: cookingTime ?? this.cookingTime,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}