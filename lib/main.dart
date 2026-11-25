import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'models/profile_model.dart';
import 'providers/app_providers.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/courses/courses_screen.dart';
import 'features/workload/workload_screen.dart';
import 'features/notes/notes_screen.dart';
import 'features/skills/skills_screen.dart';
import 'features/projects/projects_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/search/global_search_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

  runApp(const ProviderScope(child: DevOSApp()));
}

class DevOSApp extends StatelessWidget {
  const DevOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  late bool _isAuthenticated;
  bool _isDemoSession = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  void _initAuth() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(syncWorkspaceProvider);
        });
      }

      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) {
            if (_isDemoSession) return; // Retain local demo session
            final isAuth = data.session != null;
            if (mounted && isAuth != _isAuthenticated) {
              setState(() => _isAuthenticated = isAuth);
              if (isAuth) {
                ref.read(syncWorkspaceProvider);
              }
            }
          });
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _isAuthenticated = false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return LoginScreen(
        onLoginSuccess: () {
          bool isRemoteUser = false;
          try {
            isRemoteUser = Supabase.instance.client.auth.currentUser != null;
          } catch (_) {}
          setState(() {
            _isAuthenticated = true;
            _isDemoSession = !isRemoteUser;
          });
          ref.read(syncWorkspaceProvider);
        },
      );
    }

    return DevOSMainShell(
      onLogout: () async {
        await ref.read(authRepositoryProvider).signOut();
        setState(() {
          _isAuthenticated = false;
          _isDemoSession = false;
        });
      },
    );
  }
}

class DevOSMainShell extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const DevOSMainShell({super.key, required this.onLogout});

  @override
  ConsumerState<DevOSMainShell> createState() => _DevOSMainShellState();
}

class _DevOSMainShellState extends ConsumerState<DevOSMainShell> {
  int _currentIndex = 0;

  Widget _buildShellAvatar(UserProfile profile, double radius) {
    if (profile.avatarUrl.startsWith('data:image')) {
      try {
        final commaIndex = profile.avatarUrl.indexOf(',');
        final base64Data = commaIndex != -1
            ? profile.avatarUrl.substring(commaIndex + 1)
            : profile.avatarUrl;
        final bytes = base64Decode(base64Data);
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    } else if (profile.avatarUrl.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(profile.avatarUrl),
      );
    } else if (profile.avatarUrl.startsWith('preset:')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFDBEAFE),
        child: Icon(
          Icons.terminal_rounded,
          size: radius * 1.1,
          color: const Color(0xFF1E56FF),
        ),
      );
    }

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

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE2C9B8),
      child: Text(
        initials,
        style: GoogleFonts.jetBrainsMono(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    final pages = [
      DashboardScreen(
        onNavigateToTab: (index) => setState(() => _currentIndex = index),
      ),
      const CoursesScreen(),
      const WorkloadScreen(),
      const SkillsScreen(),
      const ProjectsScreen(),
      const NotesScreen(),
      ProfileScreen(
        onBackToDashboard: () => setState(() => _currentIndex = 0),
        onLogout: widget.onLogout,
      ),
      AnalyticsScreen(
        onBackToDashboard: () => setState(() => _currentIndex = 0),
        onNavigateToTab: (index) => setState(() => _currentIndex = index),
      ),
    ];

    final showDevOSTopBar = _currentIndex == 0 || _currentIndex == 1;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: showDevOSTopBar
          ? AppBar(
              backgroundColor: AppColors.background(context),
              elevation: 0,
              leadingWidth: 64,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Builder(
                  builder: (context) => Semantics(
                    label: 'Open Navigation Drawer',
                    button: true,
                    child: InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        child: _buildShellAvatar(profile, 17),
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
                  letterSpacing: 3.5,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Semantics(
                    label: 'Search DevOS Workspace',
                    button: true,
                    child: InkWell(
                      onTap: () {
                        showGlobalSearch(
                          context,
                          onNavigateToTab: (index) =>
                              setState(() => _currentIndex = index),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.figmaCardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      drawer: Drawer(
        backgroundColor: AppColors.surfaceLight,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.brandDarkBanner,
              ),
              onDetailsPressed: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 6);
              },
              accountName: Text(
                profile.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                profile.email,
                style: const TextStyle(color: Color(0xFFF3C7D4)),
              ),
              currentAccountPicture: Semantics(
                label: 'View Engineering Profile',
                button: true,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 6);
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.black,
                    child: _buildShellAvatar(profile, 36),
                  ),
                ),
              ),
            ),
            _buildDrawerTile(0, 'Dashboard Overview', Icons.dashboard_outlined),
            _buildDrawerTile(1, 'Courses & Syllabus', Icons.school_outlined),
            _buildDrawerTile(
              2,
              'Workload & Tasks',
              Icons.assignment_turned_in_rounded,
            ),
            _buildDrawerTile(3, 'Skill Matrix', Icons.code_rounded),
            _buildDrawerTile(
              4,
              'Software Projects',
              Icons.rocket_launch_outlined,
            ),
            _buildDrawerTile(
              5,
              'Notes & Knowledge Base',
              Icons.menu_book_rounded,
            ),
            _buildDrawerTile(
              6,
              'Engineering Profile',
              Icons.account_circle_outlined,
            ),
            _buildDrawerTile(
              7,
              'Productivity & Analytics',
              Icons.insights_rounded,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.saved_search_rounded,
                color: Color(0xFF1E56FF),
              ),
              title: Text(
                'Workspace Search',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandDarkBanner,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SEMANTIC',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                showGlobalSearch(
                  context,
                  onNavigateToTab: (index) =>
                      setState(() => _currentIndex = index),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.accentRose),
              title: const Text(
                'Logout / Switch User',
                style: TextStyle(color: AppColors.accentRose),
              ),
              onTap: widget.onLogout,
            ),
          ],
        ),
      ),
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: _buildFigmaBottomNavBar(),
    );
  }

  Widget _buildFigmaBottomNavBar() {
    return Container(
      color: AppColors.figmaBottomNav,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'Dashboard', Icons.grid_view_rounded),
            _buildNavItem(1, 'Courses', Icons.school_outlined),
            _buildNavItem(2, 'Workload', Icons.assignment_turned_in_rounded),
            _buildNavItem(3, 'Skills', Icons.terminal_rounded),
            _buildNavItem(4, 'Projects', Icons.alt_route_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.figmaNavActive,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF800028), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFF3C7D4),
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? Colors.white : const Color(0xFFF3C7D4),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textMutedLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
