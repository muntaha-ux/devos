import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../models/profile_model.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';

/// Professional Engineering Profile Screen for DevOS.
/// Displays student/engineer credentials, academic details, workspace metrics,
/// and includes an interactive profile picture upload & preset avatar system.
class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackToDashboard;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.onBackToDashboard,
    this.onLogout,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isUploadingPhoto = false;

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _institutionController;
  late TextEditingController _majorController;
  late TextEditingController _bioController;
  String _academicYear = '3rd Year (Junior)';

  final List<String> _academicYears = [
    '1st Year (Freshman)',
    '2nd Year (Sophomore)',
    '3rd Year (Junior)',
    '4th Year (Senior)',
    'Graduate / Master\'s',
    'PhD Candidate',
  ];

  // Preset engineering avatar options
  final List<Map<String, dynamic>> _presetAvatars = [
    {
      'label': 'Architect',
      'id': 'preset_architect',
      'icon': Icons.architecture_rounded,
      'color': const Color(0xFF1E56FF),
      'bg': const Color(0xFFDBEAFE),
    },
    {
      'label': 'Hacker',
      'id': 'preset_hacker',
      'icon': Icons.terminal_rounded,
      'color': const Color(0xFF0EA358),
      'bg': const Color(0xFFDCFCE7),
    },
    {
      'label': 'Robotics',
      'id': 'preset_robotics',
      'icon': Icons.precision_manufacturing_rounded,
      'color': const Color(0xFFE11D48),
      'bg': const Color(0xFFFFE4E6),
    },
    {
      'label': 'Cloud/DevOps',
      'id': 'preset_cloud',
      'icon': Icons.cloud_done_rounded,
      'color': const Color(0xFF7C3AED),
      'bg': const Color(0xFFF3E8FF),
    },
    {
      'label': 'AI Research',
      'id': 'preset_ai',
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFFEA580C),
      'bg': const Color(0xFFFFEDD5),
    },
    {
      'label': 'Hardware',
      'id': 'preset_hardware',
      'icon': Icons.memory_rounded,
      'color': const Color(0xFF0284C7),
      'bg': const Color(0xFFE0F2FE),
    },
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _fullNameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _institutionController = TextEditingController(text: profile.institution);
    _majorController = TextEditingController(text: profile.major);
    _bioController = TextEditingController(text: profile.bio);
    _academicYear = profile.academicYear.isNotEmpty &&
            _academicYears.contains(profile.academicYear)
        ? profile.academicYear
        : '3rd Year (Junior)';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final current = ref.read(profileProvider);
    final updated = current.copyWith(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      institution: _institutionController.text.trim(),
      major: _majorController.text.trim(),
      academicYear: _academicYear,
      bio: _bioController.text.trim(),
    );

    ref.read(profileProvider.notifier).setProfile(updated);
    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Engineering profile credentials updated successfully!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.figmaCodeBadge,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    Navigator.of(context).pop(); // Close bottom sheet
    setState(() => _isUploadingPhoto = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      String newAvatarUrl = '';

      // Try uploading to Supabase Storage if authenticated
      try {
        final client = Supabase.instance.client;
        final user = client.auth.currentUser;
        if (user != null) {
          final fileExt = pickedFile.name.split('.').last.toLowerCase();
          final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final storagePath = '${user.id}/$fileName';

          await client.storage.from('avatars').uploadBinary(
                storagePath,
                bytes,
                fileOptions: const FileOptions(upsert: true),
              );

          newAvatarUrl = client.storage.from('avatars').getPublicUrl(storagePath);
        }
      } catch (storageError) {
        debugPrint('Supabase Storage bucket upload note: $storageError');
      }

      // If cloud storage upload did not return a URL, fallback to portable base64 Data URI
      if (newAvatarUrl.isEmpty) {
        final base64String = base64Encode(bytes);
        newAvatarUrl = 'data:image/jpeg;base64,$base64String';
      }

      final current = ref.read(profileProvider);
      final updated = current.copyWith(avatarUrl: newAvatarUrl);
      ref.read(profileProvider.notifier).setProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile picture updated successfully!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.figmaCodeBadge,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load image: $e'),
            backgroundColor: AppColors.accentRose,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _applyPresetAvatar(String presetId) {
    Navigator.of(context).pop();
    final current = ref.read(profileProvider);
    final updated = current.copyWith(avatarUrl: 'preset:$presetId');
    ref.read(profileProvider.notifier).setProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preset avatar selected!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _removePhoto() {
    Navigator.of(context).pop();
    final current = ref.read(profileProvider);
    final updated = current.copyWith(avatarUrl: '');
    ref.read(profileProvider.notifier).setProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile picture removed. Reverted to monogram initials.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _showAvatarOptionsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload a custom photo or choose an engineering archetype',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.figmaBottomNav.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.figmaBottomNav,
                    ),
                  ),
                  title: Text(
                    'Upload from Gallery / Files',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('PNG, JPG or WebP images'),
                  onTap: _pickAndUploadPhoto,
                ),
                const Divider(),
                Text(
                  'Choose Engineering Preset',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final preset = _presetAvatars[index];
                      return InkWell(
                        onTap: () => _applyPresetAvatar(preset['id'] as String),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: preset['bg'] as Color,
                              child: Icon(
                                preset['icon'] as IconData,
                                color: preset['color'] as Color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              preset['label'] as String,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.accentRose,
                    ),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentRose,
                    ),
                  ),
                  onTap: _removePhoto,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget(UserProfile profile) {
    const avatarRadius = 48.0;

    Widget avatarContent;

    if (profile.avatarUrl.startsWith('data:image')) {
      try {
        final commaIndex = profile.avatarUrl.indexOf(',');
        final base64Data = commaIndex != -1
            ? profile.avatarUrl.substring(commaIndex + 1)
            : profile.avatarUrl;
        final bytes = base64Decode(base64Data);
        avatarContent = ClipOval(
          child: Image.memory(
            bytes,
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        avatarContent = _buildMonogram(profile);
      }
    } else if (profile.avatarUrl.startsWith('http')) {
      avatarContent = ClipOval(
        child: Image.network(
          profile.avatarUrl,
          width: avatarRadius * 2,
          height: avatarRadius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildMonogram(profile),
        ),
      );
    } else if (profile.avatarUrl.startsWith('preset:')) {
      final presetId = profile.avatarUrl.replaceFirst('preset:', '');
      final preset = _presetAvatars.firstWhere(
        (p) => p['id'] == presetId,
        orElse: () => _presetAvatars.first,
      );
      avatarContent = CircleAvatar(
        radius: avatarRadius,
        backgroundColor: preset['bg'] as Color,
        child: Icon(
          preset['icon'] as IconData,
          size: 48,
          color: preset['color'] as Color,
        ),
      );
    } else {
      avatarContent = _buildMonogram(profile);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: avatarRadius + 3,
          backgroundColor: Colors.black,
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: const Color(0xFFE2C9B8),
            child: avatarContent,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Semantics(
            label: 'Change Profile Photo',
            button: true,
            child: InkWell(
              onTap: _isUploadingPhoto ? null : _showAvatarOptionsBottomSheet,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.figmaBottomNav,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isUploadingPhoto
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonogram(UserProfile profile) {
    final cleanName = profile.fullName.trim();
    String initials = 'DV';
    if (cleanName.isNotEmpty) {
      final parts =
          cleanName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      } else if (cleanName.length >= 2) {
        initials = cleanName.substring(0, 2).toUpperCase();
      } else {
        initials = cleanName.toUpperCase();
      }
    }

    return Center(
      child: Text(
        initials,
        style: GoogleFonts.jetBrainsMono(
          color: AppColors.brandDarkBanner,
          fontWeight: FontWeight.w900,
          fontSize: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final courses = ref.watch(coursesProvider);
    final tasks = ref.watch(tasksProvider);
    final projects = ref.watch(projectsProvider);
    final skills = ref.watch(skillsProvider);

    final completedTasksCount =
        tasks.where((t) => t.status == TaskStatus.completed).length;

    return Container(
      color: AppColors.background(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.onBackToDashboard != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textPrimaryLight,
                        tooltip: 'Back to Dashboard',
                        onPressed: widget.onBackToDashboard,
                      ),
                    Text(
                      'Engineering Profile',
                      style: GoogleFonts.inter(
                        color: AppColors.textHeading(context),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing
                        ? AppColors.figmaCodeBadge
                        : AppColors.figmaCardDark,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  icon: Icon(
                    _isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _isEditing ? 'Save Profile' : 'Edit Profile',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Profile Header Card (Dark Banner Styling)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.brandDarkBanner,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black87,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatarWidget(profile),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.major,
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFF3C7D4),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.institution,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.figmaCodeBadge
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.figmaCodeBadge,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        color: AppColors.accentAmber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${profile.learningStreak}d Streak',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.white38,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    profile.academicYear,
                                    style: GoogleFonts.jetBrainsMono(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        profile.bio,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Engineering Metrics Overview
            Text(
              'ACADEMIC PULSE & VELOCITY',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'COURSES',
                    value: '${courses.length}',
                    subtext: 'Enrolled',
                    icon: Icons.school_outlined,
                    color: AppColors.figmaCyanCard,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'TASKS DONE',
                    value: '$completedTasksCount / ${tasks.length}',
                    subtext: 'Completed',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.figmaCodeBadge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'PROJECTS',
                    value: '${projects.length}',
                    subtext: 'Active Repos',
                    icon: Icons.rocket_launch_outlined,
                    color: AppColors.figmaOrangeCard,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'SKILLS',
                    value: '${skills.length}',
                    subtext: 'Matrix Domains',
                    icon: Icons.code_rounded,
                    color: AppColors.figmaPurpleCard,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Details & Edit Section
            Text(
              'CREDENTIALS & INSTITUTION DETAILS',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.cardBorder(context),
                  width: 1.2,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildFieldLabel('Full Name'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _fullNameController,
                      enabled: _isEditing,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: !_isEditing,
                        fillColor: Colors.grey.shade100,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Email Address
                    _buildFieldLabel('Email Address'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _emailController,
                      enabled: _isEditing,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.textPrimaryLight,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: !_isEditing,
                        fillColor: Colors.grey.shade100,
                      ),
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Institution / University
                    _buildFieldLabel('Institution / University'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _institutionController,
                      enabled: _isEditing,
                      style: GoogleFonts.inter(color: AppColors.textPrimaryLight),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.account_balance_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: !_isEditing,
                        fillColor: Colors.grey.shade100,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Institution required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Major / Department
                    _buildFieldLabel('Major / Department'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _majorController,
                      enabled: _isEditing,
                      style: GoogleFonts.inter(color: AppColors.textPrimaryLight),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.computer_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: !_isEditing,
                        fillColor: Colors.grey.shade100,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Major required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Academic Year
                    _buildFieldLabel('Academic Year'),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _academicYears.contains(_academicYear)
                          ? _academicYear
                          : _academicYears[2],
                      onChanged: _isEditing
                          ? (val) {
                              if (val != null) setState(() => _academicYear = val);
                            }
                          : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: !_isEditing,
                        fillColor: Colors.grey.shade100,
                      ),
                      items: _academicYears
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text(
                                y,
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),

                    // Engineering Bio
                    _buildFieldLabel('Engineering Bio & Specialization'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _bioController,
                      enabled: _isEditing,
                      maxLines: 3,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.textPrimaryLight,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Distributed Systems & Concurrency, Micro-ROS, Flutter Architecture...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: !_isEditing,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions & Utilities
            Text(
              'SYSTEM ACTIONS & DATA CONTROL',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),

            Material(
              color: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: AppColors.cardBorder(context),
                  width: 1.2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.accentAmber,
                    ),
                    title: Text(
                      'Log Today\'s Study Session (+1 Streak)',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Increment your daily learning streak'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      ref.read(profileProvider.notifier).incrementStreak();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Streak incremented! Current streak: ${profile.learningStreak + 1} days 🔥',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.sync_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Sync Workspace with Cloud',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Reload all courses, tasks, and notes from Supabase'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () async {
                      await ref.read(syncWorkspaceProvider.future);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Workspace synced with Supabase cloud successfully!',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppColors.figmaCodeBadge,
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.textMutedLight,
                    ),
                    title: Text(
                      'Copy Student ID / UUID',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      profile.id.isNotEmpty ? profile.id : 'Local Demo Student',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.copy_rounded, size: 16),
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: profile.id.isNotEmpty
                              ? profile.id
                              : 'demo-student-alex-001',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Student UUID copied to clipboard!',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.figmaCardDark,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  if (widget.onLogout != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.accentRose,
                      ),
                      title: Text(
                        'Logout / Switch Account',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentRose,
                        ),
                      ),
                      onTap: widget.onLogout,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textMutedLight,
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardBorder(context),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMutedLight,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
