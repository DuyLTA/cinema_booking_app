import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_edit_text.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../widgets/custom_sign_in_button.dart';
import 'provider/cinema_register_provider.dart';

class CinemaRegisterScreen extends StatefulWidget {
  CinemaRegisterScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<CinemaRegisterProvider>(
      create: (context) => CinemaRegisterProvider(),
      child: CinemaRegisterScreen(),
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
                          SizedBox(height: 180.h),
                          _buildHeaderSection(),
                          SizedBox(height: 8.h),
                          _buildRegisterSubtitle(),
                          SizedBox(height: 32.h),
                          _buildFormCard(provider),
                          SizedBox(height: 32.h),
                          _buildSignInRow(context),
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

  Widget _buildRegisterSubtitle() {
    return Text(
      'Register',
      style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
        height: 31 / 20,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFormCard(CinemaRegisterProvider provider) {
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
          _buildFullNameSection(provider),
          _buildEmailSection(provider),
          _buildPhoneSection(provider),
          _buildPasswordSection(provider),
          _buildConfirmPasswordSection(provider),
          _buildSignUpButton(provider),
          _buildDividerRow(),
          _buildSocialButtons(provider),
        ],
      ),
    );
  }

  Widget _buildFullNameSection(CinemaRegisterProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'FULL NAME',
              style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                letterSpacing: 1,
                height: 17 / 14,
              ),
            ),
          ),
          CustomEditText(
            hintText: 'John Doe',
            leftImagePath: ImageConstant.imgContainer,
            inputType: TextInputType.name,
            controller: provider.fullNameController,
            focusNode: provider.fullNameFocusNode,
            fillColor: appTheme.black_900,
            borderRadius: 8,
            contentPadding: EdgeInsets.only(
              top: 16.h,
              right: 16.h,
              bottom: 16.h,
              left: 32.h,
            ),
            width: double.infinity,
            validator: (value) => provider.validateFullName(value),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection(CinemaRegisterProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 12.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'EMAIL',
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

  Widget _buildPhoneSection(CinemaRegisterProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 12.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'PHONE (OPTIONAL)',
              style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                letterSpacing: 1,
                height: 17 / 14,
              ),
            ),
          ),
          CustomEditText(
            hintText: '+84 912 345 678',
            leftImagePath: ImageConstant.imgContainerGray500,
            inputType: TextInputType.phone,
            controller: provider.phoneController,
            focusNode: provider.phoneFocusNode,
            fillColor: appTheme.black_900,
            borderRadius: 8,
            contentPadding: EdgeInsets.only(
              top: 16.h,
              right: 16.h,
              bottom: 16.h,
              left: 32.h,
            ),
            width: double.infinity,
            validator: (value) => provider.validatePhone(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(CinemaRegisterProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 12.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'PASSWORD',
              style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                letterSpacing: 1,
                height: 17 / 14,
              ),
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

  Widget _buildConfirmPasswordSection(CinemaRegisterProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 12.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              'CONFIRM PASSWORD',
              style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                letterSpacing: 1,
                height: 17 / 14,
              ),
            ),
          ),
          CustomEditText(
            hintText: '••••••••',
            leftImagePath: ImageConstant.imgContainerGray500,
            rightImagePath: ImageConstant.imgButton,
            isPasswordField: true,
            inputType: TextInputType.visiblePassword,
            controller: provider.confirmPasswordController,
            focusNode: provider.confirmPasswordFocusNode,
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
            validator: (value) => provider.validateConfirmPassword(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton(CinemaRegisterProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
      child: CustomSignInButton(
        text: 'SIGN UP',
        width: double.infinity,
        isLoading: provider.isLoading,
        onPressed: () => _onSignUpPressed(provider),
      ),
    );
  }

  void _onSignUpPressed(CinemaRegisterProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      provider.onSignUpPressed(context);
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

  Widget _buildSocialButtons(CinemaRegisterProvider provider) {
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

  Widget _buildSignInRow(BuildContext context) {
    return Row(
      spacing: 8.h,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            height: 21 / 16,
          ),
        ),
        GestureDetector(
          onTap: () => context
              .read<CinemaRegisterProvider>()
              .onSignInTapped(context),
          child: Text(
            'Sign In',
            style: TextStyleHelper.instance.title16BoldDMSans.copyWith(
              height: 21 / 16,
            ),
          ),
        ),
      ],
    );
  }
}
