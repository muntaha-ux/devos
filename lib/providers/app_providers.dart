import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_model.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';
import '../models/note_model.dart';
import '../models/research_model.dart';
import '../models/event_model.dart';
import '../repositories/interfaces/i_auth_repository.dart';
import '../repositories/supabase_auth_repository.dart';
import '../repositories/supabase_database_repository.dart';

// Authentication Repository Provider (DIP)
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return SupabaseAuthRepository();
});

// Supabase Database Repository Provider
final databaseRepositoryProvider = Provider<SupabaseDatabaseRepository>((ref) {
  return SupabaseDatabaseRepository();
});

// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

// ===================== USER PROFILE PROVIDER =====================
class ProfileNotifier extends StateNotifier<UserProfile> {
  final SupabaseDatabaseRepository _db;

  ProfileNotifier(this._db)
    : super(
        UserProfile(
          id: '',
          email: '',
          fullName: 'Engineering Student',
          avatarUrl: '',
          institution: 'University of Technology',
          major: 'Computer Science & Engineering',
          academicYear: '3rd Year (Junior)',
          learningStreak: 1,
        ),
      ) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final profile = await _db.getProfile();
    if (profile != null) {
      state = profile;
    }
  }

  void setProfile(UserProfile profile) {
    state = profile;
    _db.updateProfile(profile);
  }

  void incrementStreak() {
    state = state.copyWith(learningStreak: state.learningStreak + 1);
    _db.updateProfile(state);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((
  ref,
) {
  final db = ref.watch(databaseRepositoryProvider);
  return ProfileNotifier(db);
});

// ===================== COURSES PROVIDER =====================
class CoursesNotifier extends StateNotifier<List<Course>> {
  final SupabaseDatabaseRepository _db;

  CoursesNotifier(this._db) : super([]) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    final list = await _db.getCourses();
    state = list;
  }

  Future<void> toggleTopic(String courseId, String topicId) async {
    CourseTopic? toggledTopic;
    state = state.map((course) {
      if (course.id == courseId) {
        final updatedTopics = course.topics.map((t) {
          if (t.id == topicId) {
            toggledTopic = t.copyWith(isCompleted: !t.isCompleted);
            return toggledTopic!;
          }
          return t;
        }).toList();

        final completedCount = updatedTopics.where((t) => t.isCompleted).length;
        final newPercentage = updatedTopics.isEmpty
            ? 0
            : ((completedCount / updatedTopics.length) * 100).round();

        return course.copyWith(
          progressPercentage: newPercentage,
          topics: updatedTopics,
        );
      }
      return course;
    }).toList();

    if (toggledTopic != null) {
      await _db.toggleCourseTopic(topicId, toggledTopic!.isCompleted);
    }
  }

  Future<void> addCourse(Course course) async {
    final created = await _db.addCourse(course);
    state = [created, ...state];
  }

  Future<void> updateCourse(Course updated) async {
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
    await _db.updateCourse(updated);
  }

  Future<void> deleteCourse(String courseId) async {
    state = state.where((c) => c.id != courseId).toList();
    await _db.deleteCourse(courseId);
  }
}

final coursesProvider = StateNotifierProvider<CoursesNotifier, List<Course>>((
  ref,
) {
  final db = ref.watch(databaseRepositoryProvider);
  return CoursesNotifier(db);
});

// ===================== SKILLS PROVIDER =====================
class SkillsNotifier extends StateNotifier<List<Skill>> {
  final SupabaseDatabaseRepository _db;

  SkillsNotifier(this._db) : super([]) {
    loadSkills();
  }

  Future<void> loadSkills() async {
    final list = await _db.getSkills();
    state = list;
  }

  Future<void> toggleSkillTopic(String skillId, String topicId) async {
    SkillTopic? toggledTopic;
    state = state.map((skill) {
      if (skill.id == skillId) {
        final updatedTopics = skill.topics.map((t) {
          if (t.id == topicId) {
            toggledTopic = t.copyWith(isCompleted: !t.isCompleted);
            return toggledTopic!;
          }
          return t;
        }).toList();

        final completedCount = updatedTopics.where((t) => t.isCompleted).length;
        final newPercentage = updatedTopics.isEmpty
            ? 0
            : ((completedCount / updatedTopics.length) * 100).round();

        return skill.copyWith(
          progressPercentage: newPercentage,
          topics: updatedTopics,
        );
      }
      return skill;
    }).toList();

    if (toggledTopic != null) {
      await _db.toggleSkillTopic(topicId, toggledTopic!.isCompleted);
    }
  }

