import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'providers/app_providers.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/courses/courses_screen.dart';
import 'features/skills/skills_screen.dart';
import 'features/projects/projects_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/goals/goals_screen.dart';
import 'features/notes/notes_screen.dart';
import 'features/research/research_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/search/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: DevOSApp(),
    ),
  );
}

class DevOSApp extends ConsumerWidget {
  const DevOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'DevOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = true; // Set to true by default for instant local dashboard access

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return LoginScreen(
        onLoginSuccess: () => setState(() => _isAuthenticated = true),
      );
    }

    return DevOSMainShell(
      onLogout: () => setState(() => _isAuthenticated = false),
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

  final List<String> _titles = [
    'Dashboard Overview',
    'Courses & Syllabus',
    'Technical Skill Matrix',
    'Software Projects',
    'Tasks & Workload',
    'Goals & Roadmaps',
    'Notes & Knowledge Base',
    'Research Papers',
    'Calendar & Deadlines',
    'Analytics & Progress',
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final pages = [
      DashboardScreen(onNavigateToTab: (index) => setState(() => _currentIndex = index)),
      const CoursesScreen(),
      const SkillsScreen(),
      const ProjectsScreen(),
      const TasksScreen(),
      const GoalsScreen(),
      const NotesScreen(),
      const ResearchScreen(),
      const CalendarScreen(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.backgroundDark,
              ),
              accountName: const Text('Alex Vance', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text('alex.dev@university.edu', style: TextStyle(color: AppColors.primary)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: const Text('AV', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildDrawerTile(0, 'Dashboard Overview', Icons.dashboard_outlined),
            _buildDrawerTile(1, 'Courses & Syllabus', Icons.school_outlined),
            _buildDrawerTile(2, 'Skill Matrix', Icons.code_rounded),
            _buildDrawerTile(3, 'Software Projects', Icons.rocket_launch_outlined),
            _buildDrawerTile(4, 'Task Management', Icons.task_alt),
            _buildDrawerTile(5, 'Goals & Roadmaps', Icons.flag_outlined),
            _buildDrawerTile(6, 'Notes & Knowledge Base', Icons.description_outlined),
            _buildDrawerTile(7, 'Research Papers', Icons.menu_book_outlined),
            _buildDrawerTile(8, 'Calendar & Deadlines', Icons.calendar_month_outlined),
            _buildDrawerTile(9, 'Analytics & Stats', Icons.bar_chart_rounded),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.accentRose),
              title: const Text('Logout', style: TextStyle(color: AppColors.accentRose)),
              onTap: widget.onLogout,
            ),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code_rounded),
            activeIcon: Icon(Icons.code),
            label: 'Skills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined),
            activeIcon: Icon(Icons.rocket_launch),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            activeIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(int index, String title, IconData icon) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMutedDark),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimaryDark,
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
