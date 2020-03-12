import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noteapp/auth_widget_builder.dart';
import 'package:noteapp/constants/app_strings.dart';
import 'package:noteapp/constants/app_themes.dart';
import 'package:noteapp/models/user_model.dart';
import 'package:noteapp/providers/auth_provider.dart';
import 'package:noteapp/providers/theme_provider.dart';
import 'package:noteapp/routes.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:noteapp/ui/auth/sign_in_screen.dart';
import 'package:noteapp/ui/home/home.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    runApp(
      /*
      * MultiProvider for top services that do not depends on any runtime values
      * such as user uid/email.
       */
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider(),
          ),
        ],
        child: MyApp(
          databaseBuilder: (_, uid) => FirestoreDatabase(uid: uid),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.databaseBuilder}) : super(key: key);

  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProviderRef, __) {
        //{context, data, child}
        return AuthWidgetBuilder(
          databaseBuilder: databaseBuilder,
          builder:
              (BuildContext context, AsyncSnapshot<UserModel> userSnapshot) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppStrings.appName,
              routes: Routes.routes,
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: themeProviderRef.isDarkModeOn
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: Consumer<AuthProvider>(
                builder: (_, authProviderRef, __) {
                  if (userSnapshot.connectionState == ConnectionState.active) {
                    return userSnapshot.hasData ? HomeScreen() : SignInScreen();
                  }

                  return Material(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
