import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_router.dart';

class ForgetAccountScreen extends StatefulWidget {
  const ForgetAccountScreen({super.key});

  @override
  State<ForgetAccountScreen> createState() => _ForgetAccountScreenState();
}

class _ForgetAccountScreenState extends State<ForgetAccountScreen> {
  int _currentStep = 0;
  final int _codeLength = 6;
  late final List<TextEditingController> _codeControllers;
  late final List<FocusNode> _focusNodes;

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
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentStep) {
      case 0:
        body = _forgotEmail();
        break;
      case 1:
        body = _checkNumberEmail();
        break;
      case 2:
        body = _updatePassword();
        break;
      default:
        body = _forgotEmail();
    }
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: context.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
              body,
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
    );
  }

  Widget _forgotEmail() {
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
        Text('email_account'.tr, style: context.bodyOneStyle),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(hintText: 'ent_email_account'.tr),
        ),
        const SizedBox(height: 50),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _currentStep = 1);
            },
            child: Text('send_link'.tr),
          ),
        ),
      ],
    );
  }

  Widget _checkNumberEmail() {
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
        Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              int currentIndex = _focusNodes.indexWhere((f) => f.hasFocus);
              if (currentIndex > 0 &&
                  _codeControllers[currentIndex].text.isEmpty) {
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
        ),
        const SizedBox(height: 50),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _currentStep = 2);
            },
            child: Text('authed'.tr),
          ),
        ),
      ],
    );
  }

  Widget _updatePassword() {
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
        Text('new_password'.tr, style: context.bodyOneStyle),
        const SizedBox(height: 4),
        TextField(
          obscureText: true,
          decoration: InputDecoration(hintText: 'ent_new_password'.tr),
        ),
        const SizedBox(height: 15),
        Text('re_passw_account'.tr, style: context.bodyOneStyle),
        const SizedBox(height: 4),
        TextField(
          obscureText: true,
          decoration: InputDecoration(hintText: 'ent_re_passw_account'.tr),
        ),
        const SizedBox(height: 50),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              context.go(AppRouter.login);
            },
            child: Text('update'.tr),
          ),
        ),
      ],
    );
  }
}
