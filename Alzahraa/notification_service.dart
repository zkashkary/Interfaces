// استيراد المكتبات المطلوبة
// Import required libraries
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// خدمة الإشعارات المحلية
/// Local Notification Service
///
/// هذه الكلاس مسؤولة عن:
/// - تهيئة نظام الإشعارات
/// - جدولة تذكيرات الري والضوء
/// - إلغاء الإشعارات
///
/// This class is responsible for:
/// - Initializing the notification system
/// - Scheduling water and light reminders
/// - Cancelling notifications
class NotificationService {
  // متغير ثابت لمكون الإشعارات المحلية
  // Static variable for local notifications plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// تهيئة نظام الإشعارات
  /// Initialize the notification system
  ///
  /// هذه الدالة تستدعى مرة واحدة عند بدء التطبيق
  /// This function is called once when the app starts
  static Future<void> initialize() async {
    // إعدادات تهيئة Android
    // Android initialization settings
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات تهيئة iOS
    // iOS initialization settings
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true, // طلب إذن التنبيهات
      requestBadgePermission: true, // طلب إذن العلامات
      requestSoundPermission: true, // طلب إذن الصوت
    );

    // إعدادات موحدة لكلا المنصتين
    // Unified settings for both platforms
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // تهيئة مكون الإشعارات
    // Initialize the notifications plugin
    await _notificationsPlugin.initialize(
      initSettings,
      // دالة يتم استدعاؤها عند الضغط على الإشعار
      // Function called when notification is tapped
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );

