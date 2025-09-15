// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'MOMENTO';

  @override
  String get appSubtitle => '엄마의 요리법을 음성과 AI로 기록하세요';

  @override
  String get login => '로그인';

  @override
  String get signup => '회원가입';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get loginButton => '로그인';

  @override
  String get signupButton => '계정 만들기';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get dontHaveAccount => '계정이 없으신가요?';

  @override
  String get enterEmail => '이메일을 입력해주세요';

  @override
  String get enterPassword => '비밀번호를 입력해주세요';

  @override
  String get invalidEmail => '올바른 이메일 형식을 입력해주세요';

  @override
  String get passwordTooShort => '비밀번호는 최소 6자 이상이어야 합니다';

  @override
  String get passwordsNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get home => '홈';

  @override
  String get recipes => '레시피';

  @override
  String get profile => '프로필';

  @override
  String get settings => '설정';

  @override
  String get createRecipe => '레시피 생성';

  @override
  String get recordVoice => '음성으로 기록';

  @override
  String get recordVoiceSubtitle => '요리 과정을 말해주시면\\nAI가 구조화된 레시피로 정리해드립니다';

  @override
  String get scanImage => '이미지 스캔';

  @override
  String get scanImageSubtitle => '사진에서 텍스트\\n추출하기';

  @override
  String get textInput => '텍스트 입력';

  @override
  String get textInputSubtitle => '메모/메시지를\\n직접 입력';

  @override
  String get urlInput => 'URL 입력';

  @override
  String get urlInputSubtitle => '유튜브/블로그\\n링크에서 추출';

  @override
  String get startRecording => '녹음 시작';

  @override
  String get stopRecording => '녹음 중지';

  @override
  String get processing => '처리 중...';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get share => '공유';

  @override
  String get voiceRecognition => '음성 인식';

  @override
  String get listening => '음성을 듣고 있습니다...';

  @override
  String get waitingForVoice => '음성 입력 대기';

  @override
  String get tapToStartRecording => '마이크 버튼을 눌러 시작하세요';

  @override
  String get speakCookingInstructions => '요리법을 명확하게 말해주세요';

  @override
  String get includeIngredientsAndSteps => '재료, 조리 과정, 팁을 포함해 주세요';

  @override
  String get credits => '크레딧';

  @override
  String get creditsRequired => '크레딧 필요';

  @override
  String creditsRequiredMessage(String action) {
    return '$action에는 1크레딧이 필요합니다.';
  }

  @override
  String get currentCredits => '현재 크레딧';

  @override
  String get insufficientCredits => '크레딧 부족';

  @override
  String get creditShortage => '크레딧이 부족합니다. 크레딧을 구매하거나 일일 무료 크레딧을 기다려주세요.';

  @override
  String freeCreditsRemaining(int count) {
    return '남은 무료 크레딧 $count개 (오늘)';
  }

  @override
  String get creditStore => '크레딧 상점';

  @override
  String get purchaseCredits => '크레딧 구매';

  @override
  String get creditPackages => '크레딧 패키지';

  @override
  String get autoRechargeSubscriptions => '자동충전 구독';

  @override
  String get starterPackage => '스타터 패키지';

  @override
  String get familyPackage => '패밀리 패키지';

  @override
  String get premiumPackage => '프리미엄 패키지';

  @override
  String get monthlyAutoRecharge => '월간 자동충전';

  @override
  String get yearlyAutoRecharge => '연간 자동충전';

  @override
  String creditsAmount(int count) {
    return '$count크레딧';
  }

  @override
  String price(String amount) {
    return '$amount';
  }

  @override
  String get creditStoreInfo => '크레딧 상점 안내';

  @override
  String creditStoreDescription(int recipeGenCost, int recipeImproveCost,
      int initialCredits, int dailyCredits) {
    return '크레딧을 사용하여 AI 레시피 생성 서비스를 이용하세요.\\n\\n📝 이용 요금:\\n• 레시피 생성: $recipeGenCost크레딧\\n• 레시피 개선: $recipeImproveCost크레딧\\n\\n🎁 무료 혜택:\\n• 신규 가입: $initialCredits크레딧\\n• 매일 $dailyCredits크레딧 무료\\n\\n⭐ 자동충전 서비스:\\n• 월간 50크레딧 자동충전: ₩9,900 (월)\\n• 연간 100크레딧 자동충전: ₩99,900 (년)\\n• 편리한 자동충전 이용';
  }

  @override
  String get autoRechargeEnabled => '자동충전 활성화됨';

  @override
  String get useCredit => '크레딧 사용';

  @override
  String useFreeCredit(int count) {
    return '무료 크레딧 사용 (오늘 $count개 남음)';
  }

  @override
  String get usePaidCredit => '유료 크레딧 사용';

  @override
  String balanceAfterUse(int balance) {
    return '사용 후 잔액: $balance크레딧';
  }

  @override
  String get recipeCreated => '🎉 레시피가 성공적으로 생성되었습니다!';

  @override
  String get processingTranscript => '음성을 분석하고 레시피를 생성중입니다...';

  @override
  String processingCharacters(int count) {
    return '$count자의 내용을 처리 중입니다.';
  }

  @override
  String get offlineMode => '오프라인 모드';

  @override
  String get offlineRecipeCreation => '오프라인 상태에서는 새로운 레시피를 생성할 수 없습니다.';

  @override
  String get offlineVoiceRecognition => '음성 인식은 온라인에서만 사용할 수 있습니다.';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get loading => '로딩 중...';

  @override
  String get retry => '재시도';

  @override
  String get confirm => '확인';

  @override
  String get close => '닫기';

  @override
  String get recipeTitle => '레시피 제목';

  @override
  String get ingredients => '재료';

  @override
  String get instructions => '조리법';

  @override
  String get cookingTime => '조리 시간';

  @override
  String get servings => '인분';

  @override
  String get difficulty => '난이도';

  @override
  String get tags => '태그';

  @override
  String get tips => '팁';

  @override
  String get easy => '쉬움';

  @override
  String get medium => '보통';

  @override
  String get hard => '어려움';

  @override
  String get minutes => '분';

  @override
  String get hours => '시간';

  @override
  String servingsCount(int count) {
    return '$count인분';
  }

  @override
  String greetingWithName(String name) {
    return '안녕하세요, $name님!';
  }

  @override
  String get greetingDefault => '안녕하세요!';

  @override
  String get todayQuestion => '오늘은 어떤 요리를 기록해볼까요?';

  @override
  String get offline => '오프라인';

  @override
  String get quickStart => '빠른 시작';

  @override
  String get voiceRecording => '음성 녹음';

  @override
  String get newRecipeVoice => '새로운 레시피를 음성으로 기록하세요';

  @override
  String get ocrScan => 'OCR 스캔';

  @override
  String get extractFromImage => '이미지에서 레시피 추출';

  @override
  String get myRecipes => '내 레시피';

  @override
  String get viewSavedRecipes => '저장된 레시피 보기';

  @override
  String get recentRecipes => '최근 레시피';

  @override
  String get viewAll => '모두 보기';

  @override
  String get noRecipesYet => '아직 레시피가 없어요';

  @override
  String get recordFirstRecipe => '첫 번째 요리 레시피를 녹음해보세요!';

  @override
  String get myCookingRecord => '나의 요리 기록';

  @override
  String get totalRecipes => '총 레시피';

  @override
  String get recordingFiles => '녹음 파일';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get community => '커뮤니티';

  @override
  String get help => '도움말';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutConfirm => '정말로 로그아웃하시겠습니까?';

  @override
  String get logoutDialog => '로그아웃';

  @override
  String get offlineRecognition => '오프라인 상태입니다. 음성 인식은 온라인 상태에서만 가능합니다.';

  @override
  String get recognizing => '음성 인식 중';

  @override
  String get waiting => '대기 중';

  @override
  String accumulatedContent(int count) {
    return '누적된 내용 ($count자)';
  }

  @override
  String get initialize => '초기화';

  @override
  String get currentlyRecognizing => '현재 인식 중';

  @override
  String get listeningToVoice => '음성을 듣고 있습니다...';

  @override
  String get startVoiceRecognition => '음성 인식 버튼을 눌러 시작하세요';

  @override
  String get speakRecipeDetails => '요리법을 자세히 말씨해주세요';

  @override
  String get startVoiceRecognitionPrompt => '음성 인식을 시작하세요';

  @override
  String get includeIngredientsAndStepsLong => '재료, 조리법, 팁 등을 포함해서 말씨해주세요';

  @override
  String get allowMicrophonePermission => '마이크 권한을 허용하고 인식 버튼을 눌러주세요';

  @override
  String get createRecipeButton => '레시피\n작성';

  @override
  String get moreInstructionsVoice =>
      '더 추가하려면 음성 인식 버튼을, 완료하려면 레시피 작성 버튼을 눌러주세요';

  @override
  String get moreInstructionsVoiceAgain => '더 추가하려면 음성 인식 버튼을 다시 눌러주세요';

  @override
  String get processingAndGenerating => '음성을 분석하고 레시피를 생성하고 있습니다...';

  @override
  String processingCharactersCount(int count) {
    return '총 $count자의 내용을 처리 중입니다.';
  }

  @override
  String get creatingAccount => '계정을 생성하고 있습니다...';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get signupSubtitle => 'MOMENTO와 함께 소중한 요리법을 기록해보세요';

  @override
  String get nameOptional => '이름 (선택사항)';

  @override
  String get enterName => '이름을 입력해주세요';

  @override
  String get nameTooShort => '이름은 2글자 이상 입력해주세요';

  @override
  String get signupSuccess => '회원가입이 완료되었습니다!';

  @override
  String get signupFailed => '회원가입에 실패했습니다.';

  @override
  String get termsAndPrivacy =>
      '회원가입을 진행하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.';
}
