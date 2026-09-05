import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text : "admin@lyri.com");
  final _passwordController = TextEditingController(text:"Admin@123");
  final AuthController _authController = Get.find<AuthController>();
  final RxBool _isSignUp = false.obs;
  final RxBool _obscurePassword = true.obs;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isSignUp.value) {
        _authController.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      } else {
        _authController.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Ambient Gradient Mesh Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            right: size.width * 0.2,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main Body Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: SizedBox(
                width: size.width > 500 ? 450 : size.width - 32,
                child: AppGlassContainer(
                  borderRadius: 24,
                  padding: EdgeInsets.all(size.width > 500 ? 40 : 24),
                  child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Icon & Title
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient(context),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.music_note,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        LocaleKeys.appName.tr,
                        textAlign: TextAlign.center,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        useOutfit: true,
                      ),
                      const SizedBox(height: 6),
                      Obx(() => CustomText(
                            _isSignUp.value ? 'Create Your Account' : 'Lyrics Database & Explorer',
                            textAlign: TextAlign.center,
                            color: Colors.grey[400],
                            isSecondary: true,
                          )),
                      const SizedBox(height: 32),
                      
                      // Full Name (Only shown for Signup)
                      Obx(() {
                        if (!_isSignUp.value) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomText(
                              'Full Name',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            CustomTextFormField(
                              controller: _nameController,
                              hintText: 'John Doe',
                              prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Full name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),

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
                        hintText: 'user@lyri.com',
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
                          Obx(() {
                            if (_isSignUp.value) return const SizedBox.shrink();
                            return TextButton(
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
                            );
                          }),
                        ],
                      ),
                      Obx(() => SizedBox(height: _isSignUp.value ? 8 : 0)),
                      Obx(() => CustomTextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword.value,
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: _obscurePassword.toggle,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.passwordRequired.tr;
                          }
                          if (_isSignUp.value && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      )),
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      Obx(() {
                        final isBtnLoading = _authController.isLoading.value;
                        return AppAnimatedButton(
                          onTap: _submit,
                          child: CustomButton(
                            label: _isSignUp.value ? 'REGISTER' : LocaleKeys.login.tr.toUpperCase(),
                            onPressed: _submit,
                            isLoading: isBtnLoading,
                            height: 52,
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Divider OR
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CustomText('OR', color: Colors.grey[400], isSecondary: true),
                          ),
                          Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Google Login Button
                      Obx(() {
                        final isBtnLoading = _authController.isLoading.value;
                        return AppAnimatedButton(
                          onTap: isBtnLoading ? null : _authController.loginWithGoogle,
                          child: OutlinedButton.icon(
                            onPressed: isBtnLoading ? null : _authController.loginWithGoogle,
                            icon: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                              width: 18,
                              height: 18,
                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.white),
                            ),
                            label: CustomText(
                              _isSignUp.value ? 'Sign up with Google' : 'Sign in with Google',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Toggle Link
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                _isSignUp.value ? 'Already have an account? ' : 'Don\'t have an account? ',
                                color: Colors.grey[400],
                                isSecondary: true,
                              ),
                              TextButton(
                                onPressed: () {
                                  _isSignUp.toggle();
                                },
                                child: Text(
                                  _isSignUp.value ? 'Sign In' : 'Sign Up',
                                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
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
