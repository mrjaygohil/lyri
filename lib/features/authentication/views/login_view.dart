import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _authController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient decoration
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E1E38),
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Gradient Accent Circles
          Positioned(
            top: -size.height * 0.2,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.2,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.12),
              ),
            ),
          ),
          // Main Body Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: size.width > 500 ? 450 : size.width - 32,
                padding: EdgeInsets.all(size.width > 500 ? 40 : 24),
                decoration: AppTheme.glassDecoration(
                  context: context,
                  opacity: 0.2,
                  blur: 20,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Icon & Title
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient(context),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.music_note,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomText(
                        LocaleKeys.appName.tr,
                        textAlign: TextAlign.center,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        useOutfit: true,
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        'Lyrics Database Admin Panel',
                        textAlign: TextAlign.center,
                        color: Colors.grey[400],
                        isSecondary: true,
                      ),
                      const SizedBox(height: 32),
                      
                      // Email Input Field
                      CustomText(
                        LocaleKeys.email.tr,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'admin@lyri.com',
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.emailRequired.tr;
                          }
                          if (!GetUtils.isEmail(value)) {
                            return LocaleKeys.invalidEmail.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Password Input Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            LocaleKeys.password.tr,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          TextButton(
                            onPressed: () {
                              if (_emailController.text.isNotEmpty) {
                                _authController.sendForgotPasswordEmail(_emailController.text.trim());
                              } else {
                                Get.snackbar(
                                  LocaleKeys.errorOccurred.tr,
                                  'Please enter your email to request password reset link.',
                                  backgroundColor: Colors.amber.shade800,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: Text(
                              LocaleKeys.forgotPassword.tr,
                              style: TextStyle(color: theme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.passwordRequired.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Login Button
                      Obx(() {
                        final isBtnLoading = _authController.isLoading.value;
                        return CustomButton(
                          label: LocaleKeys.login.tr.toUpperCase(),
                          onPressed: _submit,
                          isLoading: isBtnLoading,
                          height: 52,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
