import '../models/profile_model.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';
import '../models/note_model.dart';
import '../models/research_model.dart';
import '../models/event_model.dart';

class MockDataRepository {
  static UserProfile get sampleProfile => UserProfile(
        id: 'usr-1',
        email: 'alex.dev@university.edu',
        fullName: 'Alex Vance',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        institution: 'Institute of Science & Technology',
        major: 'Computer Science & Engineering',
        academicYear: '3rd Year (Semester 6)',
        learningStreak: 12,
      );

  static List<Course> get sampleCourses => [
        Course(
          id: 'c-1',
          name: 'Data Structure & Algorithm I',
          code: 'CSE 2201',
          instructor: 'Dr. Alan Turing',
          creditHours: 3.0,
          description: 'Fundamental data structures, recursion, dynamic programming, and algorithmic analysis.',
          colorHex: '#06B6D4',
          progressPercentage: 72,
          topics: [
            CourseTopic(id: 't-1', title: 'Array & Dynamic Arrays', isCompleted: true),
            CourseTopic(id: 't-2', title: 'Linked List & Doubly Linked List', isCompleted: true),
            CourseTopic(id: 't-3', title: 'Stack & Queue Data Structures', isCompleted: true),
            CourseTopic(id: 't-4', title: 'Trees & Binary Search Trees', isCompleted: true),
            CourseTopic(id: 't-5', title: 'Graphs & BFS/DFS Traversal', isCompleted: false),
            CourseTopic(id: 't-6', title: 'Dynamic Programming Basics', isCompleted: false),
          ],
        ),
        Course(
          id: 'c-2',
          name: 'Database Management Systems',
          code: 'CSE 3102',
          instructor: 'Prof. Grace Hopper',
          creditHours: 3.0,
          description: 'Relational algebra, SQL, normalization, transactions, and indexing.',
          colorHex: '#10B981',
          progressPercentage: 85,
          topics: [
            CourseTopic(id: 't-7', title: 'ER Diagram Modeling', isCompleted: true),
            CourseTopic(id: 't-8', title: 'Relational Algebra', isCompleted: true),
            CourseTopic(id: 't-9', title: 'Advanced SQL & Joins', isCompleted: true),
            CourseTopic(id: 't-10', title: 'Normal Forms (1NF - BCNF)', isCompleted: true),
            CourseTopic(id: 't-11', title: 'PostgreSQL Indexing & Optimization', isCompleted: false),
          ],
        ),
        Course(
          id: 'c-3',
          name: 'Software Engineering & Architecture',
          code: 'CSE 3201',
          instructor: 'Dr. Martin Fowler',
          creditHours: 4.0,
          description: 'Agile methodology, design patterns, microservices, and CI/CD pipelines.',
          colorHex: '#8B5CF6',
          progressPercentage: 60,
          topics: [
            CourseTopic(id: 't-12', title: 'Software Requirements Specification', isCompleted: true),
            CourseTopic(id: 't-13', title: 'UML Diagrams & System Architecture', isCompleted: true),
            CourseTopic(id: 't-14', title: 'SOLID Design Principles', isCompleted: true),
            CourseTopic(id: 't-15', title: 'Clean Code & Refactoring', isCompleted: false),
            CourseTopic(id: 't-16', title: 'DevOps & Pipeline Automation', isCompleted: false),
          ],
        ),
      ];

