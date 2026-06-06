import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lyri_web/firebase_options.dart';
import 'core/localization/app_translations.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/bindings/auth_binding.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize SupabaseService asynchronously before starting the application
  await Get.putAsync<SupabaseService>(() => SupabaseService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Lyri Lyrics Platform',
          debugShowCheckedModeBanner: false,

          // Theme settings
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark, // Default to dark premium aesthetics
          // Routing settings
          initialRoute: AppRoutes.login,
          getPages: AppRoutes.pages,
          initialBinding: AuthBinding(), // Instantiate Auth session immediately
          // Localization settings
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
        );
      },
    );
  }
}