    // طلب الأذونات المطلوبة (Android 13+ و iOS)
    // Request required permissions (Android 13+ and iOS)
    await requestPermissions();
  }

  /// طلب الأذونات المطلوبة للإشعارات
  /// Request required permissions for notifications
  ///
  /// - Android: يطلب إذن الإشعارات وإذن المنبهات الدقيقة
  /// - iOS: يطلب أذونات التنبيهات والعلامات والصوت
  ///
  /// - Android: Requests notification permission and exact alarm permission
  /// - iOS: Requests alert, badge, and sound permissions
  static Future<void> requestPermissions() async {
    // التحقق من المنصة الحالية
    // Check current platform
    if (defaultTargetPlatform == TargetPlatform.android) {
      // الحصول على تطبيق Android المخصص
      // Get Android-specific implementation
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // طلب إذن الإشعارات (Android 13+)
        // Request notification permission (Android 13+)
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Android notification permission granted: $granted');

        // طلب إذن المنبهات الدقيقة (Android 12+)
        // Request exact alarm permission (Android 12+)
        // هذا ضروري للإشعارات المتكررة بدقة
        // This is required for precise recurring notifications
        await androidPlugin.requestExactAlarmsPermission();
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // الحصول على تطبيق iOS المخصص
      // Get iOS-specific implementation
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        // طلب أذونات iOS
        // Request iOS permissions
        final granted = await iosPlugin.requestPermissions(
          alert: true, // تنبيهات
          badge: true, // علامات
          sound: true, // صوت
        );
        debugPrint('iOS notification permission granted: $granted');
      }
    }
  }

  /// جدولة تذكير الري
  /// Schedule water reminder
  ///
  /// [level] - مستوى الري: 'low', 'medium', 'bright' أو 'high'
  /// [plantId] - معرف النبات (اختياري)
  /// [plantName] - اسم النبات (اختياري)
  ///
  /// الفترات:
  /// - Low: كل دقيقة (Every minute)
  /// - Medium: كل ساعة (Hourly)
  /// - Bright/High: كل يوم (Daily)
  ///
  /// [level] - Water level: 'low', 'medium', 'bright' or 'high'
  /// [plantId] - Plant ID (optional)
  /// [plantName] - Plant name (optional)
  ///
  /// Intervals:
  /// - Low: Every minute
  /// - Medium: Hourly
  /// - Bright/High: Daily
  static Future<void> triggerWaterReminder(
    String level, {
    int? plantId,
    String? plantName,
  }) async {
    // عنوان الإشعار
    // Notification title
    String title = '💧 Watering Reminder';

    // نص الإشعار (سيتم تعبئته حسب المستوى)
    // Notification body (will be filled based on level)
    String body = '';

    // معرف أساسي لإشعارات الري (1000)
    // Base ID for water reminders (1000)
    int baseId = 1000;

    // متغير لتخزين فترة التكرار
    // Variable to store repeat interval
    RepeatInterval repeatInterval;

    // تحويل المستوى إلى أحرف صغيرة للمقارنة
    // Convert level to lowercase for comparison
    final lowerLevel = level.toLowerCase();

    // اسم النبات للعرض (إذا لم يتم توفيره، استخدم 'your plant')
    // Plant name for display (if not provided, use 'your plant')
    final displayName = plantName ?? 'your plant';

    // تحديد فترة التكرار حسب المستوى
    // Set repeat interval based on level
    // الفترات: دقيقة، ساعة، يوم
    // Intervals: minute, hour, day
    if (lowerLevel == 'low') {
      // Low = كل دقيقة
      // Low = Every minute
      repeatInterval = RepeatInterval.everyMinute;
      body = 'Time to water $displayName (Every minute - LOW need)';
      baseId += 1; // ID = 1001
    } else if (lowerLevel == 'medium') {
      // Medium = كل ساعة
      // Medium = Hourly
      repeatInterval = RepeatInterval.hourly;
      body = 'Time to water $displayName (Hourly - MEDIUM need)';
      baseId += 2; // ID = 1002
    } else if (lowerLevel == 'bright' || lowerLevel == 'high') {
      // Bright/High = كل يوم
      // Bright/High = Daily
      repeatInterval = RepeatInterval.daily;
      body = 'Time to water $displayName (Daily - HIGH need)';
      baseId += 3; // ID = 1003
    } else {
      // مستوى غير صحيح
      // Invalid level
      debugPrint('Invalid water level provided: $level');
      return;
    }

    // إنشاء معرف فريد للإشعار
    // Generate unique notification ID
    // إذا كان هناك plantId، أضفه إلى baseId
    // If plantId exists, add it to baseId
    // مثال: baseId=1001, plantId=5 → id=1006
    // Example: baseId=1001, plantId=5 → id=1006
    int id = plantId != null ? baseId + plantId : baseId;

    // إعدادات الإشعار لـ Android
    // Android notification settings
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'water_channel', // معرف القناة
          'Plant Watering', // اسم القناة
          channelDescription: 'Reminders for plant watering frequency.',
          importance: Importance.max, // أهمية عالية
          priority: Priority.high, // أولوية عالية
        );

    // إعدادات الإشعار لـ iOS
    // iOS notification settings
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    // إعدادات موحدة لكلا المنصتين
    // Unified settings for both platforms
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // إلغاء الإشعار القديم (إن وجد) لتجنب التكرار
    // Cancel old notification (if exists) to avoid duplicates
    await _notificationsPlugin.cancel(id);

    // جدولة إشعار متكرر جديد
    // Schedule new recurring notification
    // periodicallyShow: جدولة إشعار يتكرر تلقائياً
    // periodicallyShow: Schedule a notification that repeats automatically
    await _notificationsPlugin.periodicallyShow(
      id, // معرف الإشعار
      title, // العنوان
      body, // النص
      repeatInterval, // فترة التكرار (دقيقة/ساعة/يوم)
      platformDetails, // الإعدادات
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // وضع دقيق حتى في وضع السكون
    );

    // طباعة رسالة تأكيد في Console
    // Print confirmation message in Console
    debugPrint(
      '✅ Water Reminder ($level) scheduled to repeat ${repeatInterval.toString().split('.').last}!',
    );
  }

  /// جدولة تذكير الإضاءة
  /// Schedule light reminder
  ///
  /// [level] - مستوى الإضاءة: 'low', 'medium', 'bright' أو 'high'
  /// [plantId] - معرف النبات (اختياري)
  /// [plantName] - اسم النبات (اختياري)
  ///
  /// الفترات (نفس فترات الري):
  /// - Low: كل دقيقة (Every minute)
  /// - Medium: كل ساعة (Hourly)
  /// - Bright/High: كل يوم (Daily)
  ///
  /// [level] - Light level: 'low', 'medium', 'bright' or 'high'
  /// [plantId] - Plant ID (optional)
  /// [plantName] - Plant name (optional)
  ///
  /// Intervals (same as water):
  /// - Low: Every minute
  /// - Medium: Hourly
  /// - Bright/High: Daily
  static Future<void> triggerLightReminder(
    String level, {
    int? plantId,
    String? plantName,
  }) async {
    // عنوان الإشعار
    // Notification title
    String title = '☀️ Light Reminder';

    // نص الإشعار (سيتم تعبئته حسب المستوى)
    // Notification body (will be filled based on level)
    String body = '';

    // معرف أساسي لإشعارات الإضاءة (2000)
    // Base ID for light reminders (2000)
    int baseId = 2000;

    // متغير لتخزين فترة التكرار
    // Variable to store repeat interval
    RepeatInterval repeatInterval;

    // تحويل المستوى إلى أحرف صغيرة للمقارنة
    // Convert level to lowercase for comparison
    final lowerLevel = level.toLowerCase();

    // اسم النبات للعرض (إذا لم يتم توفيره، استخدم 'your plant')
    // Plant name for display (if not provided, use 'your plant')
    final displayName = plantName ?? 'your plant';

    // تحديد فترة التكرار حسب المستوى
    // Set repeat interval based on level
    // الفترات: دقيقة، ساعة، يوم (نفس فترات الري)
    // Intervals: minute, hour, day (same as water)
    if (lowerLevel == 'low') {
      // Low = كل دقيقة
      // Low = Every minute
      repeatInterval = RepeatInterval.everyMinute;
      body = 'Check light for $displayName (Every minute - LOW-light plant)';
      baseId += 1; // ID = 2001
    } else if (lowerLevel == 'medium') {
      // Medium = كل ساعة
      // Medium = Hourly
      repeatInterval = RepeatInterval.hourly;
      body = 'Check light for $displayName (Hourly - MEDIUM-light plant)';
      baseId += 2; // ID = 2002
    } else if (lowerLevel == 'bright' || lowerLevel == 'high') {
      // Bright/High = كل يوم
      // Bright/High = Daily
      repeatInterval = RepeatInterval.daily;
      body = 'Check light for $displayName (Daily - HIGH-light plant)';
      baseId += 3; // ID = 2003
    } else {
      // مستوى غير صحيح
      // Invalid level
      debugPrint('Invalid light level provided: $level');
      return;
    }

    // إنشاء معرف فريد للإشعار
    // Generate unique notification ID
    // إذا كان هناك plantId، أضفه إلى baseId
    // If plantId exists, add it to baseId
    // مثال: baseId=2001, plantId=5 → id=2006
    // Example: baseId=2001, plantId=5 → id=2006
    int id = plantId != null ? baseId + plantId : baseId;

    // إعدادات الإشعار لـ Android
    // Android notification settings
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'light_channel', // معرف القناة
          'Plant Light', // اسم القناة
          channelDescription: 'Reminders for plant light frequency.',
          importance: Importance.max, // أهمية عالية
          priority: Priority.high, // أولوية عالية
        );

    // إعدادات الإشعار لـ iOS
    // iOS notification settings
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    // إعدادات موحدة لكلا المنصتين
    // Unified settings for both platforms
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // إلغاء الإشعار القديم (إن وجد) لتجنب التكرار
    // Cancel old notification (if exists) to avoid duplicates
    await _notificationsPlugin.cancel(id);

    // جدولة إشعار متكرر جديد
    // Schedule new recurring notification
    // periodicallyShow: جدولة إشعار يتكرر تلقائياً
    // periodicallyShow: Schedule a notification that repeats automatically
    await _notificationsPlugin.periodicallyShow(
      id, // معرف الإشعار
      title, // العنوان
      body, // النص
      repeatInterval, // فترة التكرار (دقيقة/ساعة/يوم)
      platformDetails, // الإعدادات
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // وضع دقيق حتى في وضع السكون
    );

    // طباعة رسالة تأكيد في Console
    // Print confirmation message in Console
    debugPrint(
      '✅ Light Reminder ($level) scheduled to repeat ${repeatInterval.toString().split('.').last}!',
    );
  }

  /// إلغاء جميع الإشعارات لنبات محدد
  /// Cancel all notifications for a specific plant
  ///
  /// [plantId] - معرف النبات المراد إلغاء إشعاراته
  ///
  /// هذه الدالة تلغي جميع الإشعارات الممكنة لهذا النبات:
  /// - إشعارات الري: 1001, 1002, 1003 + plantId
  /// - إشعارات الإضاءة: 2001, 2002, 2003 + plantId
  ///
  /// [plantId] - ID of the plant whose notifications should be cancelled
  ///
  /// This function cancels all possible notifications for this plant:
  /// - Water notifications: 1001, 1002, 1003 + plantId
  /// - Light notifications: 2001, 2002, 2003 + plantId
  static Future<void> cancelPlantNotifications(int plantId) async {
    // إلغاء جميع الإشعارات الممكنة لهذا النبات
    // Cancel all possible notifications for this plant

    // الحلقة تمر على جميع المستويات (1, 2, 3)
    // Loop through all levels (1, 2, 3)
    // i=1 → Low (كل دقيقة)
    // i=2 → Medium (كل ساعة)
    // i=3 → Bright/High (كل يوم)
    for (int i = 1; i <= 3; i++) {
      // إلغاء إشعار الري: 1000 + i + plantId
      // Cancel water notification: 1000 + i + plantId
      // مثال: plantId=5, i=1 → 1000+1+5 = 1006
      // Example: plantId=5, i=1 → 1000+1+5 = 1006
      await _notificationsPlugin.cancel(1000 + i + plantId);

      // إلغاء إشعار الإضاءة: 2000 + i + plantId
      // Cancel light notification: 2000 + i + plantId
      // مثال: plantId=5, i=1 → 2000+1+5 = 2006
      // Example: plantId=5, i=1 → 2000+1+5 = 2006
      await _notificationsPlugin.cancel(2000 + i + plantId);
    }

    // طباعة رسالة تأكيد
    // Print confirmation message
    debugPrint('🗑️ Cancelled notifications for plant ID: $plantId');
  }

  /// إلغاء جميع الإشعارات في التطبيق
  /// Cancel all notifications in the app
  ///
  /// هذه الدالة تلغي جميع الإشعارات المجدولة
  /// This function cancels all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    // إلغاء جميع الإشعارات
    // Cancel all notifications
    await _notificationsPlugin.cancelAll();

    // طباعة رسالة تأكيد
    // Print confirmation message
    debugPrint('🗑️ All notifications cancelled');
  }
}
