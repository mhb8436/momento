import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/app_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/inquiry_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/storage/local_storage_service.dart';
import 'services/api/api_service.dart';
import 'services/notification_service.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize local storage
  await LocalStorageService.init();
  
  // Initialize API service
  ApiService().initialize();
  
  // Initialize notification service
  try {
    await NotificationService.initialize();
    print('✅ NotificationService 초기화 완료');
  } catch (e) {
    print('❌ NotificationService 초기화 실패: $e');
  }
  
  // Initialize cache service
  try {
    await CacheService.initialize();
    print('✅ CacheService 초기화 완료');
  } catch (e) {
    print('❌ CacheService 초기화 실패: $e');
  }
  
  runApp(const MomentoApp());
}

class MomentoApp extends StatelessWidget {
  const MomentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => InquiryProvider()),
        ChangeNotifierProxyProvider<RecipeProvider, AudioProvider>(
          create: (_) => AudioProvider(),
          update: (_, recipeProvider, audioProvider) {
            audioProvider ??= AudioProvider();
            audioProvider.setRecipeProvider(recipeProvider);
            return audioProvider;
          },
        ),
      ],
      child: GestureDetector(
        onTap: () {
          // 앱 전체에서 터치 시 키보드 숨기기
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          title: 'MOMENTO',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}