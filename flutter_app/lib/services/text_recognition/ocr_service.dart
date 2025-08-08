import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static OCRService? _instance;
  static OCRService get instance => _instance ??= OCRService._();
  
  OCRService._();
  
  late final TextRecognizer _koreanRecognizer;
  late final TextRecognizer _latinRecognizer;
  
  /// Initialize the OCR service
  Future<void> initialize() async {
    _koreanRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    _latinRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }
  
  /// Extract text from image file
  Future<OCRResult> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      
      // Try Korean recognition first (primary for recipes)
      RecognizedText? koreanResult;
      try {
        koreanResult = await _koreanRecognizer.processImage(inputImage);
      } catch (e) {
        print('Korean recognition failed: $e');
      }
      
      // Try Latin recognition as fallback
      RecognizedText? latinResult;
      try {
        latinResult = await _latinRecognizer.processImage(inputImage);
      } catch (e) {
        print('Latin recognition failed: $e');
      }
      
      // Combine results or use the better one
      RecognizedText finalResult;
      if (koreanResult != null && koreanResult.text.isNotEmpty) {
        // If Korean found text, use it (may include mixed Korean/English)
        finalResult = koreanResult;
      } else if (latinResult != null && latinResult.text.isNotEmpty) {
        // Fall back to Latin if Korean didn't work
        finalResult = latinResult;
      } else {
        // No text found in either
        return OCRResult.empty();
      }
      
      return OCRResult(
        fullText: finalResult.text,
        textElements: finalResult.blocks
            .expand((block) => block.lines)
            .expand((line) => line.elements)
            .map((element) => OCRTextElement(
              text: element.text,
              boundingBox: element.boundingBox,
              confidence: element.confidence,
            ))
            .toList(),
        blocks: finalResult.blocks
            .map((block) => OCRTextBlock(
              text: block.text,
              boundingBox: block.boundingBox,
              lines: block.lines
                  .map((line) => OCRTextLine(
                    text: line.text,
                    boundingBox: line.boundingBox,
                  ))
                  .toList(),
            ))
            .toList(),
        success: true,
      );
    } catch (e) {
      return OCRResult(
        fullText: '',
        textElements: [],
        blocks: [],
        success: false,
        error: '텍스트 인식 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }
  
  /// Clean up the OCR service
  void dispose() {
    _koreanRecognizer.close();
    _latinRecognizer.close();
  }
  
  /// Check if the service is available
  bool get isAvailable {
    return true; // Google ML Kit is always available
  }
  
  /// Preprocess text for better recipe parsing
  String preprocessRecipeText(String rawText) {
    // Remove extra whitespace and normalize line breaks
    String cleaned = rawText
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .trim();
    
    // Add some basic formatting for common recipe patterns
    cleaned = cleaned
        .replaceAll(RegExp(r'재료\s*[:：]?'), '\n재료:\n')
        .replaceAll(RegExp(r'만드는\s*법\s*[:：]?'), '\n만드는 법:\n')
        .replaceAll(RegExp(r'조리법\s*[:：]?'), '\n조리법:\n')
        .replaceAll(RegExp(r'요리법\s*[:：]?'), '\n요리법:\n')
        .replaceAll(RegExp(r'팁\s*[:：]?'), '\n팁:\n')
        .replaceAll(RegExp(r'주의사항\s*[:：]?'), '\n주의사항:\n');
    
    return cleaned;
  }
  
  /// Extract recipe-specific information from OCR text
  RecipeOCRInfo extractRecipeInfo(String text) {
    final processedText = preprocessRecipeText(text);
    
    // Extract title (usually the first line or prominent text)
    String? title;
    final lines = processedText.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      // Look for a potential title in the first few lines
      for (int i = 0; i < lines.length && i < 3; i++) {
        final line = lines[i].trim();
        if (line.length > 2 && line.length < 50 && !line.contains(':')) {
          title = line;
          break;
        }
      }
    }
    
    // Extract ingredients section
    String? ingredients;
    final ingredientsMatch = RegExp(r'재료\s*[:：]?\s*([\s\S]*?)(?=\n(?:만드는\s*법|조리법|요리법|팁|주의사항|$))', caseSensitive: false)
        .firstMatch(processedText);
    if (ingredientsMatch != null) {
      ingredients = ingredientsMatch.group(1)?.trim();
    }
    
    // Extract instructions section
    String? instructions;
    final instructionsMatch = RegExp(r'(?:만드는\s*법|조리법|요리법)\s*[:：]?\s*([\s\S]*?)(?=\n(?:팁|주의사항|$))', caseSensitive: false)
        .firstMatch(processedText);
    if (instructionsMatch != null) {
      instructions = instructionsMatch.group(1)?.trim();
    }
    
    // Extract tips section
    String? tips;
    final tipsMatch = RegExp(r'(?:팁|주의사항)\s*[:：]?\s*([\s\S]*?)$', caseSensitive: false)
        .firstMatch(processedText);
    if (tipsMatch != null) {
      tips = tipsMatch.group(1)?.trim();
    }
    
    return RecipeOCRInfo(
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      tips: tips,
      fullText: processedText,
      confidence: _calculateConfidence(processedText),
    );
  }
  
  double _calculateConfidence(String text) {
    // Simple confidence calculation based on text structure
    double confidence = 0.5; // Base confidence
    
    if (text.contains('재료')) confidence += 0.2;
    if (text.contains(RegExp(r'만드는\s*법|조리법|요리법'))) confidence += 0.2;
    if (text.contains(RegExp(r'\d+\s*(?:개|g|ml|컵|큰술|작은술|마리)'))) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }
}

