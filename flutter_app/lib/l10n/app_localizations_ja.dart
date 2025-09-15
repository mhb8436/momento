// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'MOMENTO';

  @override
  String get appSubtitle => 'お母さんのレシピを音声とAIで記録しましょう';

  @override
  String get login => 'ログイン';

  @override
  String get signup => 'サインアップ';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get loginButton => 'ログイン';

  @override
  String get signupButton => 'アカウント作成';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？';

  @override
  String get enterEmail => 'メールアドレスを入力してください';

  @override
  String get enterPassword => 'パスワードを入力してください';

  @override
  String get invalidEmail => '正しいメールアドレスを入力してください';

  @override
  String get passwordTooShort => 'パスワードは6文字以上である必要があります';

  @override
  String get passwordsNotMatch => 'パスワードが一致しません';

  @override
  String get home => 'ホーム';

  @override
  String get recipes => 'レシピ';

  @override
  String get profile => 'プロフィール';

  @override
  String get settings => '設定';

  @override
  String get createRecipe => 'レシピ作成';

  @override
  String get recordVoice => '音声で記録';

  @override
  String get recordVoiceSubtitle => '料理の過程を話していただければ\\nAIが構造化されたレシピに整理します';

  @override
  String get scanImage => '画像スキャン';

  @override
  String get scanImageSubtitle => '写真からテキストを\\n抽出する';

  @override
  String get textInput => 'テキスト入力';

  @override
  String get textInputSubtitle => 'メモ・メッセージを\\n直接入力';

  @override
  String get urlInput => 'URL入力';

  @override
  String get urlInputSubtitle => 'YouTube・ブログ\\nリンクから抽出';

  @override
  String get startRecording => '録音開始';

  @override
  String get stopRecording => '録音停止';

  @override
  String get processing => '処理中...';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get share => '共有';

  @override
  String get voiceRecognition => '音声認識';

  @override
  String get listening => '音声を聞いています...';

  @override
  String get waitingForVoice => '音声入力待機';

  @override
  String get tapToStartRecording => 'マイクボタンを押して開始してください';

  @override
  String get speakCookingInstructions => '料理法を明確に話してください';

  @override
  String get includeIngredientsAndSteps => '材料、調理過程、コツを含めてください';

  @override
  String get credits => 'クレジット';

  @override
  String get creditsRequired => 'クレジット必要';

  @override
  String creditsRequiredMessage(String action) {
    return '$actionには1クレジットが必要です。';
  }

  @override
  String get currentCredits => '現在のクレジット';

  @override
  String get insufficientCredits => 'クレジット不足';

  @override
  String get creditShortage => 'クレジットが不足しています。クレジットを購入するか、無料クレジットをお待ちください。';

  @override
  String freeCreditsRemaining(int count) {
    return '残り無料クレジット$count個（今日）';
  }

  @override
  String get creditStore => 'クレジットストア';

  @override
  String get purchaseCredits => 'クレジット購入';

  @override
  String get creditPackages => 'クレジットパッケージ';

  @override
  String get autoRechargeSubscriptions => '自動充電サブスクリプション';

  @override
  String get starterPackage => 'スターターパッケージ';

  @override
  String get familyPackage => 'ファミリーパッケージ';

  @override
  String get premiumPackage => 'プレミアムパッケージ';

  @override
  String get monthlyAutoRecharge => '月間自動充電';

  @override
  String get yearlyAutoRecharge => '年間自動充電';

  @override
  String creditsAmount(int count) {
    return '$countクレジット';
  }

  @override
  String price(String amount) {
    return '$amount';
  }

  @override
  String get creditStoreInfo => 'クレジットストア案内';

  @override
  String creditStoreDescription(int recipeGenCost, int recipeImproveCost,
      int initialCredits, int dailyCredits) {
    return 'クレジットを使用してAIレシピ生成サービスをご利用ください。\\n\\n📝 利用料金：\\n• レシピ生成：$recipeGenCostクレジット\\n• レシピ改善：$recipeImproveCostクレジット\\n\\n🎁 無料特典：\\n• 新規登録：$initialCreditsクレジット\\n• 毎日$dailyCreditsクレジット無料\\n\\n⭐ 自動充電サービス：\\n• 月間50クレジット自動充電：¥990（月）\\n• 年間100クレジット自動充電：¥9,900（年）\\n• 便利な自動充電利用';
  }

  @override
  String get autoRechargeEnabled => '自動充電有効';

  @override
  String get useCredit => 'クレジット使用';

  @override
  String useFreeCredit(int count) {
    return '無料クレジット使用（今日$count個残り）';
  }

  @override
  String get usePaidCredit => '有料クレジット使用';

  @override
  String balanceAfterUse(int balance) {
    return '使用後残高：$balanceクレジット';
  }

  @override
  String get recipeCreated => '🎉 レシピが正常に作成されました！';

  @override
  String get processingTranscript => '音声を分析してレシピを生成中です...';

  @override
  String processingCharacters(int count) {
    return '$count文字のコンテンツを処理中です。';
  }

  @override
  String get offlineMode => 'オフラインモード';

  @override
  String get offlineRecipeCreation => 'オフライン状態では新しいレシピを作成できません。';

  @override
  String get offlineVoiceRecognition => '音声認識はオンラインでのみ利用できます。';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get loading => '読み込み中...';

  @override
  String get retry => '再試行';

  @override
  String get confirm => '確認';

  @override
  String get close => '閉じる';

  @override
  String get recipeTitle => 'レシピタイトル';

  @override
  String get ingredients => '材料';

  @override
  String get instructions => '作り方';

  @override
  String get cookingTime => '調理時間';

  @override
  String get servings => '人分';

  @override
  String get difficulty => '難易度';

  @override
  String get tags => 'タグ';

  @override
  String get tips => 'コツ';

  @override
  String get easy => '簡単';

  @override
  String get medium => '普通';

  @override
  String get hard => '難しい';

  @override
  String get minutes => '分';

  @override
  String get hours => '時間';

  @override
  String servingsCount(int count) {
    return '$count人分';
  }

  @override
  String greetingWithName(String name) {
    return 'こんにちは、$nameさん！';
  }

  @override
  String get greetingDefault => 'こんにちは！';

  @override
  String get todayQuestion => '今日はどんな料理を記録しましょうか？';

  @override
  String get offline => 'オフライン';

  @override
  String get quickStart => 'クイックスタート';

  @override
  String get voiceRecording => '音声録音';

  @override
  String get newRecipeVoice => '新しいレシピを音声で記録してください';

  @override
  String get ocrScan => 'OCRスキャン';

  @override
  String get extractFromImage => '画像からレシピを抽出';

  @override
  String get myRecipes => '私のレシピ';

  @override
  String get viewSavedRecipes => '保存されたレシピを表示';

  @override
  String get recentRecipes => '最近のレシピ';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get noRecipesYet => 'まだレシピがありません';

  @override
  String get recordFirstRecipe => '初めての料理レシピを録音してみましょう！';

  @override
  String get myCookingRecord => '私の料理記録';

  @override
  String get totalRecipes => '総レシピ数';

  @override
  String get recordingFiles => '録音ファイル';

  @override
  String get favorites => 'お気に入り';

  @override
  String get community => 'コミュニティ';

  @override
  String get help => 'ヘルプ';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => '本当にログアウトしますか？';

  @override
  String get logoutDialog => 'ログアウト';

  @override
  String get offlineRecognition => 'オフライン状態です。音声認識はオンラインでのみ利用できます。';

  @override
  String get recognizing => '認識中';

  @override
  String get waiting => '待機中';

  @override
  String accumulatedContent(int count) {
    return '累積された内容（$count文字）';
  }

  @override
  String get initialize => '初期化';

  @override
  String get currentlyRecognizing => '現在認識中';

  @override
  String get listeningToVoice => '音声を聞いています...';

  @override
  String get startVoiceRecognition => '音壵認識ボタンを押して始めてください';

  @override
  String get speakRecipeDetails => 'レシピの詳細を話してください';

  @override
  String get startVoiceRecognitionPrompt => '音壷認識を開始';

  @override
  String get includeIngredientsAndStepsLong => '材料、調理手順、コツなどを含めて話してください';

  @override
  String get allowMicrophonePermission => 'マイク権限を許可し、認識ボタンを押してください';

  @override
  String get createRecipeButton => 'レシピ\n作成';

  @override
  String get moreInstructionsVoice =>
      'さらに追加するには音壷認識ボタンを、完了するにはレシピ作成ボタンを押してください';

  @override
  String get moreInstructionsVoiceAgain => 'さらに追加するには音壵認識ボタンを再び押してください';

  @override
  String get processingAndGenerating => '音壷を分析してレシピを生成中です...';

  @override
  String processingCharactersCount(int count) {
    return '合計$count文字のコンテンツを処理中です。';
  }

  @override
  String get creatingAccount => 'アカウントを作成中です...';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get signupSubtitle => 'MOMENTOで大切なレシピを記録して共有しましょう';

  @override
  String get nameOptional => 'お名前（任意）';

  @override
  String get enterName => 'お名前を入力してください';

  @override
  String get nameTooShort => '名前は2文字以上で入力してください';

  @override
  String get signupSuccess => 'アカウントが正常に作成されました！';

  @override
  String get signupFailed => 'アカウント作成に失敗しました。';

  @override
  String get termsAndPrivacy => 'サインアップすることで、利用規約および\nプライバシーポリシーに同意したことになります。';
}
