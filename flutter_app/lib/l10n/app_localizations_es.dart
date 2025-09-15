// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MOMENTO';

  @override
  String get appSubtitle => 'Registra las recetas de mamá con voz e IA';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get signup => 'Registrarse';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get signupButton => 'Crear Cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get enterEmail => 'Por favor introduce tu correo electrónico';

  @override
  String get enterPassword => 'Por favor introduce tu contraseña';

  @override
  String get invalidEmail => 'Por favor introduce un correo electrónico válido';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsNotMatch => 'Las contraseñas no coinciden';

  @override
  String get home => 'Inicio';

  @override
  String get recipes => 'Recetas';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configuración';

  @override
  String get createRecipe => 'Crear Receta';

  @override
  String get recordVoice => 'Grabar con Voz';

  @override
  String get recordVoiceSubtitle =>
      'Cuéntanos sobre tu proceso de cocina\\ny la IA lo organizará en una receta estructurada';

  @override
  String get scanImage => 'Escanear Imagen';

  @override
  String get scanImageSubtitle => 'Extraer texto\\nde una foto';

  @override
  String get textInput => 'Entrada de Texto';

  @override
  String get textInputSubtitle => 'Introducir notas/mensajes\\ndirectamente';

  @override
  String get urlInput => 'Entrada de URL';

  @override
  String get urlInputSubtitle => 'Extraer desde YouTube\\n/enlaces de blogs';

  @override
  String get startRecording => 'Iniciar Grabación';

  @override
  String get stopRecording => 'Detener Grabación';

  @override
  String get processing => 'Procesando...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get share => 'Compartir';

  @override
  String get voiceRecognition => 'Reconocimiento de Voz';

  @override
  String get listening => 'Escuchando tu voz...';

  @override
  String get waitingForVoice => 'Esperando entrada de voz';

  @override
  String get tapToStartRecording => 'Toca el botón del micrófono para comenzar';

  @override
  String get speakCookingInstructions =>
      'Por favor habla claramente tus instrucciones de cocina';

  @override
  String get includeIngredientsAndSteps =>
      'Incluye ingredientes, pasos de cocción y consejos';

  @override
  String get credits => 'Créditos';

  @override
  String get creditsRequired => 'Créditos Requeridos';

  @override
  String creditsRequiredMessage(String action) {
    return '$action requiere 1 crédito.';
  }

  @override
  String get currentCredits => 'Créditos Actuales';

  @override
  String get insufficientCredits => 'Créditos Insuficientes';

  @override
  String get creditShortage =>
      'No tienes suficientes créditos. Por favor compra créditos o espera por los créditos gratuitos diarios.';

  @override
  String freeCreditsRemaining(int count) {
    return '$count créditos gratuitos restantes (hoy)';
  }

  @override
  String get creditStore => 'Tienda de Créditos';

  @override
  String get purchaseCredits => 'Comprar Créditos';

  @override
  String get creditPackages => 'Paquetes de Créditos';

  @override
  String get autoRechargeSubscriptions => 'Suscripciones de Recarga Automática';

  @override
  String get starterPackage => 'Paquete Inicial';

  @override
  String get familyPackage => 'Paquete Familiar';

  @override
  String get premiumPackage => 'Paquete Premium';

  @override
  String get monthlyAutoRecharge => 'Recarga Automática Mensual';

  @override
  String get yearlyAutoRecharge => 'Recarga Automática Anual';

  @override
  String creditsAmount(int count) {
    return '$count créditos';
  }

  @override
  String price(String amount) {
    return '$amount';
  }

  @override
  String get creditStoreInfo => 'Guía de la Tienda de Créditos';

  @override
  String creditStoreDescription(int recipeGenCost, int recipeImproveCost,
      int initialCredits, int dailyCredits) {
    return 'Usa créditos para acceder al servicio de generación de recetas con IA.\\n\\n📝 Tarifas de Uso:\\n• Generación de recetas: $recipeGenCost crédito\\n• Mejora de recetas: $recipeImproveCost crédito\\n\\n🎁 Beneficios Gratuitos:\\n• Nuevo registro: $initialCredits créditos\\n• Diarios $dailyCredits créditos gratuitos\\n\\n⭐ Servicio de Recarga Automática:\\n• Recarga automática mensual de 50 créditos: €8.99 (mes)\\n• Recarga automática anual de 100 créditos: €89.99 (año)\\n• Uso conveniente de recarga automática';
  }

  @override
  String get autoRechargeEnabled => 'Recarga automática habilitada';

  @override
  String get useCredit => 'Usar Crédito';

  @override
  String useFreeCredit(int count) {
    return 'Usar crédito gratuito ($count restantes hoy)';
  }

  @override
  String get usePaidCredit => 'Usar crédito pagado';

  @override
  String balanceAfterUse(int balance) {
    return 'Saldo después del uso: $balance créditos';
  }

  @override
  String get recipeCreated => '🎉 ¡Receta creada exitosamente!';

  @override
  String get processingTranscript => 'Analizando voz y generando receta...';

  @override
  String processingCharacters(int count) {
    return 'Procesando $count caracteres de contenido.';
  }

  @override
  String get offlineMode => 'Modo sin conexión';

  @override
  String get offlineRecipeCreation =>
      'No se pueden crear nuevas recetas mientras está sin conexión.';

  @override
  String get offlineVoiceRecognition =>
      'El reconocimiento de voz solo está disponible en línea.';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get loading => 'Cargando...';

  @override
  String get retry => 'Reintentar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get recipeTitle => 'Título de la Receta';

  @override
  String get ingredients => 'Ingredientes';

  @override
  String get instructions => 'Instrucciones';

  @override
  String get cookingTime => 'Tiempo de Cocción';

  @override
  String get servings => 'Porciones';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get tags => 'Etiquetas';

  @override
  String get tips => 'Consejos';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get minutes => 'minutos';

  @override
  String get hours => 'horas';

  @override
  String servingsCount(int count) {
    return '$count porciones';
  }

  @override
  String greetingWithName(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get greetingDefault => '¡Hola!';

  @override
  String get todayQuestion => '¿Qué plato te gustaría registrar hoy?';

  @override
  String get offline => 'Sin conexión';

  @override
  String get quickStart => 'Inicio Rápido';

  @override
  String get voiceRecording => 'Grabación de Voz';

  @override
  String get newRecipeVoice => 'Grabar una nueva receta con voz';

  @override
  String get ocrScan => 'Escaneo OCR';

  @override
  String get extractFromImage => 'Extraer receta de imagen';

  @override
  String get myRecipes => 'Mis Recetas';

  @override
  String get viewSavedRecipes => 'Ver recetas guardadas';

  @override
  String get recentRecipes => 'Recetas Recientes';

  @override
  String get viewAll => 'Ver Todas';

  @override
  String get noRecipesYet => 'Aún no hay recetas';

  @override
  String get recordFirstRecipe => '¡Graba tu primera receta de cocina!';

  @override
  String get myCookingRecord => 'Mi Registro de Cocina';

  @override
  String get totalRecipes => 'Total de Recetas';

  @override
  String get recordingFiles => 'Archivos de Grabación';

  @override
  String get favorites => 'Favoritos';

  @override
  String get community => 'Comunidad';

  @override
  String get help => 'Ayuda';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get logoutDialog => 'Cerrar Sesión';

  @override
  String get offlineRecognition =>
      'Estás sin conexión. El reconocimiento de voz solo está disponible en línea.';

  @override
  String get recognizing => 'Reconociendo';

  @override
  String get waiting => 'Esperando';

  @override
  String accumulatedContent(int count) {
    return 'Contenido acumulado ($count caracteres)';
  }

  @override
  String get initialize => 'Inicializar';

  @override
  String get currentlyRecognizing => 'Reconociendo actualmente';

  @override
  String get listeningToVoice => 'Escuchando voz...';

  @override
  String get startVoiceRecognition =>
      'Presiona el botón de reconocimiento de voz para comenzar';

  @override
  String get speakRecipeDetails => 'Por favor habla los detalles de tu receta';

  @override
  String get startVoiceRecognitionPrompt => 'Iniciar reconocimiento de voz';

  @override
  String get includeIngredientsAndStepsLong =>
      'Por favor incluye ingredientes, pasos de cocción, consejos, etc.';

  @override
  String get allowMicrophonePermission =>
      'Por favor permite el permiso del micrófono y presiona el botón de reconocimiento';

  @override
  String get createRecipeButton => 'Crear\nReceta';

  @override
  String get moreInstructionsVoice =>
      'Presiona el botón de reconocimiento de voz para agregar más, o el botón crear receta para terminar';

  @override
  String get moreInstructionsVoiceAgain =>
      'Presiona el botón de reconocimiento de voz nuevamente para agregar más';

  @override
  String get processingAndGenerating => 'Analizando voz y generando receta...';

  @override
  String processingCharactersCount(int count) {
    return 'Procesando $count caracteres de contenido.';
  }

  @override
  String get creatingAccount => 'Creando cuenta...';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get signupSubtitle => 'Graba y comparte recetas preciosas con MOMENTO';

  @override
  String get nameOptional => 'Nombre (Opcional)';

  @override
  String get enterName => 'Por favor introduce tu nombre';

  @override
  String get nameTooShort => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get signupSuccess => '¡Cuenta creada exitosamente!';

  @override
  String get signupFailed => 'Error al crear la cuenta.';

  @override
  String get termsAndPrivacy =>
      'Al registrarte, aceptas nuestros Términos de Servicio y\nPolítica de Privacidad.';
}