  Future<void> addSkill(Skill skill) async {
    final created = await _db.addSkill(skill);
    state = [created, ...state];
  }

  Future<void> updateSkill(Skill updated) async {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
    await _db.updateSkill(updated);
  }

  Future<void> deleteSkill(String skillId) async {
    state = state.where((s) => s.id != skillId).toList();
    await _db.deleteSkill(skillId);
  }
}

final skillsProvider = StateNotifierProvider<SkillsNotifier, List<Skill>>((
  ref,
) {
  final db = ref.watch(databaseRepositoryProvider);
  return SkillsNotifier(db);
});

// ===================== PROJECTS PROVIDER =====================
class ProjectsNotifier extends StateNotifier<List<Project>> {
  final SupabaseDatabaseRepository _db;

  ProjectsNotifier(this._db) : super([]) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    final list = await _db.getProjects();
    state = list;
  }

  Future<void> toggleMilestone(String projectId, String milestoneId) async {
    ProjectMilestone? toggled;
    state = state.map((project) {
      if (project.id == projectId) {
        final updatedMilestones = project.milestones.map((m) {
          if (m.id == milestoneId) {
            toggled = m.copyWith(isCompleted: !m.isCompleted);
            return toggled!;
          }
          return m;
        }).toList();

        final completedCount = updatedMilestones
            .where((m) => m.isCompleted)
            .length;
        final newPercentage = updatedMilestones.isEmpty
            ? 0
            : ((completedCount / updatedMilestones.length) * 100).round();

        return project.copyWith(
          status: newPercentage == 100 ? 'completed' : project.status,
          progressPercentage: newPercentage,
          milestones: updatedMilestones,
        );
      }
      return project;
    }).toList();

    if (toggled != null) {
      await _db.toggleProjectMilestone(milestoneId, toggled!.isCompleted);
    }
  }

  Future<void> addProject(Project project) async {
    final created = await _db.addProject(project);
    state = [created, ...state];
  }

  Future<void> updateProject(Project updated) async {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    await _db.updateProject(updated);
  }

  Future<void> deleteProject(String projectId) async {
    state = state.where((p) => p.id != projectId).toList();
    await _db.deleteProject(projectId);
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>(
  (ref) {
    final db = ref.watch(databaseRepositoryProvider);
    return ProjectsNotifier(db);
  },
);

// ===================== TASKS PROVIDER =====================
class TasksNotifier extends StateNotifier<List<DevTask>> {
  final SupabaseDatabaseRepository _db;

  TasksNotifier(this._db) : super([]) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final list = await _db.getTasks();
    state = list;
  }

  Future<void> toggleTaskStatus(String taskId) async {
    DevTask? updatedTask;
    state = state.map((task) {
      if (task.id == taskId) {
        final nextStatus = task.status == TaskStatus.completed
            ? TaskStatus.pending
            : TaskStatus.completed;
        updatedTask = task.copyWith(status: nextStatus);
        return updatedTask!;
      }
      return task;
    }).toList();

    if (updatedTask != null) {
      await _db.updateTask(updatedTask!);
    }
  }

  Future<void> addTask(DevTask task) async {
    final created = await _db.addTask(task);
    state = [created, ...state];
  }

  Future<void> updateTask(DevTask updated) async {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
    await _db.updateTask(updated);
  }

  Future<void> deleteTask(String taskId) async {
    state = state.where((t) => t.id != taskId).toList();
    await _db.deleteTask(taskId);
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<DevTask>>((
  ref,
) {
  final db = ref.watch(databaseRepositoryProvider);
  return TasksNotifier(db);
});

// ===================== GOALS PROVIDER =====================
class GoalsNotifier extends StateNotifier<List<Goal>> {
  final SupabaseDatabaseRepository _db;

  GoalsNotifier(this._db) : super([]) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    final list = await _db.getGoals();
    state = list;
  }

  Future<void> toggleGoalMilestone(String goalId, String milestoneId) async {
    GoalMilestone? toggled;
    state = state.map((goal) {
      if (goal.id == goalId) {
        final updatedMilestones = goal.milestones.map((m) {
          if (m.id == milestoneId) {
            toggled = m.copyWith(isCompleted: !m.isCompleted);
            return toggled!;
          }
          return m;
        }).toList();

        final completedCount = updatedMilestones
            .where((m) => m.isCompleted)
            .length;
        final newPercentage = updatedMilestones.isEmpty
            ? 0
            : ((completedCount / updatedMilestones.length) * 100).round();

        return goal.copyWith(
          progressPercentage: newPercentage,
          status: newPercentage == 100 ? 'achieved' : goal.status,
          milestones: updatedMilestones,
        );
      }
      return goal;
    }).toList();

    if (toggled != null) {
      await _db.toggleGoalMilestone(milestoneId, toggled!.isCompleted);
    }
  }

  Future<void> addGoal(Goal goal) async {
    final created = await _db.addGoal(goal);
    state = [created, ...state];
  }

  Future<void> updateGoal(Goal updated) async {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
    await _db.updateGoal(updated);
  }

  Future<void> deleteGoal(String goalId) async {
    state = state.where((g) => g.id != goalId).toList();
    await _db.deleteGoal(goalId);
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  final db = ref.watch(databaseRepositoryProvider);
  return GoalsNotifier(db);
});

// ===================== NOTES PROVIDER =====================
class NotesNotifier extends StateNotifier<List<Note>> {
  final SupabaseDatabaseRepository _db;

  NotesNotifier(this._db) : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    final list = await _db.getNotes();
    state = list;
  }

  Future<void> toggleFavorite(String noteId) async {
    Note? updatedNote;
    state = state.map((note) {
      if (note.id == noteId) {
        updatedNote = note.copyWith(isFavorite: !note.isFavorite);
        return updatedNote!;
      }
      return note;
    }).toList();

    if (updatedNote != null) {
      await _db.updateNote(updatedNote!);
    }
  }

  Future<void> addNote(Note note) async {
    final created = await _db.addNote(note);
    state = [created, ...state];
  }

  Future<void> updateNote(Note updated) async {
    state = state.map((n) => n.id == updated.id ? updated : n).toList();
    await _db.updateNote(updated);
  }

  Future<void> deleteNote(String noteId) async {
    state = state.where((n) => n.id != noteId).toList();
    await _db.deleteNote(noteId);
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  final db = ref.watch(databaseRepositoryProvider);
  return NotesNotifier(db);
});

