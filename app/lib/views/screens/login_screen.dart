import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_router.dart';
import '../widgets/circular_progress.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authController = context.read<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    DateTime? lastBackPressed;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > Duration(seconds: 2)) {
          lastBackPressed = now;
          Fluttertoast.showToast(msg: "press_back_again_to_exit".tr);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              color: context.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo_1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'login_account'.tr,
                      style: context.h4Style,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    if (authController.errorMessage != null)
                      Text(
                        authController.errorMessage!,
                        style: context.bodyOneStyle.copyWith(
                          color: context.errorColor,
                        ),
                      ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('email_account'.tr, style: context.bodyOneStyle),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'ent_email_account'.tr,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'email_required'.tr
                              : null,
                        ),
                        const SizedBox(height: 15),
                        Text('passw_account'.tr, style: context.bodyOneStyle),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'ent_passw_account'.tr,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'passw_invalid'.tr
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          context.go(AppRouter.forgetAccount);
                        },
                        child: Text(
                          'forg_account_txt'.tr,
                          style: context.captionStyle.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: authController.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;
                              final success = await authController.login(
                                email,
                                password,
                              );
                              if (!mounted) return;
                              if (success) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  context.go(AppRouter.home);
                                });
                              }
                            },
                      child: authController.isLoading
                          ? const AppCircularProgress()
                          : Text('login'.tr),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: authController.isLoading
                          ? null
                          : () async {
                              final success = await authController
                                  .googleLogin();
                              if (!mounted) return;
                              if (success) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  context.go(AppRouter.home);
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.backgroundColor,
                        foregroundColor: context.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/gg_logo.png',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'login_with_google'.tr,
                            style: context.buttonStyle.copyWith(
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('dont_have_an_account'.tr),
                        SizedBox(width: 4),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            context.go(AppRouter.register);
                          },
                          child: Text('register'.tr),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
