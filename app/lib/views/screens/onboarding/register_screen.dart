import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/routes/app_router.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SafeArea(
        child: SingleChildScrollView(
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
                const SizedBox(height: 50),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('name_account'.tr, style: context.bodyOneStyle),
                    SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ent_name_account'.tr,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text('email_account'.tr, style: context.bodyOneStyle),
                    SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ent_email_account'.tr,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text('passw_account'.tr, style: context.bodyOneStyle),
                    SizedBox(height: 4),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'ent_passw_account'.tr,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text('re_passw_account'.tr, style: context.bodyOneStyle),
                    SizedBox(height: 4),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'ent_re_passw_account'.tr,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    // Handle registration logic
                  },
                  child: Text('register'.tr),
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
    );
  }
}
