import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/recipe.dart';
import '../../config/theme.dart';
import '../../widgets/share/recipe_share_card.dart';

class RecipeShareService {
  static final RecipeShareService _instance = RecipeShareService._internal();
  factory RecipeShareService() => _instance;
  RecipeShareService._internal();

  final GlobalKey _globalKey = GlobalKey();

  // 간단한 텍스트 공유 (이미지 없이)
  Future<void> shareRecipeText(Recipe recipe, BuildContext context) async {
    try {
      String shareText = '🍽️ ${recipe.title} 레시피\n\n';
      
      if (recipe.description != null && recipe.description!.isNotEmpty) {
        shareText += '📖 ${recipe.description}\n\n';
      }
      
      if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) {
        shareText += '🥬 재료:\n';
        for (final ingredient in recipe.ingredients!.take(5)) {
          shareText += '• ${ingredient.name} ${ingredient.amount}\n';
        }
        if (recipe.ingredients!.length > 5) {
          shareText += '외 ${recipe.ingredients!.length - 5}개 더...\n';
        }
        shareText += '\n';
      }
      
      if (recipe.steps != null && recipe.steps!.isNotEmpty) {
        shareText += '👩‍🍳 조리법:\n';
        for (final step in recipe.steps!.take(3)) {
          shareText += '${step.step}. ${step.instruction}\n';
        }
        if (recipe.steps!.length > 3) {
          shareText += '총 ${recipe.steps!.length}단계...\n';
        }
        shareText += '\n';
      }
      
      shareText += '📱 MOMENTO 앱에서 음성안내로 요리해보세요!';
      
      // share_plus가 실패하면 클립보드 복사로 대체
      try {
        await Share.share(shareText);
      } catch (shareError) {
        print('Share.share failed: $shareError');
        // 클립보드에 복사하고 사용자에게 알림
        await _copyToClipboardAndNotify(shareText, context);
      }
      
    } catch (e) {
      // 모든 공유 방법 실패시 클립보드 복사
      String fallbackText = '${recipe.title} 레시피를 MOMENTO에서 공유합니다!';
      await _copyToClipboardAndNotify(fallbackText, context);
    }
  }

  Future<void> _copyToClipboardAndNotify(String text, BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('레시피가 클립보드에 복사되었습니다! 원하는 앱에서 붙여넣기하세요 📋'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공유 기능을 사용할 수 없습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> shareRecipeCard(Recipe recipe, BuildContext context) async {
    try {
      // 로딩 다이얼로그 표시
      _showLoadingDialog(context);

      // 이미지 생성 시도 - 오버레이 없이 직접 생성
      final imageFile = await _generateRecipeCardDirectly(recipe);

      // 로딩 다이얼로그 닫기
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (imageFile != null) {
        // 공유하기
        try {
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            text: '${recipe.title} 레시피를 MOMENTO에서 공유합니다! 🍽️\n\n앱에서 음성안내로 요리해보세요 📱',
          );
        } catch (shareError) {
          // XFiles 공유 실패시 fallback으로 텍스트만 공유
          print('XFiles share failed: $shareError');
          await Share.share(
            '${recipe.title} 레시피를 MOMENTO에서 공유합니다! 🍽️\n\n${recipe.description ?? ''}\n\n앱에서 음성안내로 요리해보세요 📱',
          );
        }

        // 임시 파일 삭제
        await imageFile.delete();
      } else {
        // 이미지 생성 실패시 텍스트 공유로 fallback
        await shareRecipeText(recipe, context);
      }
    } catch (e) {
      // 로딩 다이얼로그가 열려있으면 닫기
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 공유 실패: 텍스트로 공유합니다'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        // fallback으로 텍스트 공유
        await shareRecipeText(recipe, context);
      }
    }
  }

  OverlayEntry _createHiddenWidget(Recipe recipe, BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: -1000, // 화면 밖에 위치
        top: 0,
        child: RepaintBoundary(
          key: _globalKey,
          child: Material(
            color: Colors.transparent,
            child: RecipeShareCard(recipe: recipe),
          ),
        ),
      ),
    );
  }

  Future<File?> _generateRecipeCardDirectly(Recipe recipe) async {
    try {
      // 간단하게 텍스트 기반 이미지 생성 (실제로는 텍스트 파일)
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/recipe_text_${DateTime.now().millisecondsSinceEpoch}.txt');
      
      String content = '🍽️ ${recipe.title}\n\n';
      if (recipe.description != null) {
        content += '${recipe.description}\n\n';
      }
      content += '📱 MOMENTO 앱에서 음성안내로 요리해보세요!';
      
      await file.writeAsString(content);
      return file;
    } catch (e) {
      print('Direct image generation error: $e');
      return null;
    }
  }

  Future<File?> _captureWidget() async {
    try {
      final RenderRepaintBoundary boundary = 
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/recipe_card_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      
      return file;
    } catch (e) {
      print('Image capture error: $e');
      return null;
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '레시피 카드를 생성하고 있습니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}