/// OCR result data class
class OCRResult {
  final String fullText;
  final List<OCRTextElement> textElements;
  final List<OCRTextBlock> blocks;
  final bool success;
  final String? error;
  
  OCRResult({
    required this.fullText,
    required this.textElements,
    required this.blocks,
    required this.success,
    this.error,
  });
  
  factory OCRResult.empty() {
    return OCRResult(
      fullText: '',
      textElements: [],
      blocks: [],
      success: true,
    );
  }
  
  bool get hasText => fullText.isNotEmpty;
}

/// OCR text element data class
class OCRTextElement {
  final String text;
  final Rect boundingBox;
  final double? confidence;
  
  OCRTextElement({
    required this.text,
    required this.boundingBox,
    this.confidence,
  });
}

/// OCR text block data class
class OCRTextBlock {
  final String text;
  final Rect boundingBox;
  final List<OCRTextLine> lines;
  
  OCRTextBlock({
    required this.text,
    required this.boundingBox,
    required this.lines,
  });
}

/// OCR text line data class
class OCRTextLine {
  final String text;
  final Rect boundingBox;
  
  OCRTextLine({
    required this.text,
    required this.boundingBox,
  });
}

/// Recipe-specific OCR information
class RecipeOCRInfo {
  final String? title;
  final String? ingredients;
  final String? instructions;
  final String? tips;
  final String fullText;
  final double confidence;
  
  RecipeOCRInfo({
    this.title,
    this.ingredients,
    this.instructions,
    this.tips,
    required this.fullText,
    required this.confidence,
  });
  
  bool get hasStructuredData => title != null || ingredients != null || instructions != null;
  
  /// Convert to a formatted string for AI processing
  String toFormattedString() {
    final buffer = StringBuffer();
    
    if (title != null) {
      buffer.writeln('제목: $title');
      buffer.writeln();
    }
    
    if (ingredients != null) {
      buffer.writeln('재료:');
      buffer.writeln(ingredients);
      buffer.writeln();
    }
    
    if (instructions != null) {
      buffer.writeln('만드는 법:');
      buffer.writeln(instructions);
      buffer.writeln();
    }
    
    if (tips != null) {
      buffer.writeln('팁:');
      buffer.writeln(tips);
    }
    
    // If no structured data, return full text
    if (!hasStructuredData) {
      return fullText;
    }
    
    return buffer.toString().trim();
  }
}