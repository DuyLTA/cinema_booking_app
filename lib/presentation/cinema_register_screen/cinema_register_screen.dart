import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import 'provider/cinema_register_provider.dart';
import 'widgets/register_widgets.dart';

class CinemaRegisterScreen extends StatefulWidget {
  const CinemaRegisterScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<CinemaRegisterProvider>(
      create: (context) => CinemaRegisterProvider(),
      child: const CinemaRegisterScreen(),
    );
  }

  @override
  State<CinemaRegisterScreen> createState() => _CinemaRegisterScreenState();
}

class _CinemaRegisterScreenState extends State<CinemaRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_900_01,
      body: Consumer<CinemaRegisterProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: RegisterBackground(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 180.h),
                      const RegisterBrandHeader(),
                      SizedBox(height: 8.h),
                      RegisterSubtitle(provider: provider),
                      SizedBox(height: 32.h),
                      RegisterFormCard(
                        provider: provider,
                        onSignUpPressed: () => _onSignUpPressed(provider),
                        onVerifyPressed: () => _onVerifyPressed(provider),
                      ),
                      SizedBox(height: 32.h),
                      const RegisterSignInRow(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSignUpPressed(CinemaRegisterProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      provider.onSignUpPressed(context);
    }
  }

  void _onVerifyPressed(CinemaRegisterProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      provider.onVerifyRegistrationPressed(context);
    }
  }
}
