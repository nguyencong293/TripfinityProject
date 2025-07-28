import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/dto/user_dto.dart';
import 'package:app/routes/app_router.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/user_controller.dart';
import '../../widgets/circular_progress.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required'.tr;
    }
    final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegEx.hasMatch(value)) {
      return 'email_invalid'.tr;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              width: double.infinity,
              color: context.backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
                  Text('register_account'.tr, style: context.h4Style),
                  // Hiển thị lỗi nếu có
                  const SizedBox(height: 50),
                  if (userController.errorMessage != null)
                    Text(
                      userController.errorMessage!,
                      style: context.bodyOneStyle.copyWith(
                        color: context.errorColor,
                      ),
                    ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('name_account'.tr, style: context.bodyOneStyle),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'ent_name_account'.tr,
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'name_required'.tr
                            : null,
                      ),
                      SizedBox(height: 15),
                      Text('email_account'.tr, style: context.bodyOneStyle),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'ent_email_account'.tr,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      SizedBox(height: 15),
                      Text('passw_account'.tr, style: context.bodyOneStyle),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'ent_passw_account'.tr,
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'passw_invalid'.tr
                            : null,
                      ),
                      SizedBox(height: 15),
                      Text('re_passw_account'.tr, style: context.bodyOneStyle),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'ent_re_passw_account'.tr,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'confirm_required'.tr;
                          }
                          if (v != _passwordController.text) {
                            return 'password_mismatch'.tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: userController.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            final user = UserDTO(
                              email: _emailController.text.trim(),
                              passwordHash: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                              fullName: _nameController.text.trim(),
                              accountRole: AccountRole.tourist,
                              accountStatus: AccountStatus.active,
                            );

                            final success = await userController.register(user);
                            if (!mounted) return;
                            if (success) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context.go(AppRouter.login);
                              });
                            }
                          },
                    child: userController.isLoading
                        ? const AppCircularProgress()
                        : Text('register'.tr),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('already_have_an_account'.tr),
                      SizedBox(width: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          context.go(AppRouter.login);
                        },
                        child: Text('login'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