  static List<Skill> get sampleSkills => [
        Skill(
          id: 's-1',
          name: 'Flutter & Mobile Development',
          category: 'Mobile Engineering',
          proficiencyLevel: 'Intermediate',
          progressPercentage: 65,
          topics: [
            SkillTopic(id: 'st-1', title: 'Dart Core Syntax & OOP', isCompleted: true),
            SkillTopic(id: 'st-2', title: 'Flutter Layouts & Widgets', isCompleted: true),
            SkillTopic(id: 'st-3', title: 'Declarative Navigation 2.0', isCompleted: true),
            SkillTopic(id: 'st-4', title: 'State Management (Riverpod/Bloc)', isCompleted: false),
            SkillTopic(id: 'st-5', title: 'Supabase & Backend Integration', isCompleted: false),
          ],
        ),
        Skill(
          id: 's-2',
          name: 'Python & Data Science',
          category: 'Artificial Intelligence',
          proficiencyLevel: 'Advanced',
          progressPercentage: 82,
          topics: [
            SkillTopic(id: 'st-6', title: 'NumPy & Pandas Data Analysis', isCompleted: true),
            SkillTopic(id: 'st-7', title: 'Data Visualization with Matplotlib', isCompleted: true),
            SkillTopic(id: 'st-8', title: 'Scikit-Learn Machine Learning Models', isCompleted: true),
            SkillTopic(id: 'st-9', title: 'PyTorch Deep Learning Fundamentals', isCompleted: false),
          ],
        ),
        Skill(
          id: 's-3',
          name: 'Robotics Operating System (ROS)',
          category: 'Robotics & Hardware',
          proficiencyLevel: 'Beginner',
          progressPercentage: 40,
          topics: [
            SkillTopic(id: 'st-10', title: 'ROS 2 Core Architecture & Nodes', isCompleted: true),
            SkillTopic(id: 'st-11', title: 'Publishers & Subscribers Communication', isCompleted: true),
            SkillTopic(id: 'st-12', title: 'URDF Robot Modeling', isCompleted: false),
            SkillTopic(id: 'st-13', title: 'Gazebo Physics Simulation', isCompleted: false),
          ],
        ),
      ];

  static List<Project> get sampleProjects => [
        Project(
          id: 'p-1',
          title: 'Autonomous Humanoid Robot',
          description: 'Bipedal humanoid robot equipped with vision navigation, ROS 2, and RL locomotion control.',
          technologies: ['C++', 'Python', 'ROS 2', 'OpenCV', 'PyTorch'],
          githubUrl: 'https://github.com/alexdev/humanoid-robot',
          liveUrl: '',
          startDate: '2026-01-10',
          targetCompletionDate: '2026-11-30',
          status: 'in_progress',
          progressPercentage: 43,
          milestones: [
            ProjectMilestone(id: 'pm-1', title: 'Literature Research & Specs', targetDate: '2026-02-15', isCompleted: true),
            ProjectMilestone(id: 'pm-2', title: 'CAD Mechanical Design & 3D Print', targetDate: '2026-04-10', isCompleted: true),
            ProjectMilestone(id: 'pm-3', title: 'Servo Electronics & Bus Wiring', targetDate: '2026-06-01', isCompleted: false),
            ProjectMilestone(id: 'pm-4', title: 'ROS 2 Navigation & Vision Pipeline', targetDate: '2026-09-15', isCompleted: false),
          ],
        ),
        Project(
          id: 'p-2',
          title: 'DevOS - Engineering Dashboard App',
          description: 'Centralized mobile application for engineering student course, project, skill, and research tracking.',
          technologies: ['Flutter', 'Dart', 'Supabase', 'PostgreSQL', 'Cloudflare R2'],
          githubUrl: 'https://github.com/alexdev/devos-app',
          liveUrl: 'https://devos.app',
          startDate: '2026-08-01',
          targetCompletionDate: '2026-09-30',
          status: 'in_progress',
          progressPercentage: 70,
          milestones: [
            ProjectMilestone(id: 'pm-5', title: 'Architecture & UI System', targetDate: '2026-08-10', isCompleted: true),
            ProjectMilestone(id: 'pm-6', title: 'Supabase PostgreSQL Schema & RLS', targetDate: '2026-08-20', isCompleted: true),
            ProjectMilestone(id: 'pm-7', title: 'Module Integration & Cloudflare R2', targetDate: '2026-09-05', isCompleted: false),
          ],
        ),
      ];

