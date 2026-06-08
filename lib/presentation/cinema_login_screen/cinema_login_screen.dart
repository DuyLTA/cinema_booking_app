import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_edit_text.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../widgets/custom_sign_in_button.dart';
import '../cinema_login_screen/provider/cinema_login_provider.dart';

class CinemaLoginScreen extends StatefulWidget {
  CinemaLoginScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<CinemaLoginProvider>(
      create: (context) => CinemaLoginProvider(),
      child: CinemaLoginScreen(),
    );
  }

  @override
  State<CinemaLoginScreen> createState() => _CinemaLoginScreenState();
}

class _CinemaLoginScreenState extends State<CinemaLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_900_01,
      body: Consumer<CinemaLoginProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomImageView(
                        imagePath: ImageConstant.imgOverlayBlur,
                        width: 116.h,
                        height: 310.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: CustomImageView(
                        imagePath: ImageConstant.imgOverlayBlur310x116,
                        width: 116.h,
                        height: 310.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: CustomImageView(
                        imagePath: ImageConstant.imgImage,
                        width: double.infinity,
                        height: 1036.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 219.h),
                          _buildHeaderSection(),
                          SizedBox(height: 8.h),
                          _buildLoginSubtitle(),
                          SizedBox(height: 32.h),
                          _buildFormCard(provider),
                          SizedBox(height: 32.h),
                          _buildSignUpRow(context),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.h),
      child: Column(
        spacing: 4.h,
        children: [
          Text(
            'CINE BOOKING',
            style: TextStyleHelper.instance.display48RegularBebasNeue.copyWith(
              letterSpacing: 6,
              height: 40 / 48,
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            width: double.infinity,
            height: 1.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0x7FFFDF9E),
                  appTheme.color7FFFDF,
                  Color(0x7FFFDF9E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSubtitle() {
    return Text(
      'Login',
      style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
        height: 31 / 20,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFormCard(CinemaLoginProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.gray_900_cc,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.color19A48B, width: 1.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.black_900_3f,
            blurRadius: 50.h,
            offset: Offset(0, 25.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 2.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0x005C0612),
                  appTheme.gray_900,
                  appTheme.color005C06,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.h),
                topRight: Radius.circular(12.h),
              ),
            ),
          ),
          _buildEmailSection(provider),
          _buildPasswordSection(provider),
          _buildSignInButton(provider),
          _buildDividerRow(),
          _buildSocialButtons(provider),
        ],
      ),
    );
  }

  Widget _buildEmailSection(CinemaLoginProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'EMAIL OR PHONE',
              style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                letterSpacing: 1,
                height: 17 / 14,
              ),
            ),
          ),
          CustomEditText(
            hintText: 'name@cinema.com',
            leftImagePath: ImageConstant.imgContainer,
            inputType: TextInputType.emailAddress,
            controller: provider.emailController,
            focusNode: provider.emailFocusNode,
            fillColor: appTheme.black_900,
            borderRadius: 8,
            contentPadding: EdgeInsets.only(
              top: 16.h,
              right: 16.h,
              bottom: 16.h,
              left: 32.h,
            ),
            width: double.infinity,
            validator: (value) => provider.validateEmail(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(CinemaLoginProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 12.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PASSWORD',
                  style: TextStyleHelper.instance.body14RegularBebasNeue
                      .copyWith(letterSpacing: 1, height: 17 / 14),
                ),
                GestureDetector(
                  onTap: () => provider.onForgotPasswordTapped(context),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyleHelper.instance.body14RegularBebasNeue
                        .copyWith(
                          color: appTheme.orange_100,
                          letterSpacing: 1,
                          height: 17 / 14,
                        ),
                  ),
                ),
              ],
            ),
          ),
          CustomEditText(
            hintText: '••••••••',
            leftImagePath: ImageConstant.imgContainerGray500,
            rightImagePath: ImageConstant.imgButton,
            isPasswordField: true,
            inputType: TextInputType.visiblePassword,
            controller: provider.passwordController,
            focusNode: provider.passwordFocusNode,
            fillColor: appTheme.black_900,
            borderRadius: 8,
            leftIconWidth: 12,
            leftIconHeight: 16,
            rightIconWidth: 18,
            rightIconHeight: 16,
            contentPadding: EdgeInsets.only(
              top: 16.h,
              right: 34.h,
              bottom: 16.h,
              left: 28.h,
            ),
            width: double.infinity,
            validator: (value) => provider.validatePassword(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(CinemaLoginProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
      child: CustomSignInButton(
        text: 'SIGN IN',
        width: double.infinity,
        isLoading: provider.isLoading,
        onPressed: () => _onSignInPressed(provider),
      ),
    );
  }

  void _onSignInPressed(CinemaLoginProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      provider.onSignInPressed(context);
    }
  }

  Widget _buildDividerRow() {
    return Container(
      margin: EdgeInsets.only(top: 20.h, left: 16.h, right: 16.h),
      child: Row(
        spacing: 16.h,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              height: 1.h,
              color: appTheme.color33A48B,
            ),
          ),
          Text(
            'Or Continue With',
            style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
              color: appTheme.color99A48B,
              letterSpacing: 1,
              height: 17 / 14,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              height: 1.h,
              color: appTheme.color33A48B,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButtons(CinemaLoginProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 22.h, bottom: 32.h),
      child: Row(
        spacing: 16.h,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconButton(
            imagePath: ImageConstant.imgButtonGoogle,
            size: 56,
            backgroundColor: appTheme.blue_gray_900_66,
            borderColor: appTheme.color33FFDF,
            borderRadius: 28,
            padding: EdgeInsets.all(16.h),
            onTap: () => provider.onGoogleSignInPressed(context),
          ),
          CustomIconButton(
            imagePath: ImageConstant.imgSvg,
            size: 56,
            backgroundColor: appTheme.blue_gray_900_66,
            borderColor: appTheme.color33FFDF,
            borderRadius: 28,
            padding: EdgeInsets.all(16.h),
            onTap: () => provider.onAppleSignInPressed(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpRow(BuildContext context) {
    return Row(
      spacing: 8.h,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            height: 21 / 16,
          ),
        ),
        GestureDetector(
          onTap: () => context
              .read<CinemaLoginProvider>()
              .onJoinThePremiereTapped(context),
          child: Text(
            'Join the Premiere',
            style: TextStyleHelper.instance.title16BoldDMSans.copyWith(
              height: 21 / 16,
            ),
          ),
        ),
      ],
    );
  }
}
