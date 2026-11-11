import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/app_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final VoidCallback onSignUpSuccess;
  final VoidCallback? onNavigateToLogin;

  const SignUpScreen({
    super.key,
    required this.onSignUpSuccess,
    this.onNavigateToLogin,
  });

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _institutionController = TextEditingController(
    text: 'University of Science & Tech',
  );
  final _majorController = TextEditingController(
    text: 'Computer Science & Engineering',
  );
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _academicYear = '3rd Year (Junior)';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;

  final List<String> _academicYears = [
    '1st Year (Freshman)',
    '2nd Year (Sophomore)',
    '3rd Year (Junior)',
    '4th Year (Senior)',
    'Graduate / Master\'s',
    'PhD Candidate',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    _majorController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please agree to DevOS Terms & Academic Guidelines to proceed.',
          ),
          backgroundColor: AppColors.accentAmber,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final institution = _institutionController.text.trim();
    final major = _majorController.text.trim();

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.signUp(
      email: email,
      password: password,
      fullName: fullName,
      institution: institution,
      major: major,
      academicYear: _academicYear,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.user != null) {
      ref.read(profileProvider.notifier).setProfile(result.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.requiresEmailConfirmation
                ? 'Account created! Confirmation link sent. Welcome, $fullName.'
                : 'Account created successfully! Welcome, $fullName.',
          ),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 3),
        ),
      );
      widget.onSignUpSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Registration failed.'),
          backgroundColor: AppColors.accentRose,
          action: widget.onNavigateToLogin != null
              ? SnackBarAction(
                  label: 'Sign In',
                  textColor: Colors.white,
                  onPressed: widget.onNavigateToLogin!,
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.figmaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.figmaBackground,
        elevation: 0,
        leadingWidth: 64,
        leading: widget.onNavigateToLogin != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                onPressed: widget.onNavigateToLogin,
              )
            : Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Center(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: const Color(0xFFE2C9B8),
                      child: Text(
                        'DV',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        centerTitle: true,
        title: Text(
          'DevOS',
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.figmaBlue,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.figmaCardDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Dark Purple Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.figmaDarkPurpleBanner,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF201633),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Registration',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'POSTGRESQL & WORKSPACE ACCESS',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFFD6BCFA),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '• SECURE',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Main Card Stack with Floating Green </> Code Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: AppColors.figmaMetricCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Student Profile',
                                style: GoogleFonts.inter(
                                  color: AppColors.figmaTextRed,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Initialize your developer profile to track courses & sprints',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                color: Color(0xFFA69090),
                                thickness: 1,
                              ),
                              const SizedBox(height: 14),

                              _buildFieldLabel('Full Name *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _fullNameController,
                                textCapitalization: TextCapitalization.words,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                decoration: _buildInputDecoration(
                                  hint: 'e.g. Alex Vance',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: FormValidators.validateName,
                              ),
                              const SizedBox(height: 12),

                              _buildFieldLabel('University Email *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                decoration: _buildInputDecoration(
                                  hint: 'alex.dev@university.edu',
                                  icon: Icons.alternate_email_rounded,
                                ),
                                validator: FormValidators.validateEmail,
                              ),
                              const SizedBox(height: 12),

                              _buildFieldLabel('Institution / University'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _institutionController,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                decoration: _buildInputDecoration(
                                  hint:
                                      'e.g. Institute of Science & Technology',
                                  icon: Icons.account_balance_outlined,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildFieldLabel('Major / Department'),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _majorController,
                                          style: GoogleFonts.inter(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          decoration: _buildInputDecoration(
                                            hint: 'Computer Science',
                                            icon: Icons.code_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildFieldLabel('Year'),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          initialValue:
                                              _academicYears.contains(
                                                _academicYear,
                                              )
                                              ? _academicYear
                                              : _academicYears[2],
                                          isExpanded: true,
                                          dropdownColor: Colors.white,
                                          style: GoogleFonts.inter(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF333333),
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF333333),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: AppColors.figmaBlue,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 12,
                                                ),
                                          ),
                                          items: _academicYears.map((year) {
                                            return DropdownMenuItem<String>(
                                              value: year,
                                              child: Text(
                                                year,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(
                                                () => _academicYear = val,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _buildFieldLabel('Password *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                decoration: _buildInputDecoration(
                                  hint: 'Min 6 characters',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 18,
                                      color: const Color(0xFF555555),
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: FormValidators.validatePassword,
                              ),
                              const SizedBox(height: 12),

                              _buildFieldLabel('Confirm Password *'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                decoration: _buildInputDecoration(
                                  hint: 'Re-enter password',
                                  icon: Icons.lock_reset_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 18,
                                      color: const Color(0xFF555555),
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    ),
                                  ),
                                ),
                                validator: (val) =>
                                    FormValidators.validateConfirmPassword(
                                      val,
                                      _passwordController.text,
                                    ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _agreedToTerms,
                                      activeColor: AppColors.figmaBottomNav,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF333333),
                                        width: 1.2,
                                      ),
                                      onChanged: (val) => setState(
                                        () => _agreedToTerms = val ?? false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'I agree to DevOS Terms & Academic Guidelines.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.figmaBottomNav,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                        color: Color(0xFF333333),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.person_add_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'CREATE DEVOS ACCOUNT',
                                              style: GoogleFonts.jetBrainsMono(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                letterSpacing: 0.5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (widget.onNavigateToLogin != null)
                                Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account?',
                                        style: GoogleFonts.inter(
                                          color: Colors.black87,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: widget.onNavigateToLogin,
                                        child: Text(
                                          'Sign In',
                                          style: GoogleFonts.jetBrainsMono(
                                            color: AppColors.figmaBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: -10,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.figmaCodeBadge,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF333333),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '</>',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTagBadge('#Flutter', const Color(0xFF6B21A8)),
                      _buildTagBadge('#Supabase', const Color(0xFF16A34A)),
                      _buildTagBadge('#PostgreSQL', AppColors.figmaBlue),
                      _buildTagBadge('#CloudflareR2', const Color(0xFFDC2626)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF757575),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF333333)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.figmaBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentRose, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentRose, width: 2),
      ),
    );
  }

  Widget _buildTagBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF333333), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
