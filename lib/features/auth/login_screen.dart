import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/profile_model.dart';
import '../../providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;
  final bool initialIsSignUp;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    this.initialIsSignUp = false,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late bool _isSignUp;

  // Sign In Form Controllers
  final _signInFormKey = GlobalKey<FormState>();
  final _signInEmailController = TextEditingController(
    text: 'alex.dev@university.edu',
  );
  final _signInPasswordController = TextEditingController(text: 'password123');
  bool _obscureSignInPassword = true;

  // Sign Up Form Controllers
  final _signUpFormKey = GlobalKey<FormState>();
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpInstitutionController = TextEditingController(
    text: 'University of Science & Tech',
  );
  final _signUpMajorController = TextEditingController(
    text: 'Computer Science & Engineering',
  );
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  String _signUpAcademicYear = '3rd Year (Junior)';
  bool _obscureSignUpPassword = true;
  bool _obscureSignUpConfirmPassword = true;
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
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpInstitutionController.dispose();
    _signUpMajorController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleDemoSignIn() async {
    setState(() => _isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.signInAsDemo();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.user != null) {
      ref.read(profileProvider.notifier).setProfile(result.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged in as Demo Student (${result.user!.fullName})'),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
      widget.onLoginSuccess();
    }
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text;

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.signIn(email: email, password: password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.user != null) {
      ref.read(profileProvider.notifier).setProfile(result.user!);
      widget.onLoginSuccess();
    } else {
      final isConnectionIssue =
          result.errorMessage?.contains('CORS') == true ||
          result.errorMessage?.contains('Supabase') == true ||
          result.errorMessage?.contains('reach') == true ||
          result.errorMessage?.contains('connection') == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Sign in failed. Please check credentials.',
          ),
          backgroundColor: AppColors.accentRose,
          duration: const Duration(seconds: 6),
          action: isConnectionIssue
              ? SnackBarAction(
                  label: 'ENTER DEMO',
                  textColor: Colors.white,
                  onPressed: _handleDemoSignIn,
                )
              : null,
        ),
      );
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to DevOS Terms & Academic Guidelines.'),
          backgroundColor: AppColors.accentAmber,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fullName = _signUpNameController.text.trim();
    final email = _signUpEmailController.text.trim();
    final password = _signUpPasswordController.text;
    final institution = _signUpInstitutionController.text.trim();
    final major = _signUpMajorController.text.trim();

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.signUp(
      email: email,
      password: password,
      fullName: fullName,
      institution: institution,
      major: major,
      academicYear: _signUpAcademicYear,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.user != null) {
      ref.read(profileProvider.notifier).setProfile(result.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created! Welcome to DevOS, $fullName.'),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 3),
        ),
      );
      widget.onLoginSuccess();
    } else {
      final isConnectionIssue =
          result.errorMessage?.contains('CORS') == true ||
          result.errorMessage?.contains('Supabase') == true ||
          result.errorMessage?.contains('reach') == true ||
          result.errorMessage?.contains('connection') == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Sign up failed.'),
          backgroundColor: AppColors.accentRose,
          duration: const Duration(seconds: 6),
          action: isConnectionIssue
              ? SnackBarAction(
                  label: 'PROCEED OFFLINE',
                  textColor: Colors.white,
                  onPressed: () {
                    final localProfile = UserProfile(
                      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
                      email: email,
                      fullName: fullName,
                      avatarUrl: '',
                      institution: institution.isNotEmpty
                          ? institution
                          : 'University of Science & Tech',
                      major: major.isNotEmpty
                          ? major
                          : 'Computer Science & Engineering',
                      academicYear: _signUpAcademicYear,
                      learningStreak: 1,
                    );
                    ref.read(profileProvider.notifier).setProfile(localProfile);
                    widget.onLoginSuccess();
                  },
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
        leading: Padding(
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
                  Icons.terminal_rounded,
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
                  // Top Banner (Matching Projects screen purple banner)
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
                              Icons.lock_outline_rounded,
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
                                _isSignUp
                                    ? 'Developer Registration'
                                    : 'Engineering Workspace',
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Segmented Switcher: [ Sign In ] [ Register ]
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.figmaCardDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF333333),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildSegmentButton(
                                      label: 'Sign In',
                                      icon: Icons.login_rounded,
                                      isSelected: !_isSignUp,
                                      onTap: () =>
                                          setState(() => _isSignUp = false),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildSegmentButton(
                                      label: 'Register',
                                      icon: Icons.person_add_rounded,
                                      isSelected: _isSignUp,
                                      onTap: () =>
                                          setState(() => _isSignUp = true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Header Text in Dashboard Red
                            Text(
                              _isSignUp
                                  ? 'Create Student Profile'
                                  : 'Welcome Back',
                              style: GoogleFonts.inter(
                                color: AppColors.figmaTextRed,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isSignUp
                                  ? 'Initialize your developer profile to track courses & sprints'
                                  : 'Sign in to access your coursework, skills, and projects',
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

                            // Form Content
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _isSignUp
                                  ? _buildSignUpForm()
                                  : _buildSignInForm(),
                            ),
                          ],
                        ),
                      ),

                      // Green floating </> badge at the bottom-right corner (Dashboard signature)
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

                  // Technology Badges (Projects style tags)
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

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.figmaBottomNav : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF333333), width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== SIGN IN FORM =====================
  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demo Account Quick Helper Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Account: alex.dev@university.edu',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _signInEmailController.text = 'alex.dev@university.edu';
                      _signInPasswordController.text = 'password123';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Auto-Fill',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          _buildFieldLabel('University Email'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
            decoration: _buildInputDecoration(
              hint: 'alex.dev@university.edu',
              icon: Icons.alternate_email_rounded,
            ),
            validator: FormValidators.validateEmail,
          ),
          const SizedBox(height: 14),

          _buildFieldLabel('Password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
            decoration: _buildInputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignInPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: const Color(0xFF555555),
                ),
                onPressed: () => setState(
                  () => _obscureSignInPassword = !_obscureSignInPassword,
                ),
              ),
            ),
            validator: FormValidators.validatePassword,
          ),
          const SizedBox(height: 20),

          // Primary Launch Button (Figma Bottom Nav style)
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBottomNav,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF333333), width: 1),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.login_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LAUNCH DASHBOARD',
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
          const SizedBox(height: 10),

          // Secondary Demo Mode Button (100% offline & CORS resilient)
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleDemoSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF4B5563), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'CONTINUE AS DEMO STUDENT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Switch to Register Prompt
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: GoogleFonts.inter(color: Colors.black87, fontSize: 12),
                ),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = true),
                  child: Text(
                    'Create Account',
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
    );
  }

  // ===================== SIGN UP FORM =====================
  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Full Name *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpNameController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
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
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
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
            controller: _signUpInstitutionController,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
            decoration: _buildInputDecoration(
              hint: 'e.g. Institute of Science & Technology',
              icon: Icons.account_balance_outlined,
            ),
          ),
          const SizedBox(height: 12),

          // Major and Academic Year
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Major / Department'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _signUpMajorController,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Year'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _academicYears.contains(_signUpAcademicYear)
                          ? _signUpAcademicYear
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
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.figmaBlue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
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
                          setState(() => _signUpAcademicYear = val);
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
            controller: _signUpPasswordController,
            obscureText: _obscureSignUpPassword,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
            decoration: _buildInputDecoration(
              hint: 'Min 6 characters',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignUpPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: const Color(0xFF555555),
                ),
                onPressed: () => setState(
                  () => _obscureSignUpPassword = !_obscureSignUpPassword,
                ),
              ),
            ),
            validator: FormValidators.validatePassword,
          ),
          const SizedBox(height: 12),

          _buildFieldLabel('Confirm Password *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signUpConfirmPasswordController,
            obscureText: _obscureSignUpConfirmPassword,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
            decoration: _buildInputDecoration(
              hint: 'Re-enter password',
              icon: Icons.lock_reset_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignUpConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: const Color(0xFF555555),
                ),
                onPressed: () => setState(
                  () => _obscureSignUpConfirmPassword =
                      !_obscureSignUpConfirmPassword,
                ),
              ),
            ),
            validator: (val) => FormValidators.validateConfirmPassword(
              val,
              _signUpPasswordController.text,
            ),
          ),
          const SizedBox(height: 12),

          // Terms Checkbox
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
                  side: const BorderSide(color: Color(0xFF333333), width: 1.2),
                  onChanged: (val) =>
                      setState(() => _agreedToTerms = val ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I agree to DevOS Terms & Academic Guidelines.',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Submit Button
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
                  side: const BorderSide(color: Color(0xFF333333), width: 1),
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 10),

          // Secondary Demo Mode Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleDemoSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF4B5563), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'EXPLORE AS DEMO STUDENT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Switch to Sign In Prompt
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(color: Colors.black87, fontSize: 12),
                ),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = false),
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
