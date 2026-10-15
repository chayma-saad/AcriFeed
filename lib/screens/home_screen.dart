import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../services/alerts_service.dart';
import '../models/smart_alert.dart';
import 'charts_screen.dart';
import 'history_screen.dart' as activity_history; // Add prefix to avoid conflict
import 'chatbot_screen.dart';
import 'login_screen.dart';
import 'sensor_simulator_screen.dart';
import 'camera_history_screen.dart';
import '../widgets/dashboard_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  final AlertsService _alertsService = AlertsService();
  int _unreadAlertsCount = 0;
  StreamSubscription<List<SmartAlert>>? _alertsSubscription;

  // Consolidated localization
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'appTitle': 'AcriFeed',
      'dashboard': 'Dashboard',
      'analytics': 'Analytics',
      'history': 'History',
      'assistant': 'Assistant',
      'systemOnline': 'System Online',
      'connected': 'Connected',
      'updated': 'Updated',
      'smartAlerts': 'Smart Alerts',
      'allSystemsNormal': 'All Systems Normal',
      'noAlertsAtThisTime': 'No alerts at this time.',
      'languageChangedTo': 'Language changed to',
      'english': 'English',
      'french': 'Français',
      'arabic': 'العربية',
      'helpGettingStarted': 'Getting Started',
      'welcomeToAcriFeed': 'Welcome to AcriFeed!',
      'quickStartGuide': 'Quick Start Guide:',
      'monitorRealTime': '• Dashboard: Monitor real-time sensor data and system status',
      'viewCharts': '• Analytics: View detailed charts and data analysis',
      'browseHistory': '• History: Browse past sensor readings and events',
      'getHelp': '• Assistant: Get AI-powered recommendations and help',
      'useSimulator': '• Use the sensor simulator to test different conditions',
      'checkCamera': '• Check camera history for captured images',
      'monitorAlerts': '• Monitor smart alerts for system notifications',
      'switchLanguages': '• Switch languages using the language selector',
      'tip': '💡 Tip: Tap on any alert to mark it as read and get detailed information.',
      'gotIt': 'Got it!',
      'smartAgricultureMonitor': 'Smart Agriculture Monitor',
      'refreshData': 'Refresh Data',
      'refreshingData': 'Refreshing data...',
      'userMenu': 'User Menu',
      'logout': 'Logout',
      'selectLanguage': 'Select Language',
      'changeLanguage': 'Change Language',
      'language': 'Language',
      'notifications': 'Notifications',
      'sensorSimulator': 'Sensor Simulator',
      'cameraHistory': 'Camera History',
      'clearAlerts': 'Clear All Alerts',
    },
    'fr': {
      'appTitle': 'AcriFeed',
      'dashboard': 'Tableau de Bord',
      'analytics': 'Analyses',
      'history': 'Historique',
      'assistant': 'Assistant',
      'systemOnline': 'Système En Ligne',
      'connected': 'Connecté',
      'updated': 'Mis à Jour',
      'smartAlerts': 'Alertes Intelligentes',
      'allSystemsNormal': 'Tous les Systèmes Normaux',
      'noAlertsAtThisTime': 'Aucune alerte pour le moment.',
      'languageChangedTo': 'Langue changée en',
      'english': 'English',
      'french': 'Français',
      'arabic': 'العربية',
      'helpGettingStarted': 'Premiers Pas',
      'welcomeToAcriFeed': 'Bienvenue sur AcriFeed !',
      'quickStartGuide': 'Guide de Démarrage Rapide :',
      'monitorRealTime': '• Tableau de Bord : Surveillez les données des capteurs en temps réel et l\'état du système',
      'viewCharts': '• Analyses : Consultez des graphiques détaillés et des analyses de données',
      'browseHistory': '• Historique : Parcourez les relevés de capteurs passés et les événements',
      'getHelp': '• Assistant : Obtenez des recommandations alimentées par l\'IA et de l\'aide',
      'useSimulator': '• Utilisez le simulateur de capteurs pour tester différentes conditions',
      'checkCamera': '• Vérifiez l\'historique de la caméra pour les images capturées',
      'monitorAlerts': '• Surveillez les alertes intelligentes pour les notifications système',
      'switchLanguages': '• Changez de langue à l\'aide du sélecteur de langue',
      'tip': '💡 Conseil : Appuyez sur une alerte pour la marquer comme lue et obtenir des informations détaillées.',
      'gotIt': 'Compris !',
      'smartAgricultureMonitor': 'Moniteur Agricole Intelligent',
      'refreshData': 'Actualiser les Données',
      'refreshingData': 'Actualisation des données...',
      'userMenu': 'Menu Utilisateur',
      'logout': 'Déconnexion',
      'selectLanguage': 'Sélectionner la Langue',
      'changeLanguage': 'Changer de Langue',
      'language': 'Langue',
      'notifications': 'Notifications',
      'sensorSimulator': 'Simulateur de Capteurs',
      'cameraHistory': 'Historique de la Caméra',
      'clearAlerts': 'Effacer Toutes les Alertes',
    },
    'ar': {
      'appTitle': 'أكريفيد',
      'dashboard': 'لوحة التحكم',
      'analytics': 'التحليلات',
      'history': 'السجل',
      'assistant': 'المساعد',
      'systemOnline': 'النظام متصل',
      'connected': 'متصل',
      'updated': 'محدث',
      'smartAlerts': 'التنبيهات الذكية',
      'allSystemsNormal': 'جميع الأنظمة طبيعية',
      'noAlertsAtThisTime': 'لا توجد تنبيهات في الوقت الحالي.',
      'languageChangedTo': 'تم تغيير اللغة إلى',
      'english': 'English',
      'french': 'Français',
      'arabic': 'العربية',
      'helpGettingStarted': 'البدء',
      'welcomeToAcriFeed': 'مرحباً بك في أكريفيد!',
      'quickStartGuide': 'دليل البدء السريع:',
      'monitorRealTime': '• لوحة التحكم: مراقبة بيانات أجهزة الاستشعار في الوقت الفعلي وحالة النظام',
      'viewCharts': '• التحليلات: عرض الرسوم البيانية التفصيلية وتحليل البيانات',
      'browseHistory': '• السجل: تصفح قراءات أجهزة الاستشعار السابقة والأحداث',
      'getHelp': '• المساعد: الحصول على توصيات مدعومة بالذكاء الاصطناعي والمساعدة',
      'useSimulator': '• استخدم محاكي أجهزة الاستشعار لاختبار الظروف المختلفة',
      'checkCamera': '• تحقق من سجل الكاميرا للصور الملتقطة',
      'monitorAlerts': '• مراقبة التنبيهات الذكية لإشعارات النظام',
      'switchLanguages': '• تبديل اللغات باستخدام محدد اللغة',
      'tip': '💡 نصيحة: اضغط على أي تنبيه لتحديده كمقروء والحصول على معلومات مفصلة.',
      'gotIt': 'فهمت!',
      'smartAgricultureMonitor': 'مراقب الزراعة الذكية',
      'refreshData': 'تحديث البيانات',
      'refreshingData': 'جاري تحديث البيانات...',
      'userMenu': 'قائمة المستخدم',
      'logout': 'تسجيل الخروج',
      'selectLanguage': 'اختر اللغة',
      'changeLanguage': 'تغيير اللغة',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'sensorSimulator': 'محاكي أجهزة الاستشعار',
      'cameraHistory': 'سجل الكاميرا',
      'clearAlerts': 'مسح جميع التنبيهات',
    },
  };

  // Fixed screens list with proper import prefix
  final List<Widget> _screens = [
    const DashboardTab(),
    const ChartsScreen(),
    const activity_history.HistoryScreen(), // Use prefix to avoid conflict
    const ChatbotScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _alertsSubscription = _alertsService.alertsStream.listen(_updateUnreadCount);
    _updateUnreadCount(_alertsService.alerts);
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }

  void _updateUnreadCount(List<SmartAlert> alerts) {
    if (!mounted) return;
    final unreadCount = _alertsService.getUnreadAlerts().length;
    setState(() {
      _unreadAlertsCount = unreadCount;
    });
  }

  String _getLocalizedString(String key) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final locale = languageService.locale.languageCode;
    return _localizedStrings[locale]?[key] ?? _localizedStrings['en']?[key] ?? key;
  }

  // Unified action button builder
  Widget _buildActionButton({
    required IconData icon,
    required String tooltipKey,
    required VoidCallback onPressed,
    bool isCompact = false,
    Color? backgroundColor,
  }) {
    final size = isCompact ? 16.0 : 20.0;
    final padding = isCompact ? const EdgeInsets.all(6) : const EdgeInsets.all(8);
    final margin = isCompact ? const EdgeInsets.symmetric(horizontal: 2) : const EdgeInsets.symmetric(horizontal: 4);

    return Container(
      margin: margin,
      child: Tooltip(
        message: _getLocalizedString(tooltipKey),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  // Unified language switcher
  Widget _buildLanguageSwitcher({bool isCompact = false}) {
    return Consumer<LanguageService>(
      builder: (context, languageService, _) {
        final currentLocale = languageService.locale;
        final languageFlags = {'en': '🇺🇸', 'fr': '🇫🇷', 'ar': '🇸🇦'};
        final languageNames = {'en': 'English', 'fr': 'Français', 'ar': 'العربية'};

        if (isCompact) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: PopupMenuButton<Locale>(
              tooltip: _getLocalizedString('language'),
              onSelected: (locale) => _changeLanguage(locale, languageService),
              itemBuilder: (context) => [
                PopupMenuItem<Locale>(
                  enabled: false,
                  child: Text(
                    _getLocalizedString('selectLanguage'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const PopupMenuDivider(),
                ...['en', 'fr', 'ar'].map((langCode) {
                  final isSelected = currentLocale.languageCode == langCode;
                  return PopupMenuItem<Locale>(
                    value: Locale(langCode),
                    child: Row(
                      children: [
                        Text(_getLanguageFlag(langCode), style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(languageNames[langCode] ?? langCode),
                        if (isSelected) ...[
                          const Spacer(),
                          const Icon(Icons.check, color: Colors.green, size: 16),
                        ],
                      ],
                    ),
                  );
                }),
              ],
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  languageFlags[currentLocale.languageCode] ?? '🌐',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: PopupMenuButton<Locale>(
            tooltip: _getLocalizedString('changeLanguage'),
            onSelected: (locale) => _changeLanguage(locale, languageService),
            itemBuilder: (context) => [
              PopupMenuItem<Locale>(
                enabled: false,
                child: Text(
                  _getLocalizedString('selectLanguage'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuDivider(),
              ...['en', 'fr', 'ar'].map((langCode) {
                final isSelected = currentLocale.languageCode == langCode;
                return PopupMenuItem<Locale>(
                  value: Locale(langCode),
                  child: Row(
                    children: [
                      Text(_getLanguageFlag(langCode), style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(languageNames[langCode] ?? langCode),
                      if (isSelected) ...[
                        const Spacer(),
                        const Icon(Icons.check, color: Colors.green, size: 16),
                      ],
                    ],
                  ),
                );
              }),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(languageFlags[currentLocale.languageCode] ?? '🌐'),
                  const SizedBox(width: 4),
                  Text(
                    (languageNames[currentLocale.languageCode]?.substring(0, 2) ?? 'EN').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLanguageFlag(String langCode) {
    const flags = {'en': '🇺🇸', 'fr': '🇫🇷', 'ar': '🇸🇦'};
    return flags[langCode] ?? '🌐';
  }

  void _changeLanguage(Locale locale, LanguageService languageService) {
    languageService.setLanguage(locale);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getLocalizedString('languageChangedTo')} ${_getLocalizedString(locale.languageCode == 'en' ? 'english' : locale.languageCode == 'fr' ? 'french' : 'arabic')}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Unified notification button
  Widget _buildNotificationButton({bool isCompact = false}) {
    final hasUnread = _unreadAlertsCount > 0;
    final backgroundColor = hasUnread ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1);
    final iconColor = hasUnread ? Colors.red[100] : Colors.white;
    final size = isCompact ? 16.0 : 20.0;
    final padding = isCompact ? const EdgeInsets.all(6) : const EdgeInsets.all(8);
    final margin = isCompact ? const EdgeInsets.symmetric(horizontal: 2) : const EdgeInsets.symmetric(horizontal: 4);

    return Container(
      margin: margin,
      child: Badge(
        isLabelVisible: hasUnread,
        label: hasUnread
            ? Text(
          _unreadAlertsCount > 99 ? '99+' : '$_unreadAlertsCount',
          style: TextStyle(fontSize: isCompact ? 8 : 10),
        )
            : null,
        child: Tooltip(
          message: hasUnread
              ? '$_unreadAlertsCount ${_getLocalizedString('notifications')}'
              : _getLocalizedString('noAlertsAtThisTime'),
          child: InkWell(
            onTap: () => _showNotifications(context),
            borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
              ),
              child: Icon(
                hasUnread ? Icons.notifications_active : Icons.notifications_outlined,
                color: iconColor,
                size: size,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Unified user menu
  Widget _buildUserMenu({bool isCompact = false}) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final padding = isCompact ? const EdgeInsets.all(6) : const EdgeInsets.all(8);
        final margin = isCompact ? const EdgeInsets.only(left: 2) : const EdgeInsets.only(left: 4);
        final iconSize = isCompact ? 16.0 : 20.0;

        return Container(
          margin: margin,
          child: PopupMenuButton<String>(
            tooltip: _getLocalizedString('userMenu'),
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  authService.username ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(_getLocalizedString('logout'), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
              ),
              child: Icon(
                Icons.account_circle,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSystemStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Check if we have enough space for all items in a single row
          final hasEnoughSpace = constraints.maxWidth > 500;

          if (hasEnoughSpace) {
            // Single row layout for wider screens
            return Row(
              children: [
                _buildCompactStatusItem(
                  icon: Icons.circle,
                  color: Colors.green,
                  text: _getLocalizedString('systemOnline'),
                ),
                const SizedBox(width: 12),
                _buildCompactStatusItem(
                  icon: Icons.wifi,
                  color: Colors.blue.shade600,
                  text: _getLocalizedString('connected'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactStatusItem(
                    icon: Icons.access_time,
                    color: Colors.grey.shade600,
                    text: '${_getLocalizedString('updated')} ${_getLastUpdateTime()}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  tooltip: _getLocalizedString('refreshData'),
                  onPressed: _refreshData,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            );
          } else {
            // Stacked layout for narrower screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Status indicators
                Row(
                  children: [
                    _buildCompactStatusItem(
                      icon: Icons.circle,
                      color: Colors.green,
                      text: _getLocalizedString('systemOnline'),
                    ),
                    const SizedBox(width: 12),
                    _buildCompactStatusItem(
                      icon: Icons.wifi,
                      color: Colors.blue.shade600,
                      text: _getLocalizedString('connected'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Second row: Time and refresh button
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStatusItem(
                        icon: Icons.access_time,
                        color: Colors.grey.shade600,
                        text: '${_getLocalizedString('updated')} ${_getLastUpdateTime()}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16),
                      tooltip: _getLocalizedString('refreshData'),
                      onPressed: _refreshData,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCompactStatusItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getLastUpdateTime() {
    // TODO: Get actual last update time from service
    return '2 min ago';
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_getLocalizedString('refreshingData'))),
    );
  }

  Widget _buildFloatingHelpButton() {
    return FloatingActionButton(
      onPressed: () => _showHelpDialog(context),
      tooltip: _getLocalizedString('helpGettingStarted'),
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.help_outline),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(_getLocalizedString('helpGettingStarted')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getLocalizedString('welcomeToAcriFeed'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(_getLocalizedString('quickStartGuide'), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_getLocalizedString('monitorRealTime')),
              Text(_getLocalizedString('viewCharts')),
              Text(_getLocalizedString('browseHistory')),
              Text(_getLocalizedString('getHelp')),
              const SizedBox(height: 16),
              Text(_getLocalizedString('useSimulator')),
              Text(_getLocalizedString('checkCamera')),
              Text(_getLocalizedString('monitorAlerts')),
              Text(_getLocalizedString('switchLanguages')),
              const SizedBox(height: 16),
              Text(
                _getLocalizedString('tip'),
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedString('gotIt')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: _buildFloatingHelpButton(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // App Logo and Title
                  _buildAppHeader(),
                  const Spacer(),
                  // Compact Action Buttons
                  _buildCompactActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSystemStatusBar(),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildAppHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.agriculture, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLocalizedString('appTitle'),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _getLocalizedString('smartAgricultureMonitor'),
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available space for buttons (accounting for logo/title)
        final availableWidth = MediaQuery.of(context).size.width - 200; // Reserve space for logo
        final maxButtonWidth = availableWidth * 0.7; // Use 70% of available space

        return Container(
          constraints: BoxConstraints(
            maxWidth: maxButtonWidth.clamp(200, 400), // Min 200px, max 400px
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: Icons.science_outlined,
                  tooltipKey: 'sensorSimulator',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SensorSimulatorScreen())),
                  isCompact: true,
                ),
                _buildActionButton(
                  icon: Icons.video_library_outlined,
                  tooltipKey: 'cameraHistory',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraHistoryScreen())),
                  isCompact: true,
                ),
                _buildLanguageSwitcher(isCompact: true),
                _buildNotificationButton(isCompact: true),
                _buildUserMenu(isCompact: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: _buildNavigationDestinations(theme),
      ),
    );
  }

  List<NavigationDestination> _buildNavigationDestinations(ThemeData theme) {
    return [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.dashboard, color: theme.primaryColor),
        ),
        label: _getLocalizedString('dashboard'),
        tooltip: 'Monitor current system status and real-time data',
      ),
      NavigationDestination(
        icon: const Icon(Icons.show_chart_outlined),
        selectedIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.show_chart, color: theme.primaryColor),
        ),
        label: _getLocalizedString('analytics'),
        tooltip: 'View detailed charts and data analysis',
      ),
      NavigationDestination(
        icon: const Icon(Icons.history_outlined),
        selectedIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.history, color: theme.primaryColor),
        ),
        label: _getLocalizedString('history'),
        tooltip: 'Browse historical data and past events',
      ),
      NavigationDestination(
        icon: const Icon(Icons.smart_toy_outlined),
        selectedIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.smart_toy, color: theme.primaryColor),
        ),
        label: _getLocalizedString('assistant'),
        tooltip: 'Get help and AI-powered recommendations',
      ),
    ];
  }

  void _showNotifications(BuildContext context) {
    final alerts = _alertsService.alerts;
    final unreadAlerts = _alertsService.getUnreadAlerts();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.deepOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedString('smartAlerts'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${alerts.length} total • ${unreadAlerts.length} unread',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unreadAlerts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${unreadAlerts.length} new',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Filter Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('All Alerts'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Unread (${unreadAlerts.length})',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Content Area
              Expanded(
                child: alerts.isEmpty
                    ? _buildEmptyAlertsState()
                    : _buildAlertsList(alerts, unreadAlerts),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (alerts.isNotEmpty) ...[
                    TextButton.icon(
                      onPressed: () {
                        _alertsService.clearAlerts();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_getLocalizedString('clearAlerts')),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.clear_all),
                      label: Text(_getLocalizedString('clearAlerts')),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAlertsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getLocalizedString('allSystemsNormal'),
            style: const TextStyle(
              color: Colors.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLocalizedString('noAlertsAtThisTime'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to system diagnostics
            },
            icon: const Icon(Icons.health_and_safety),
            label: const Text('View System Health'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<SmartAlert> alerts, List<SmartAlert> unreadAlerts) {
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final isUnread = unreadAlerts.contains(alert);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: alert.color.withAlpha(51),
              width: 1,
            ),
            color: isUnread ? alert.color.withAlpha(13) : Colors.white,
            boxShadow: isUnread
                ? [
              BoxShadow(
                color: alert.color.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _alertsService.markAlertAsRead(alert.id);
              setState(() {}); // Refresh to update unread count
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(alert.icon, color: alert.color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(alert.message)),
                    ],
                  ),
                  backgroundColor: alert.color,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'View Details',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Show detailed alert view
                    },
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert Icon with Status Indicator
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: alert.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          alert.icon,
                          color: alert.color,
                          size: 24,
                        ),
                      ),
                      if (isUnread)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Alert Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                  color: alert.color,
                                ),
                              ),
                            ),
                            Text(
                              _formatTimestamp(alert.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: alert.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'New Alert',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Action Arrow
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardWidget();
  }
}