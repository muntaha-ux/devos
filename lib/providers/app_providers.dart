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
import '../repositories/mock_data.dart';

// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// User Profile Provider
class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(MockDataRepository.sampleProfile);

  void incrementStreak() {
    state = UserProfile(
      id: state.id,
      email: state.email,
      fullName: state.fullName,
      avatarUrl: state.avatarUrl,
      institution: state.institution,
      major: state.major,
      academicYear: state.academicYear,
      learningStreak: state.learningStreak + 1,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});

// Courses Provider
class CoursesNotifier extends StateNotifier<List<Course>> {
  CoursesNotifier() : super(MockDataRepository.sampleCourses);

  void toggleTopic(String courseId, String topicId) {
    state = state.map((course) {
      if (course.id == courseId) {
        final updatedTopics = course.topics.map((t) {
          if (t.id == topicId) {
            return t.copyWith(isCompleted: !t.isCompleted);
          }
          return t;
        }).toList();

        final completedCount = updatedTopics.where((t) => t.isCompleted).length;
        final newPercentage = updatedTopics.isEmpty
            ? 0
            : ((completedCount / updatedTopics.length) * 100).round();

        return Course(
          id: course.id,
          name: course.name,
          code: course.code,
          instructor: course.instructor,
          creditHours: course.creditHours,
          description: course.description,
          colorHex: course.colorHex,
          progressPercentage: newPercentage,
          topics: updatedTopics,
        );
      }
      return course;
    }).toList();
  }

  void addCourse(Course course) {
    state = [...state, course];
  }

  void updateCourse(Course updated) {
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
  }

  void deleteCourse(String courseId) {
    state = state.where((c) => c.id != courseId).toList();
  }
}

final coursesProvider = StateNotifierProvider<CoursesNotifier, List<Course>>((ref) {
  return CoursesNotifier();
});

// Skills Provider
class SkillsNotifier extends StateNotifier<List<Skill>> {
  SkillsNotifier() : super(MockDataRepository.sampleSkills);

  void toggleSkillTopic(String skillId, String topicId) {
    state = state.map((skill) {
      if (skill.id == skillId) {
        final updatedTopics = skill.topics.map((t) {
          if (t.id == topicId) {
            return t.copyWith(isCompleted: !t.isCompleted);
          }
          return t;
        }).toList();

        final completedCount = updatedTopics.where((t) => t.isCompleted).length;
        final newPercentage = updatedTopics.isEmpty
            ? 0
            : ((completedCount / updatedTopics.length) * 100).round();

        return Skill(
          id: skill.id,
          name: skill.name,
          category: skill.category,
          proficiencyLevel: skill.proficiencyLevel,
          progressPercentage: newPercentage,
          topics: updatedTopics,
        );
      }
      return skill;
    }).toList();
  }

  void addSkill(Skill skill) {
    state = [...state, skill];
  }

  void updateSkill(Skill updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
  }

  void deleteSkill(String skillId) {
    state = state.where((s) => s.id != skillId).toList();
  }
}

final skillsProvider = StateNotifierProvider<SkillsNotifier, List<Skill>>((ref) {
  return SkillsNotifier();
});

// Projects Provider
class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super(MockDataRepository.sampleProjects);

  void toggleMilestone(String projectId, String milestoneId) {
    state = state.map((project) {
      if (project.id == projectId) {
        final updatedMilestones = project.milestones.map((m) {
          if (m.id == milestoneId) {
            return m.copyWith(isCompleted: !m.isCompleted);
          }
          return m;
        }).toList();

        final completedCount = updatedMilestones.where((m) => m.isCompleted).length;
        final newPercentage = updatedMilestones.isEmpty
            ? 0
            : ((completedCount / updatedMilestones.length) * 100).round();

        return Project(
          id: project.id,
          title: project.title,
          description: project.description,
          technologies: project.technologies,
          githubUrl: project.githubUrl,
          liveUrl: project.liveUrl,
          startDate: project.startDate,
          targetCompletionDate: project.targetCompletionDate,
          status: newPercentage == 100 ? 'completed' : project.status,
          progressPercentage: newPercentage,
          milestones: updatedMilestones,
        );
      }
      return project;
    }).toList();
  }

  void addProject(Project project) {
    state = [...state, project];
  }

  void updateProject(Project updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void deleteProject(String projectId) {
    state = state.where((p) => p.id != projectId).toList();
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier();
});