  static List<DevTask> get sampleTasks => [
        DevTask(
          id: 'task-1',
          title: 'Implement Binary Tree Traversal in C++',
          description: 'Write iterative in-order, pre-order, and post-order traversal with stack implementation.',
          category: 'course',
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          relatedCourseName: 'Data Structure & Algorithm I',
        ),
        DevTask(
          id: 'task-2',
          title: 'Configure Supabase Auth & RLS Policies',
          description: 'Deploy PostgreSQL tables to Supabase project and test Row Level Security rules.',
          category: 'project',
          priority: TaskPriority.urgent,
          status: TaskStatus.inProgress,
          dueDate: DateTime.now().add(const Duration(days: 2)),
          relatedProjectName: 'DevOS - Engineering Dashboard App',
        ),
        DevTask(
          id: 'task-3',
          title: 'Revise ROS 2 Publisher-Subscriber Nodes',
          description: 'Review C++ node declarations and custom message types in ROS 2 Humble package.',
          category: 'skill',
          priority: TaskPriority.medium,
          status: TaskStatus.completed,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        DevTask(
          id: 'task-4',
          title: 'Summarize Humanoid Locomotion Research Paper',
          description: 'Read sections 3-5 of the Reinforcement Learning paper and draft key findings note.',
          category: 'research',
          priority: TaskPriority.low,
          status: TaskStatus.pending,
          dueDate: DateTime.now().add(const Duration(days: 4)),
        ),
      ];

  static List<Goal> get sampleGoals => [
        Goal(
          id: 'g-1',
          title: 'Become a Flutter Mobile Engineer',
          description: 'Master full-stack mobile development with Flutter, state management, and backend integrations.',
          category: 'Career Goal',
          targetDate: '2026-12-31',
          progressPercentage: 68,
          status: 'active',
          milestones: [
            GoalMilestone(id: 'gm-1', title: 'Master Dart OOP & Asynchronous programming', isCompleted: true),
            GoalMilestone(id: 'gm-2', title: 'Learn Flutter UI widgets & responsive design', isCompleted: true),
            GoalMilestone(id: 'gm-3', title: 'Implement clean navigation architecture', isCompleted: true),
            GoalMilestone(id: 'gm-4', title: 'Master Riverpod state management', isCompleted: true),
            GoalMilestone(id: 'gm-5', title: 'Integrate Supabase backend & Auth', isCompleted: false),
            GoalMilestone(id: 'gm-6', title: 'Build 3 full production mobile applications', isCompleted: false),
            GoalMilestone(id: 'gm-7', title: 'Publish application to Play Store / App Store', isCompleted: false),
          ],
        ),
        Goal(
          id: 'g-2',
          title: 'Publish Undergraduate Robotics Research Paper',
          description: 'Author and submit an IEEE paper on humanoid bipedal gait stabilization using reinforcement learning.',
          category: 'Academic Goal',
          targetDate: '2027-04-15',
          progressPercentage: 35,
          status: 'active',
          milestones: [
            GoalMilestone(id: 'gm-8', title: 'Conduct comprehensive literature review (30 papers)', isCompleted: true),
            GoalMilestone(id: 'gm-9', title: 'Develop Gazebo physics simulation environment', isCompleted: true),
            GoalMilestone(id: 'gm-10', title: 'Train PyTorch PPO locomotion agent', isCompleted: false),
            GoalMilestone(id: 'gm-11', title: 'Draft paper manuscript & benchmark results', isCompleted: false),
          ],
        ),
      ];

  static List<Note> get sampleNotes => [
        Note(
          id: 'n-1',
          title: 'C++ Pointers, References & Smart Pointers',
          content: '''# C++ Memory Management Guide

## Raw Pointers vs References
- Pointers can be null (`nullptr`), references must bind to valid objects.
- Use `std::unique_ptr` for single ownership semantics.
- Use `std::shared_ptr` when resource ownership is shared across threads.

```cpp
#include <memory>

class SensorNode {
public:
    void readData() { /* ... */ }
};

int main() {
    auto sensor = std::make_unique<SensorNode>();
    sensor->readData();
    return 0;
}
```''',
          category: 'Programming',
          isFavorite: true,
          tags: ['#C++', '#Memory', '#CPP'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Note(
          id: 'n-2',
          title: 'Binary Tree Traversal Patterns & Complexity',
          content: '''# Binary Tree Traversals

1. **In-Order (L-Root-R)**: Produces sorted sequence for BST.
2. **Pre-Order (Root-L-R)**: Useful for creating tree copies.
3. **Post-Order (L-R-Root)**: Useful for bottom-up deletion and expression evaluation.

**Time Complexity**: O(N) where N is number of nodes.  
**Space Complexity**: O(H) call stack height where H is tree height.''',
          category: 'DSA',
          isFavorite: true,
          tags: ['#DSA', '#Trees', '#Algorithms'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Note(
          id: 'n-3',
          title: 'Supabase Row Level Security (RLS) Rules',
          content: '''# PostgreSQL RLS with Supabase

Always check `auth.uid() = user_id` for personal user tables:

```sql
CREATE POLICY "Users access own notes" 
ON public.notes 
FOR ALL 
USING (auth.uid() = user_id);
```''',
          category: 'Backend',
          isFavorite: false,
          tags: ['#Supabase', '#PostgreSQL', '#Security'],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  static List<ResearchPaper> get sampleResearchPapers => [
        ResearchPaper(
          id: 'rp-1',
          title: 'Humanoid Bipedal Gait Generation using Deep Reinforcement Learning',
          authors: 'H. Jin, K. Takahashi, M. Zhang',
          publicationYear: 2025,
          topic: 'Robotics & AI',
          paperLink: 'https://arxiv.org/abs/2501.09876',
          personalNotes: 'PPO algorithm combined with domain randomization yields highly robust gait on uneven surfaces.',
          keyFindings: 'Domain randomization during PyTorch training reduces Sim-to-Real gap by 84%.',
          status: 'reading',
          attachmentUrl: 'research/rp-1/gait_generation_2025.pdf',
        ),
        ResearchPaper(
          id: 'rp-2',
          title: 'Declarative State Management Architectures for Cross-Platform Mobile Apps',
          authors: 'E. Gamma, R. Johnson, L. Chen',
          publicationYear: 2024,
          topic: 'Software Architecture',
          paperLink: 'https://acm.org/papers/2024-mobile-state',
          personalNotes: 'Compares Riverpod, Redux, and Unidirectional Data Flow performance in complex Flutter widget trees.',
          keyFindings: 'Fine-grained widget rebuild selectors reduce CPU rendering frame drops from 14% to under 1.2%.',
          status: 'completed',
          attachmentUrl: 'research/rp-2/state_management_flutter.pdf',
        ),
      ];

  static List<CalendarEvent> get sampleEvents => [
        CalendarEvent(
          id: 'ev-1',
          title: 'DSA II Midterm Examination',
          description: 'Covering Trees, Graphs, Hash Tables, and Dynamic Programming in Room 402.',
          eventType: 'exam',
          startTime: DateTime.now().add(const Duration(days: 3, hours: 2)),
          endTime: DateTime.now().add(const Duration(days: 3, hours: 4)),
        ),
        CalendarEvent(
          id: 'ev-2',
          title: 'Database Normalization Assignment Due',
          description: 'Submit PDF report with 1NF to BCNF decomposition examples.',
          eventType: 'assignment',
          startTime: DateTime.now().add(const Duration(days: 1, hours: 12)),
        ),
        CalendarEvent(
          id: 'ev-3',
          title: 'Humanoid Servo Motor Test Session',
          description: 'Calibrate bus servos and verify PWM signal responses in Robotics Lab.',
          eventType: 'learning_session',
          startTime: DateTime.now().add(const Duration(days: 5, hours: 4)),
          endTime: DateTime.now().add(const Duration(days: 5, hours: 7)),
        ),
      ];
}
