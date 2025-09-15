import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/recipe.dart';

enum TtsState { playing, stopped, paused, continued }

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  int _currentStepIndex = 0;
  Recipe? _currentRecipe;
  bool _isRepeating = false;

  TtsState get ttsState => _ttsState;
  int get currentStepIndex => _currentStepIndex;
  bool get isRepeating => _isRepeating;

  Function(int)? onStepChanged;
  Function(TtsState)? onStateChanged;

  Future<void> initialize() async {
    try {
      _flutterTts = FlutterTts();

      if (Platform.isIOS) {
        try {
          await _flutterTts.setSharedInstance(true);
          await _flutterTts
              .setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ]);
        } catch (e) {
          print("iOS specific TTS settings failed: $e");
        }
      }

      // 한국어 설정
      await _flutterTts.setLanguage("ko-KR");
      await _flutterTts.setSpeechRate(0.5); // 조리에 적합한 느린 속도
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      print("TTS initialization failed: $e");
      return;
    }

    // 콜백 설정
    _flutterTts.setStartHandler(() {
      _setTtsState(TtsState.playing);
    });

    _flutterTts.setCompletionHandler(() {
      _setTtsState(TtsState.stopped);
    });

    _flutterTts.setErrorHandler((msg) {
      _setTtsState(TtsState.stopped);
      print("TTS Error: $msg");
    });

    _flutterTts.setCancelHandler(() {
      _setTtsState(TtsState.stopped);
    });

    _flutterTts.setPauseHandler(() {
      _setTtsState(TtsState.paused);
    });

    _flutterTts.setContinueHandler(() {
      _setTtsState(TtsState.continued);
    });
  }

  void _setTtsState(TtsState state) {
    _ttsState = state;
    onStateChanged?.call(state);
  }


  Future<void> startReadingRecipe(Recipe recipe, {int startStep = 0}) async {
    _currentRecipe = recipe;
    _currentStepIndex = -1; // 재료/요약 단계를 나타내기 위해 -1로 시작
    _isRepeating = true;

    // 재료 -> 요약 -> 조리법 순서로 읽기 시작
    await _startFullRecipeReading();
  }

  Future<void> _startFullRecipeReading() async {
    while (_isRepeating && _currentRecipe != null) {
      // 1. 레시피 제목과 내용 읽기
      await _readRecipeTitle(_currentRecipe!);
      if (!_isRepeating) break;
      await Future.delayed(const Duration(seconds: 2));
      
      // 2. 재료 읽기
      await readIngredients(_currentRecipe!);
      if (!_isRepeating) break;
      await Future.delayed(const Duration(seconds: 2));
      
      // 3. 조리법 단계별 읽기
      _currentStepIndex = 0;
      onStepChanged?.call(_currentStepIndex);
      await _readAllSteps();
      if (!_isRepeating) break;
      await Future.delayed(const Duration(seconds: 2));
      
      // 4. 팁 읽기
      await _readTips(_currentRecipe!);
      if (!_isRepeating) break;
      
      // 전체 반복을 위해 3초 대기 후 처음부터 다시
      await Future.delayed(const Duration(seconds: 3));
      _currentStepIndex = -1; // 다시 시작
      onStepChanged?.call(_currentStepIndex);
    }
  }

  Future<void> _readRecipeTitle(Recipe recipe) async {
    String textToRead = "레시피: ${recipe.title}. ";
    
    if (recipe.description != null && recipe.description!.isNotEmpty) {
      textToRead += "${recipe.description}. ";
    }

    if (recipe.servings != null && recipe.servings!.isNotEmpty) {
      textToRead += "인분: ${recipe.servings}. ";
    }

    if (recipe.cookingTime != null && recipe.cookingTime!.isNotEmpty) {
      textToRead += "조리시간: ${recipe.cookingTime}. ";
    }

    String difficultyText = recipe.difficulty ?? '보통';
    textToRead += "난이도: $difficultyText.";

    return _speakAndWait(textToRead);
  }

  Future<void> _readAllSteps() async {
    if (_currentRecipe?.steps == null) return;
    
    for (int i = 0; i < _currentRecipe!.steps!.length; i++) {
      if (!_isRepeating) break;
      
      _currentStepIndex = i;
      onStepChanged?.call(_currentStepIndex);
      
      final step = _currentRecipe!.steps![i];
      String textToRead = "단계 ${step.step}. ${step.instruction}";

      if (step.time != null && step.time!.isNotEmpty) {
        textToRead += " 시간: ${step.time}";
      }

      if (step.temperature != null && step.temperature!.isNotEmpty) {
        textToRead += " 온도: ${step.temperature}";
      }

      if (step.tips != null && step.tips!.isNotEmpty) {
        textToRead += " 팁: ${step.tips}";
      }

      await _speakAndWait(textToRead);
      
      if (i < _currentRecipe!.steps!.length - 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> _readTips(Recipe recipe) async {
    if (recipe.tips != null && recipe.tips!.isNotEmpty) {
      String textToRead = "요리 팁을 알려드리겠습니다. ${recipe.tips}";
      await _speakAndWait(textToRead);
    } else {
      await _speakAndWait("등록된 요리 팁이 없습니다.");
    }
  }

  Future<void> readStep(Recipe recipe, int stepIndex) async {
    _currentRecipe = recipe;
    _currentStepIndex = stepIndex;
    _isRepeating = false;

    if (recipe.steps == null || stepIndex >= recipe.steps!.length) return;
    
    final step = recipe.steps![stepIndex];
    String textToRead = "단계 ${step.step}. ${step.instruction}";

    if (step.time != null && step.time!.isNotEmpty) {
      textToRead += " 시간: ${step.time}";
    }

    if (step.temperature != null && step.temperature!.isNotEmpty) {
      textToRead += " 온도: ${step.temperature}";
    }

    if (step.tips != null && step.tips!.isNotEmpty) {
      textToRead += " 팁: ${step.tips}";
    }

    await speak(textToRead);
  }

  Future<void> readIngredients(Recipe recipe) async {
    if (recipe.ingredients == null || recipe.ingredients!.isEmpty) {
      return _speakAndWait("재료가 없습니다.");
    }

    String textToRead = "재료를 알려드리겠습니다. ";
    for (final ingredient in recipe.ingredients!) {
      textToRead += "${ingredient.name} ${ingredient.amount}. ";
      if (ingredient.notes != null && ingredient.notes!.isNotEmpty) {
        textToRead += "참고사항: ${ingredient.notes}. ";
      }
    }

    return _speakAndWait(textToRead);
  }

  Future<void> _speakAndWait(String text) async {
    final completer = Completer<void>();
    
    // 임시로 completion handler 설정
    _flutterTts.setCompletionHandler(() {
      completer.complete();
      // 원래 completion handler로 복구
      _flutterTts.setCompletionHandler(() {
        _setTtsState(TtsState.stopped);
      });
    });

    await speak(text);
    return completer.future;
  }

  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS speak failed: $e");
    }
  }

  Future<void> stop() async {
    _isRepeating = false;
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("TTS stop failed: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print("TTS pause failed: $e");
    }
  }

  Future<void> resume() async {
    try {
      await _flutterTts.speak("");
    } catch (e) {
      print("TTS resume failed: $e");
    }
  }

  void toggleRepeat() {
    _isRepeating = !_isRepeating;
    if (!_isRepeating) {
      stop();
    }
  }

  void setRepeat(bool repeat) {
    _isRepeating = repeat;
    if (!_isRepeating) {
      stop();
    }
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  void dispose() {
    try {
      _flutterTts.stop();
    } catch (e) {
      print("TTS dispose failed: $e");
    }
  }
}