// Tasks Provider
class TasksNotifier extends StateNotifier<List<DevTask>> {
  TasksNotifier() : super(MockDataRepository.sampleTasks);

  void toggleTaskStatus(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        final nextStatus = task.status == TaskStatus.completed
            ? TaskStatus.pending
            : TaskStatus.completed;
        return task.copyWith(status: nextStatus);
      }
      return task;
    }).toList();
  }

  void addTask(DevTask task) {
    state = [task, ...state];
  }

  void updateTask(DevTask updated) {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
  }

  void deleteTask(String taskId) {
    state = state.where((t) => t.id != taskId).toList();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<DevTask>>((ref) {
  return TasksNotifier();
});

// Goals Provider
class GoalsNotifier extends StateNotifier<List<Goal>> {
  GoalsNotifier() : super(MockDataRepository.sampleGoals);

  void toggleGoalMilestone(String goalId, String milestoneId) {
    state = state.map((goal) {
      if (goal.id == goalId) {
        final updatedMilestones = goal.milestones.map((m) {
          if (m.id == milestoneId) {
            return m.copyWith(isCompleted: !m.isCompleted);
          }
          return m;
        }).toList();

        final completedCount = updatedMilestones.where((m) => m.isCompleted).length;
        final newPercentage = updatedMilestones.isEmpty
            ? 0
            : ((completedCount / updatedMilestones.length) * 100).round();

        return Goal(
          id: goal.id,
          title: goal.title,
          description: goal.description,
          category: goal.category,
          targetDate: goal.targetDate,
          progressPercentage: newPercentage,
          status: newPercentage == 100 ? 'achieved' : goal.status,
          milestones: updatedMilestones,
        );
      }
      return goal;
    }).toList();
  }

  void addGoal(Goal goal) {
    state = [...state, goal];
  }

  void updateGoal(Goal updated) {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
  }

  void deleteGoal(String goalId) {
    state = state.where((g) => g.id != goalId).toList();
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier();
});

// Notes Provider
class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super(MockDataRepository.sampleNotes);

  void toggleFavorite(String noteId) {
    state = state.map((note) {
      if (note.id == noteId) {
        return note.copyWith(isFavorite: !note.isFavorite);
      }
      return note;
    }).toList();
  }

  void addNote(Note note) {
    state = [note, ...state];
  }

  void updateNote(Note updated) {
    state = state.map((n) => n.id == updated.id ? updated : n).toList();
  }

  void deleteNote(String noteId) {
    state = state.where((n) => n.id != noteId).toList();
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier();
});

// Research Papers Provider
class ResearchNotifier extends StateNotifier<List<ResearchPaper>> {
  ResearchNotifier() : super(MockDataRepository.sampleResearchPapers);

  void addPaper(ResearchPaper paper) {
    state = [paper, ...state];
  }

  void updatePaper(ResearchPaper updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void deletePaper(String paperId) {
    state = state.where((p) => p.id != paperId).toList();
  }
}

final researchProvider = StateNotifierProvider<ResearchNotifier, List<ResearchPaper>>((ref) {
  return ResearchNotifier();
});

// Events Provider
class EventsNotifier extends StateNotifier<List<CalendarEvent>> {
  EventsNotifier() : super(MockDataRepository.sampleEvents);

  void addEvent(CalendarEvent event) {
    state = [...state, event];
  }

  void updateEvent(CalendarEvent updated) {
    state = state.map((e) => e.id == updated.id ? updated : e).toList();
  }

  void deleteEvent(String eventId) {
    state = state.where((e) => e.id != eventId).toList();
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, List<CalendarEvent>>((ref) {
  return EventsNotifier();
});

// Global Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');
