import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import 'widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static Widget builder(BuildContext context) {
    return const ProfileScreen();
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().loadCustomerProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final customer = authProvider.currentCustomer;
          final user = authProvider.currentUser;
          final name = (customer?.fullName.trim().isNotEmpty ?? false)
              ? customer!.fullName.trim()
              : user?.email ?? 'Cine Member';

          return SafeArea(
            child: Column(
              children: [
                ProfileHeader(onBackTap: _goHome),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        ProfileHero(name: name),
                        SizedBox(height: 22.h),
                        const ProfileFanCard(),
                        SizedBox(height: 18.h),
                        ProfileMenuGroup(
                          items: [
                            ProfileMenuItem(
                              Icons.badge_outlined,
                              'Account Information',
                              _openPersonalInformationPage,
                            ),
                            ProfileMenuItem(
                              Icons.lock_outline,
                              'Change Password',
                              _openPersonalInformationPage,
                            ),
                            ProfileMenuItem(
                              Icons.pin_outlined,
                              'Payment PIN Settings',
                              null,
                            ),
                            ProfileMenuItem(
                              Icons.workspace_premium_outlined,
                              'Member Card',
                              null,
                            ),
                          ],
                        ),
                        const ProfileDividerBand(),
                        ProfileMenuGroup(
                          items: [
                            ProfileMenuItem(
                              Icons.toll_outlined,
                              'Points',
                              null,
                            ),
                            ProfileMenuItem(
                              Icons.card_giftcard_outlined,
                              'Gift Card | Voucher | Coupon',
                              null,
                            ),
                          ],
                        ),
                        const ProfileDividerBand(),
                        ProfileMenuGroup(
                          items: [
                            ProfileMenuItem(
                              Icons.receipt_long_outlined,
                              'Transaction History',
                              null,
                            ),
                            ProfileMenuItem(
                              Icons.logout,
                              'Log Out',
                              authProvider.isLoading ? null : _onLogoutPressed,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _goHome() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.cinemaHomeScreen, (route) => false);
  }

  void _openPersonalInformationPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PersonalInformationScreen()),
    );
  }

  Future<void> _onLogoutPressed() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!mounted) return;

    NavigatorService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.cinemaLoginScreen,
      (route) => false,
    );
  }
}

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _isSaving = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final customer = authProvider.currentCustomer;
    final user = authProvider.currentUser;

    _nameController = TextEditingController(text: customer?.fullName ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _emailController = TextEditingController(
      text: customer?.email ?? user?.email ?? '',
    );
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.black_900,
      body: SafeArea(
        child: Column(
          children: [
            ProfileAccountHeader(onBackTap: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.h, 22.h, 18.h, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfileSectionTitle('PERSONAL INFORMATION'),
                    SizedBox(height: 14.h),
                    ProfileTextField(
                      controller: _nameController,
                      label: 'Full name',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    ProfileTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),
                    SizedBox(height: 12.h),
                    ProfileTextField(
                      controller: _phoneController,
                      label: 'Phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 14.h),
                    ProfileActionButton(
                      label: _isSaving ? 'SAVING...' : 'SAVE CHANGES',
                      onPressed: _isSaving || _isChangingPassword
                          ? null
                          : _saveProfileInfo,
                    ),
                    SizedBox(height: 30.h),
                    const ProfileSectionTitle('CHANGE PASSWORD'),
                    SizedBox(height: 14.h),
                    ProfileTextField(
                      controller: _newPasswordController,
                      label: 'New password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    SizedBox(height: 12.h),
                    ProfileTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      icon: Icons.verified_user_outlined,
                      obscureText: true,
                    ),
                    SizedBox(height: 14.h),
                    ProfileActionButton(
                      label: _isChangingPassword
                          ? 'UPDATING...'
                          : 'UPDATE PASSWORD',
                      onPressed: _isSaving || _isChangingPassword
                          ? null
                          : _changePassword,
                      outlined: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfileInfo() async {
    setState(() {
      _isSaving = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      fullName: _nameController.text,
      phone: _phoneController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    AppSnackBar.show(
      context,
      message: success
          ? 'Profile updated successfully.'
          : authProvider.errorMessage ?? 'Failed to update profile.',
      type: success ? AppSnackBarType.success : AppSnackBarType.error,
    );
  }

  Future<void> _changePassword() async {
    setState(() {
      _isChangingPassword = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isChangingPassword = false;
    });

    if (success) {
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }

    AppSnackBar.show(
      context,
      message: success
          ? 'Password changed successfully.'
          : authProvider.errorMessage ?? 'Failed to change password.',
      type: success ? AppSnackBarType.success : AppSnackBarType.error,
    );
  }
}
