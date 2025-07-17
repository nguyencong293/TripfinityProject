import 'package:app/constants/app_constants.dart';
import 'package:app/services/localization_service.dart';
import 'package:app/widgets/language_switcher.dart';
import 'package:app/widgets/theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/language_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final langController = LanguageController();
  await langController.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => langController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageController>(
      builder: (context, themeProvider, langController, child) {
        return MaterialApp(
          title: 'TripFinity App Project',
          locale: Locale(langController.currentLanguage),
          supportedLocales: langController.languages.keys
              .map((code) => Locale(code))
              .toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.flutterThemeMode,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('theme_text_style_system'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Controls Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('theme_controls'.tr, style: context.subTitleOneStyle),
                    const SizedBox(height: 16),

                    // Theme Dropdown
                    const ThemeModeDropdown(width: 200),
                    const SizedBox(height: 12),
                    const LanguageDropdownCard(width: 200),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Counter Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('counter_demo'.tr, style: context.subTitleOneStyle),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'you_have_pushed'.tr,
                            style: context.bodyOneStyle,
                          ),
                          const SizedBox(height: 8),
                          Text('$_counter', style: context.subTitleTwoStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Text Styles Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Styles Preview',
                      style: context.subTitleTwoStyle,
                    ),
                    const SizedBox(height: 16),

                    Text('Display Large', style: context.displayHeroStyle),

                    const SizedBox(height: 16),

                    Text('Mobile H1', style: context.h1Style),
                    Text('Mobile H2', style: context.h2Style),
                    Text('Mobile H3', style: context.h3Style),
                    Text('Mobile Body 1', style: context.bodyOneStyle),
                    Text('Mobile Caption', style: context.bodyTwoStyle),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