// ===================== RESEARCH PAPERS PROVIDER =====================
class ResearchNotifier extends StateNotifier<List<ResearchPaper>> {
  final SupabaseDatabaseRepository _db;

  ResearchNotifier(this._db) : super([]) {
    loadResearchPapers();
  }

  Future<void> loadResearchPapers() async {
    final list = await _db.getResearchPapers();
    state = list;
  }

  Future<void> addPaper(ResearchPaper paper) async {
    final created = await _db.addResearchPaper(paper);
    state = [created, ...state];
  }

  Future<void> updatePaper(ResearchPaper updated) async {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    await _db.updateResearchPaper(updated);
  }

  Future<void> deletePaper(String paperId) async {
    state = state.where((p) => p.id != paperId).toList();
    await _db.deleteResearchPaper(paperId);
  }
}

final researchProvider =
    StateNotifierProvider<ResearchNotifier, List<ResearchPaper>>((ref) {
      final db = ref.watch(databaseRepositoryProvider);
      return ResearchNotifier(db);
    });

// ===================== EVENTS PROVIDER =====================
class EventsNotifier extends StateNotifier<List<CalendarEvent>> {
  final SupabaseDatabaseRepository _db;

  EventsNotifier(this._db) : super([]) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    final list = await _db.getEvents();
    state = list;
  }

  Future<void> addEvent(CalendarEvent event) async {
    final created = await _db.addEvent(event);
    state = [created, ...state];
  }

  Future<void> updateEvent(CalendarEvent updated) async {
    state = state.map((e) => e.id == updated.id ? updated : e).toList();
    await _db.updateEvent(updated);
  }

  Future<void> deleteEvent(String eventId) async {
    state = state.where((e) => e.id != eventId).toList();
    await _db.deleteEvent(eventId);
  }
}

final eventsProvider =
    StateNotifierProvider<EventsNotifier, List<CalendarEvent>>((ref) {
      final db = ref.watch(databaseRepositoryProvider);
      return EventsNotifier(db);
    });

// Global Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Global Workspace Initializer & Sync Provider
final syncWorkspaceProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseRepositoryProvider);
  await db.seedInitialWorkspaceDataIfEmpty();
  await ref.read(profileProvider.notifier).loadProfile();
  await ref.read(coursesProvider.notifier).loadCourses();
  await ref.read(skillsProvider.notifier).loadSkills();
  await ref.read(projectsProvider.notifier).loadProjects();
  await ref.read(tasksProvider.notifier).loadTasks();
  await ref.read(goalsProvider.notifier).loadGoals();
  await ref.read(notesProvider.notifier).loadNotes();
  await ref.read(researchProvider.notifier).loadResearchPapers();
  await ref.read(eventsProvider.notifier).loadEvents();
});
