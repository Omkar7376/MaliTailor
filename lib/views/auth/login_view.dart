import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Get.find<AuthController>();
      if (auth.isAuthenticated) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF161412), const Color(0xFF241E1A)]
                : [const Color(0xFFF7F2EB), const Color(0xFFFDFBF7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 38),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Atelier Logo
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryDarkBrown, AppColors.secondaryMediumBrown],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDarkBrown.withAlpha(50),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.cut, color: AppColors.softGolden, size: 36),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'StitchUp',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Admin Workshop Portal',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Username Field
                        Text(
                          'Admin Username',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 20),
                            hintText: 'Enter username or email',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter username';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password Field
                        Text(
                          'Password',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            hintText: 'Enter password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter password';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        Obx(() {
                          return ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      authController.login(
                                        _usernameController.text,
                                        _passwordController.text,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDarkBrown,
                              foregroundColor: AppColors.softGolden,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authController.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    'Admin Sign In',
                                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
