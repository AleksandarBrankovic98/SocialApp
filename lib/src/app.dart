import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shnatter/src/controllers/PostController.dart';
import 'package:shnatter/src/helpers/helper.dart';
import 'package:shnatter/src/routes/route_generator.dart';
import 'package:shnatter/src/routes/route_names.dart';
import 'package:shnatter/src/utils/colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/AppController.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'controllers/SearcherController.dart';
import 'controllers/UserController.dart';
import 'models/setting.dart';

class MyApp extends AppStatefulWidgetMVC {
  const MyApp({Key? key}) : super(key: key);

  /// This is the App's State object
  @override
  AppStateMVC createState() => _MyAppState();
}

class _MyAppState extends AppStateMVC<MyApp> with WidgetsBindingObserver {
  factory _MyAppState() => _this ??= _MyAppState._();
  _MyAppState._()
      : super(
          controller: AppController(),
          controllers: [
            UserController(),
            SearcherController(),
            PostController()
          ],
        );
  static _MyAppState? _this;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb) {
      // FlutterWindowClose.setWindowShouldCloseHandler();

      // html.window.onUnload.listen((event) async {
      //   event.preventDefault();
      //   Helper.makeOffline();
      // });
      return;
    }

    // FlutterWindowClose.setWindowShouldCloseHandler(() async {
    //   Helper.makeOffline();

    //   return false;
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
    } else {
      Helper.makeOffline();
    }
  }

  Widget createApp() {
    return ValueListenableBuilder(
        valueListenable: Helper.setting,
        builder: (context, Setting setting, _) {
          return FirebasePhoneAuthProvider(
              child: MaterialApp(
                  title: 'Shnatter',
                  debugShowCheckedModeBanner: false,
                  //home: HomeScreen(key: UniqueKey()),
                  locale: setting.language,
                  localizationsDelegates: const [
                    AppLocalizations.delegate, // Add this line
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const <Locale>[
                    Locale.fromSubtags(languageCode: 'en'),
                    Locale.fromSubtags(languageCode: 'ar'),
                    Locale.fromSubtags(languageCode: 'es'),
                    Locale.fromSubtags(languageCode: 'fr'),
                    Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA'),
                    Locale.fromSubtags(languageCode: 'in'),
                    Locale.fromSubtags(languageCode: 'ko'),
                    Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
                  ],
                  initialRoute: '',
                  onGenerateRoute: RouteGenerator.generateRoute,
                  // ignore: dead_code
                  theme: setting.isBright
                      ? ThemeData(
                          brightness: Brightness.dark,
                          fontFamily: 'Georgia',
                          buttonTheme: const ButtonThemeData(
                            buttonColor: Color(0xff00adb5),
                          ),
                          textTheme: const TextTheme(
                            displayLarge: TextStyle(
                                fontSize: 72.0, fontWeight: FontWeight.bold),
                            titleLarge: TextStyle(
                                fontSize: 36.0, fontStyle: FontStyle.italic),
                            bodyMedium:
                                TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
                          ),
                          colorScheme: ColorScheme.fromSwatch(
                                  primarySwatch: kprimarySwatch)
                              .copyWith(
                                  background:
                                      const Color.fromARGB(255, 255, 255, 255)),
                        )
                      : ThemeData(
                          brightness: Brightness.light,
                          fontFamily: 'Georgia',
                          buttonTheme: const ButtonThemeData(
                            buttonColor: Color(0xff00adb5),
                          ),
                          textTheme: const TextTheme(
                            displayLarge: TextStyle(
                                fontSize: 72.0, fontWeight: FontWeight.bold),
                            titleLarge: TextStyle(
                                fontSize: 36.0, fontStyle: FontStyle.italic),
                            bodyMedium:
                                TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
                          ),
                          colorScheme: ColorScheme.fromSwatch(
                                  primarySwatch: kprimarySwatch)
                              .copyWith(background: const Color(0xffeeeeee)),
                        )));
        });
  }

  @override
  Widget buildChild(BuildContext context) {
    return createApp();
  }
}
