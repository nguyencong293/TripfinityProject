import 'dart:async';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../controllers/user_controller.dart';
import '../../../routes/app_router.dart';
import '../../widgets/circular_progress.dart';

class ForgetAccountScreen extends StatefulWidget {
  const ForgetAccountScreen({super.key});

  @override
  State<ForgetAccountScreen> createState() => _ForgetAccountScreenState();
}

class _ForgetAccountScreenState extends State<ForgetAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final int _codeLength = 6;
  late final List<TextEditingController> _codeControllers;
  late final List<FocusNode> _focusNodes;
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _email;
  String? _otp;

  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _codeControllers = List.generate(
      _codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _goToStep(int step) {
    final userController = context.read<UserController>();
    userController.clearError();
    setState(() => _currentStep = step);
  }

  String _getOtp() => _codeControllers.map((c) => c.text).join();

  // đếm ngược thời gian gửi lại
  void _startResendCooldown() {
    setState(() => _resendCooldown = 120);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        child: SafeArea(
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
                  _buildBody(),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0:
        return _forgotEmail();
      case 1:
        return _checkOtp();
      case 2:
        return _updatePassword();
      default:
        return _forgotEmail();
    }
  }

  Widget _forgotEmail() {
    final userController = context.watch<UserController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'forgot_account'.tr,
            style: context.h4Style,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),
        if (userController.errorMessage != null)
          Text(
            userController.errorMessage!,
            style: context.bodyOneStyle.copyWith(color: context.errorColor),
          ),
        const SizedBox(height: 10),
        Text('email_account'.tr, style: context.bodyOneStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(hintText: 'ent_email_account'.tr),
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'email_required'.tr : null,
        ),
        const SizedBox(height: 50),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: userController.isLoading
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    final email = _emailController.text.trim();
                    final success = await userController.forgotPassword(email);
                    if (success) {
                      _email = email;
                      _startResendCooldown();
                      _goToStep(1);
                    }
                  },
            child: userController.isLoading
                ? const AppCircularProgress()
                : Text('send_link'.tr),
          ),
        ),
      ],
    );
  }

  Widget _checkOtp() {
    final userController = context.watch<UserController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'check_number_code'.tr,
            style: context.h4Style,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),
        if (userController.errorMessage != null)
          Text(
            userController.errorMessage!,
            style: context.bodyOneStyle.copyWith(color: context.errorColor),
          ),
        const SizedBox(height: 10),
        _buildOtpFields(),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: _resendCooldown > 0
              ? Text(
                  'Gửi lại sau $_resendCooldown giây',
                  style: context.buttonStyle.copyWith(
                    color: context.buttonDisabledTextColor,
                  ),
                )
              : TextButton(
                  onPressed: userController.isLoading
                      ? null
                      : () async {
                          if (_email != null) {
                            final success = await userController.forgotPassword(
                              _email!,
                            );
                            if (success) {
                              for (var controller in _codeControllers) {
                                controller.clear();
                              }
                              if (!mounted) return;
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[0]);
                              _startResendCooldown();
                            }
                          }
                        },
                  child: Text(
                    "Gửi lại mã",
                    style: context.buttonStyle.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: userController.isLoading
                ? null
                : () async {
                    final otp = _getOtp();
                    if (otp.length != _codeLength) return;

                    final success = await userController.verifyOtp(
                      _email!,
                      otp,
                    );
                    if (success) {
                      _otp = otp;
                      _goToStep(2);
                    }
                  },
            child: userController.isLoading
                ? const AppCircularProgress()
                : Text('authed'.tr),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          int currentIndex = _focusNodes.indexWhere((f) => f.hasFocus);
          if (currentIndex > 0 && _codeControllers[currentIndex].text.isEmpty) {
            _focusNodes[currentIndex - 1].requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) {
          return SizedBox(
            width: 40,
            height: 40,
            child: TextField(
              controller: _codeControllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              style: context.h5Style,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.buttonDisabledTextColor,
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: context.primaryColor,
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.length == 1 && i + 1 < _codeLength) {
                  _focusNodes[i + 1].requestFocus();
                } else if (value.isEmpty && i > 0) {
                  _focusNodes[i - 1].requestFocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _updatePassword() {
    final userController = context.watch<UserController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'update_password'.tr,
            style: context.h4Style,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),
        if (userController.errorMessage != null)
          Text(
            userController.errorMessage!,
            style: context.bodyOneStyle.copyWith(color: context.errorColor),
          ),
        const SizedBox(height: 10),
        Text('new_password'.tr, style: context.bodyOneStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(hintText: 'ent_new_password'.tr),
          validator: (v) =>
              (v == null || v.length < 6) ? 'passw_invalid'.tr : null,
        ),
        const SizedBox(height: 15),
        Text('re_passw_account'.tr, style: context.bodyOneStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(hintText: 'ent_re_passw_account'.tr),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'confirm_required'.tr;
            }
            if (v != _newPasswordController.text) {
              return 'password_mismatch'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 50),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: userController.isLoading
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;

                    final newPassword = _newPasswordController.text;
                    final confirmPassword = _confirmPasswordController.text;

                    final success = await userController.resetPassword(
                      email: _email!,
                      otp: _otp!,
                      newPassword: newPassword,
                      newConfirmPassword: confirmPassword,
                    );

                    if (!mounted) return;
                    if (success) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go(AppRouter.login);
                      });
                    }
                  },
            child: userController.isLoading
                ? const AppCircularProgress()
                : Text('update'.tr),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Row(
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
    );
  }
}
