import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_cine_marquee_app_bar.dart';
import '../../widgets/custom_image_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const ProfileScreen();
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _avatarUrl =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'
      '?auto=format&fit=crop&w=400&q=80';

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
      backgroundColor: appTheme.black_900,
      appBar: const CustomCineMarqueeAppBar(titleText: 'CINE BOOKING'),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final customer = authProvider.currentCustomer;
          final user = authProvider.currentUser;
          final name = (customer?.fullName.trim().isNotEmpty ?? false)
              ? customer!.fullName
              : 'Julian Vance';
          final memberSince = customer?.createdAt.year.toString() ?? '2026';
          final idValue = _shortId(customer?.id ?? user?.id);

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(18.h, 26.h, 18.h, 28.h),
                    child: Column(
                      children: [
                        _buildProfileHero(name, idValue, memberSince),
                        SizedBox(height: 24.h),
                        _buildStatsCard(),
                        SizedBox(height: 26.h),
                        _buildTicketHub(),
                        SizedBox(height: 30.h),
                        _buildSettings(authProvider),
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

  String _shortId(String? value) {
    if (value == null || value.isEmpty) {
      return 'U12345678';
    }

    final compact = value.replaceAll('-', '').toUpperCase();
    return compact.length <= 8 ? compact : compact.substring(0, 8);
  }

  Widget _buildProfileHero(String name, String idValue, String memberSince) {
    return Column(
      children: [
        Container(
          width: 96.h,
          height: 96.h,
          padding: EdgeInsets.all(4.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: appTheme.orange_100, width: 3.h),
            boxShadow: [
              BoxShadow(
                color: appTheme.orange_100.withValues(alpha: 0.22),
                blurRadius: 22.h,
              ),
            ],
          ),
          child: ClipOval(
            child: CustomImageView(imagePath: _avatarUrl, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
            color: appTheme.gray_300,
            fontSize: 25.fSize,
            letterSpacing: 1.8,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'ID: $idValue  |  MEMBER SINCE $memberSince',
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            color: appTheme.gray_500,
            fontSize: 12.fSize,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color19A48B),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('124', 'MOVIES WATCHED')),
          Container(width: 1.h, height: 34.h, color: appTheme.color19A48B),
          Expanded(child: _buildStatItem('3', 'UPCOMING TICKETS')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyleHelper.instance.headline24RegularBebasNeue.copyWith(
            color: const Color(0xFFFFD21E),
            fontSize: 22.fSize,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            color: appTheme.gray_400,
            fontSize: 10.fSize,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketHub() {
    return Column(
      children: [
        _buildSectionHeader('MY TICKET HUB', trailing: 'VIEW ALL'),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.h),
          decoration: BoxDecoration(
            color: appTheme.gray_900_03,
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: Row(
            children: [
              Container(
                width: 66.h,
                height: 86.h,
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: appTheme.black_900,
                  borderRadius: BorderRadius.circular(4.h),
                  border: Border.all(color: appTheme.color19A48B),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.h),
                  child: CustomImageView(
                    imagePath:
                        'https://images.unsplash.com/photo-1517602302552-471fe67acf66'
                        '?auto=format&fit=crop&w=300&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 14.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FRIDAY - 9:00 PM',
                      style: TextStyleHelper.instance.label10RegularBebasNeue
                          .copyWith(
                            color: const Color(0xFFFFD21E),
                            letterSpacing: 0.8,
                          ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Shadows of the City',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                          .copyWith(
                            color: appTheme.gray_300,
                            fontSize: 17.fSize,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Vincom Mega Mall - District 9',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleHelper.instance.body12MediumDMSans
                          .copyWith(color: appTheme.gray_400),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 28.h,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.qr_code_2, size: 14.h),
                        label: Text(
                          'VIEW TICKET',
                          style: TextStyleHelper
                              .instance
                              .label10RegularBebasNeue
                              .copyWith(
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.bookRedFill,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.h),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(AuthProvider authProvider) {
    return Column(
      children: [
        _buildSectionHeader('SETTINGS'),
        SizedBox(height: 10.h),
        _buildSettingsTile(
          icon: Icons.person_outline,
          label: 'Personal Information',
          onTap: _openPersonalInformationPage,
        ),
        SizedBox(height: 8.h),
        _buildSettingsTile(
          icon: Icons.shield_outlined,
          label: 'Log Out',
          onTap: authProvider.isLoading ? null : () => _onLogoutPressed(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyleHelper.instance.title18RegularBebasNeue.copyWith(
            color: appTheme.gray_300,
            letterSpacing: 1.5,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: const Color(0xFFFFD21E),
              letterSpacing: 0.8,
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 14.h),
        decoration: BoxDecoration(
          color: appTheme.gray_900_02,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Row(
          children: [
            Icon(icon, color: appTheme.orange_100, size: 20.h),
            SizedBox(width: 14.h),
            Expanded(
              child: Text(
                label,
                style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontSize: 14.fSize,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: appTheme.gray_400, size: 22.h),
          ],
        ),
      ),
    );
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.h, 22.h, 18.h, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('PERSONAL INFORMATION'),
                    SizedBox(height: 14.h),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full name',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      enabled: false,
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 14.h),
                    _buildSaveButton(),
                    SizedBox(height: 30.h),
                    _buildSectionTitle('CHANGE PASSWORD'),
                    SizedBox(height: 14.h),
                    _buildTextField(
                      controller: _newPasswordController,
                      label: 'New password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      icon: Icons.verified_user_outlined,
                      obscureText: true,
                    ),
                    SizedBox(height: 14.h),
                    _buildPasswordButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_01,
        border: Border(bottom: BorderSide(color: appTheme.bookRedBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36.h,
              height: 36.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back,
                color: appTheme.orange_100,
                size: 22.h,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'ACCOUNT',
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.headline24RegularBebasNeue
                  .copyWith(color: appTheme.orange_100, letterSpacing: 3),
            ),
          ),
          SizedBox(width: 36.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyleHelper.instance.title18RegularBebasNeue.copyWith(
        color: appTheme.gray_300,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
        color: enabled ? appTheme.gray_300 : appTheme.gray_500,
        fontSize: 14.fSize,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyleHelper.instance.body12MediumDMSans.copyWith(
          color: appTheme.gray_500,
        ),
        prefixIcon: Icon(icon, color: appTheme.orange_100, size: 19.h),
        filled: true,
        fillColor: appTheme.gray_900_02,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color19A48B),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color19A48B),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.orange_100),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color19A48B),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: _isSaving || _isChangingPassword ? null : _saveProfileInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.bookRedFill,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.h),
          ),
        ),
        child: Text(
          _isSaving ? 'SAVING...' : 'SAVE CHANGES',
          style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
            color: Colors.white,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: OutlinedButton(
        onPressed: _isSaving || _isChangingPassword ? null : _changePassword,
        style: OutlinedButton.styleFrom(
          foregroundColor: appTheme.orange_100,
          side: BorderSide(color: appTheme.bookRedBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.h),
          ),
        ),
        child: Text(
          _isChangingPassword ? 'UPDATING...' : 'UPDATE PASSWORD',
          style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
            color: appTheme.orange_100,
            letterSpacing: 1.4,
          ),
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
