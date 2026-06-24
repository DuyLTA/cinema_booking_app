import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_edit_text.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../widgets/custom_sign_in_button.dart';
import '../provider/cinema_register_provider.dart';

class RegisterBackground extends StatelessWidget {
  const RegisterBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          child,
        ],
      ),
    );
  }
}

class RegisterBrandHeader extends StatelessWidget {
  const RegisterBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class RegisterSubtitle extends StatelessWidget {
  const RegisterSubtitle({super.key, required this.provider});

  final CinemaRegisterProvider provider;

  @override
  Widget build(BuildContext context) {
    return Text(
      provider.isAwaitingEmailVerification ? 'Verify Email' : 'Register',
      style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
        height: 31 / 20,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({
    super.key,
    required this.provider,
    required this.onSignUpPressed,
    required this.onVerifyPressed,
  });

  final CinemaRegisterProvider provider;
  final VoidCallback onSignUpPressed;
  final VoidCallback onVerifyPressed;

  @override
  Widget build(BuildContext context) {
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
          _CardTopLine(),
          if (provider.isAwaitingEmailVerification) ...[
            _VerificationSummary(provider: provider),
            _RegisterFieldSection(
              label: 'VERIFICATION CODE',
              hintText: '123456',
              leftImagePath: ImageConstant.imgContainer,
              inputType: TextInputType.number,
              controller: provider.verificationCodeController,
              focusNode: provider.verificationCodeFocusNode,
              validator: provider.validateVerificationCode,
              marginTop: 16,
            ),
            _PrimaryRegisterButton(
              text: 'VERIFY EMAIL',
              isLoading: provider.isLoading,
              onPressed: onVerifyPressed,
            ),
            _ResendCodeButton(provider: provider),
            SizedBox(height: 20.h),
          ] else ...[
            _RegisterFieldSection(
              label: 'FULL NAME',
              hintText: 'John Doe',
              leftImagePath: ImageConstant.imgContainer,
              inputType: TextInputType.name,
              controller: provider.fullNameController,
              focusNode: provider.fullNameFocusNode,
              validator: provider.validateFullName,
              marginTop: 10,
            ),
            _RegisterFieldSection(
              label: 'EMAIL',
              hintText: 'name@cinema.com',
              leftImagePath: ImageConstant.imgContainer,
              inputType: TextInputType.emailAddress,
              controller: provider.emailController,
              focusNode: provider.emailFocusNode,
              validator: provider.validateEmail,
            ),
            _RegisterFieldSection(
              label: 'PHONE (OPTIONAL)',
              hintText: '+84 912 345 678',
              leftImagePath: ImageConstant.imgContainerGray500,
              inputType: TextInputType.phone,
              controller: provider.phoneController,
              focusNode: provider.phoneFocusNode,
              validator: provider.validatePhone,
            ),
            _RegisterFieldSection(
              label: 'PASSWORD',
              hintText: '••••••••',
              leftImagePath: ImageConstant.imgContainerGray500,
              rightImagePath: ImageConstant.imgButton,
              isPasswordField: true,
              inputType: TextInputType.visiblePassword,
              controller: provider.passwordController,
              focusNode: provider.passwordFocusNode,
              validator: provider.validatePassword,
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
            ),
            _RegisterFieldSection(
              label: 'CONFIRM PASSWORD',
              hintText: '••••••••',
              leftImagePath: ImageConstant.imgContainerGray500,
              rightImagePath: ImageConstant.imgButton,
              isPasswordField: true,
              inputType: TextInputType.visiblePassword,
              controller: provider.confirmPasswordController,
              focusNode: provider.confirmPasswordFocusNode,
              validator: provider.validateConfirmPassword,
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
            ),
            _PrimaryRegisterButton(
              text: 'SIGN UP',
              isLoading: provider.isLoading,
              onPressed: onSignUpPressed,
            ),
            const _DividerRow(),
            _SocialButtons(provider: provider),
          ],
        ],
      ),
    );
  }
}

class _CardTopLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0x005C0612), appTheme.gray_900, appTheme.color005C06],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.h),
          topRight: Radius.circular(12.h),
        ),
      ),
    );
  }
}

class _VerificationSummary extends StatelessWidget {
  const _VerificationSummary({required this.provider});

  final CinemaRegisterProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 16.h, right: 16.h),
      width: double.infinity,
      child: Text(
        'Code sent to ${provider.emailController.text.trim()}',
        style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
          color: appTheme.gray_500,
          height: 31 / 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _RegisterFieldSection extends StatelessWidget {
  const _RegisterFieldSection({
    required this.label,
    required this.hintText,
    required this.leftImagePath,
    required this.inputType,
    required this.controller,
    required this.focusNode,
    required this.validator,
    this.rightImagePath,
    this.isPasswordField = false,
    this.marginTop = 12,
    this.leftIconWidth,
    this.leftIconHeight,
    this.rightIconWidth,
    this.rightIconHeight,
    this.contentPadding,
  });

  final String label;
  final String hintText;
  final String leftImagePath;
  final TextInputType inputType;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?) validator;
  final String? rightImagePath;
  final bool isPasswordField;
  final double marginTop;
  final double? leftIconWidth;
  final double? leftIconHeight;
  final double? rightIconWidth;
  final double? rightIconHeight;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop.h, left: 16.h, right: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.h,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Text(
              label,
              style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                letterSpacing: 1,
                height: 17 / 14,
              ),
            ),
          ),
          CustomEditText(
            hintText: hintText,
            leftImagePath: leftImagePath,
            rightImagePath: rightImagePath,
            isPasswordField: isPasswordField,
            inputType: inputType,
            controller: controller,
            focusNode: focusNode,
            fillColor: appTheme.black_900,
            borderRadius: 8,
            leftIconWidth: leftIconWidth,
            leftIconHeight: leftIconHeight,
            rightIconWidth: rightIconWidth,
            rightIconHeight: rightIconHeight,
            contentPadding:
                contentPadding ??
                EdgeInsets.only(
                  top: 16.h,
                  right: 16.h,
                  bottom: 16.h,
                  left: 32.h,
                ),
            width: double.infinity,
            validator: validator,
          ),
        ],
      ),
    );
  }
}

class _PrimaryRegisterButton extends StatelessWidget {
  const _PrimaryRegisterButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
      child: CustomSignInButton(
        text: text,
        width: double.infinity,
        isLoading: isLoading,
        onPressed: onPressed,
      ),
    );
  }
}

class _ResendCodeButton extends StatelessWidget {
  const _ResendCodeButton({required this.provider});

  final CinemaRegisterProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: TextButton(
        onPressed: provider.isLoading
            ? null
            : () => provider.onResendRegistrationCodePressed(context),
        child: Text(
          'Resend code',
          style: TextStyleHelper.instance.title16BoldDMSans,
        ),
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
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
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({required this.provider});

  final CinemaRegisterProvider provider;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}

class RegisterSignInRow extends StatelessWidget {
  const RegisterSignInRow({super.key});

  @override
  Widget build(BuildContext context) {
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
          onTap: () =>
              context.read<CinemaRegisterProvider>().onSignInTapped(context),
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
