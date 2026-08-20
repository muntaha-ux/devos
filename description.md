DEVOS
Personal Engineering & Academic Dashboard
Software Development 2 Project Documentation
Project Type: Cross-Platform Mobile Application
Framework: Flutter
Programming Language: Dart
Backend: Supabase
Primary Database: PostgreSQL
Object Storage: Cloudflare R2
Authentication: Supabase Authentication
Target Platform: Android / iOS
Target Users: University students, CSE students, developers and technical learners
________________________________________
1. Introduction
DevOS is a cross-platform mobile application designed to act as a personal engineering and academic dashboard for students and technical learners.
University students often use multiple disconnected applications to manage their courses, assignments, learning progress, projects, research papers, notes, deadlines and personal goals. Because these activities are separated across different applications, it becomes difficult to maintain an organized overview of academic and technical development.
DevOS solves this problem by bringing these activities together into one centralized platform.
The main concept of DevOS is:
Learn → Practice → Build → Research → Track Progress
The application allows users to manage their academic responsibilities, technical skills, software projects, goals, notes and research activities from a single application.
________________________________________
2. Problem Statement
Students and developers commonly face the following problems:
•	Academic information is scattered across different applications.
•	Assignment and project deadlines are easily forgotten.
•	Learning progress is difficult to measure.
•	Technical skills are learned without a structured progression.
•	Project tasks and milestones are not properly organized.
•	Research papers and technical resources are difficult to manage.
•	Personal notes are stored in multiple locations.
•	There is no single dashboard showing overall academic and technical progress.
Therefore, a centralized system is required to organize these activities and provide users with a clear view of their development.
________________________________________
3. Proposed Solution
DevOS provides a centralized digital workspace where users can manage:
•	University courses
•	Assignments
•	Exams
•	Technical skills
•	Learning topics
•	Software projects
•	Project tasks
•	Goals
•	Notes
•	Research papers
•	Deadlines
•	Learning sessions
•	Progress statistics
The application uses Supabase as the main backend platform and Cloudflare R2 as object storage.
Supabase will manage structured application data, authentication and database operations, while Cloudflare R2 will store larger files such as PDFs, images and project attachments.
________________________________________
4. Project Objectives
The main objectives of DevOS are:
1.	To create a centralized platform for academic and technical management.
2.	To help students organize their university courses and academic activities.
3.	To track technical skills and learning progress.
4.	To manage software development projects and milestones.
5.	To organize tasks and deadlines.
6.	To provide a structured personal knowledge base.
7.	To organize research papers and research-related information.
8.	To provide progress analytics and statistics.
9.	To provide reminders for important deadlines and activities.
10.	To develop a modern cross-platform application using Flutter.
11.	To demonstrate practical implementation of PostgreSQL, authentication, APIs, cloud storage and software engineering principles.
________________________________________
5. Target Users
DevOS is primarily designed for:
•	University students
•	CSE/CS students
•	Engineering students
•	Software developers
•	Self-learners
•	Students working on academic projects
•	Students involved in technical research
________________________________________
6. Core Features
6.1 User Authentication
Users can securely create and manage their accounts.
Features:
•	User registration
•	Login
•	Logout
•	Password recovery
•	User profile
•	Authentication state management
Authentication will be handled using Supabase Auth.
________________________________________
7. Personalized Dashboard
The dashboard is the main screen of DevOS.
It provides a quick overview of the user's activities.
The dashboard can display:
•	Today's tasks
•	Upcoming deadlines
•	Active projects
•	Learning progress
•	Current goals
•	Recent notes
•	Research activities
•	Learning streak
•	Overall progress
Example:
Today's Overview
•	3 tasks completed
•	2 tasks remaining
•	1 assignment due soon
•	2 active projects
•	68% weekly learning progress
The dashboard allows users to understand their current workload without opening every module separately.
________________________________________
8. Course Management
Users can create and manage university courses.
Each course may contain:
•	Course name
•	Course code
•	Teacher/instructor
•	Credit hours
•	Course description
•	Topics
•	Assignments
•	Exams
•	Notes
•	Progress
Example:
Data Structure & Algorithm I
Course Code: CSE 2201
Progress: 72%
Topics:
•	Array
•	Linked List
•	Stack
•	Queue
•	Tree
•	Graph
•	Dynamic Programming
________________________________________
9. Skill Tracking
Skill Tracking is one of the major features of DevOS.
Users can create technical skills and divide them into smaller topics.
Example:
Flutter — 65%
•	Dart — 90%
•	Flutter Widgets — 75%
•	Navigation — 60%
•	State Management — 45%
•	Firebase/Supabase — 40%
The system can calculate overall progress based on completed topics.
Users can track skills such as:
•	C++
•	Python
•	Java
•	Flutter
•	React
•	Data Structures
•	Algorithms
•	Machine Learning
•	Robotics
•	SQL
________________________________________
10. Goal Management
Users can create long-term technical or academic goals.
Example:
Goal: Become a Flutter Developer
Milestones:
1.	Learn Dart
2.	Learn Flutter basics
3.	Learn navigation
4.	Learn state management
5.	Learn backend integration
6.	Build three applications
7.	Deploy an application
The application calculates goal completion percentage.
________________________________________
11. Project Management
DevOS provides a dedicated module for software projects.
Users can create projects and manage:
•	Project name
•	Description
•	Technologies
•	Start date
•	Deadline
•	Status
•	Progress
•	Milestones
•	Tasks
•	Notes
•	Resources
Example:
Project: Autonomous Humanoid Robot
Technologies:
•	C++
•	Python
•	ROS
•	OpenCV
•	AI
Progress:
43%
Project stages:
•	Research
•	Planning
•	Mechanical Development
•	Electronics
•	Software
•	AI
•	Testing
________________________________________
12. Task Management
Users can create tasks associated with courses, projects, skills or personal goals.
Each task contains:
•	Task title
•	Description
•	Category
•	Priority
•	Deadline
•	Status
•	Related project/course
•	Creation date
Task statuses:
•	Pending
•	In Progress
•	Completed
Priority levels:
•	Low
•	Medium
•	High
•	Urgent
________________________________________
13. Notes and Knowledge Base
DevOS includes a structured note-taking system.
Users can organize notes into categories.
Example:
Programming
•	C++
•	Python
•	Flutter
DSA
•	Trees
•	Graphs
•	Dynamic Programming
Robotics
•	ROS
•	Computer Vision
•	Electronics
Users can:
•	Create notes
•	Edit notes
•	Delete notes
•	Search notes
•	Add tags
•	Favorite important notes
________________________________________
14. Research Management
DevOS provides a research management module for technical learners.
Users can store:
•	Research paper title
•	Authors
•	Publication year
•	Research topic
•	Paper link
•	Personal notes
•	Important findings
•	Research questions
•	Status
Research statuses may include:
•	Saved
•	Reading
•	Completed
•	Important
Users can attach the actual research paper PDF using Cloudflare R2.
________________________________________
15. Calendar and Deadline Management
The calendar displays important events such as:
•	Assignment deadlines
•	Exams
•	Project deadlines
•	Research deadlines
•	Personal tasks
•	Learning sessions
Users can select a date to see all activities scheduled for that day.
________________________________________
16. Notification and Reminder System
DevOS can remind users about important activities.
Examples:
Assignment Reminder
"Your DSA assignment is due tomorrow."
Project Reminder
"Your Flutter project milestone is due in 3 days."
Learning Reminder
"You planned to revise Binary Trees today."
Notifications can be implemented using Flutter-compatible notification services.
________________________________________
17. Analytics and Progress Tracking
DevOS provides visual statistics to help users understand their progress.
Analytics can include:
Learning Analytics
•	Weekly learning hours
•	Completed topics
•	Learning streak
•	Skill progress
Project Analytics
•	Active projects
•	Completed projects
•	Project completion percentage
•	Completed milestones
Academic Analytics
•	Course progress
•	Completed assignments
•	Upcoming exams
Charts and progress indicators can make this information easier to understand.
________________________________________
18. Global Search
DevOS will provide a global search feature.
For example, searching:
"Binary Tree"
may return:
•	DSA course topic
•	Binary Tree note
•	Tree-related skill
•	Related project
•	Research paper
This allows users to quickly find information without manually navigating through multiple modules.
________________________________________
19. Tags and Categories
Users can organize information with tags.
Examples:
•	#DSA
•	#Flutter
•	#C++
•	#Exam
•	#Important
•	#Research
•	#Project
•	#Revision
Tags will make filtering and searching more efficient.
________________________________________
20. Dark and Light Mode
DevOS will support:
•	Dark Mode
•	Light Mode
The default design can use a modern dark engineering aesthetic with:
•	Minimal cards
•	Clean typography
•	Subtle gradients
•	Progress indicators
•	Consistent icons
•	Modern navigation
________________________________________
21. Learning Streak
DevOS can track consistent learning activity.
Example:
🔥 12 Day Learning Streak
A streak can increase when the user completes a planned learning activity.
This feature encourages consistent learning habits.
________________________________________
22. Hybrid Backend Architecture
DevOS will use a hybrid backend architecture consisting of:
Supabase
Supabase will be responsible for:
•	Authentication
•	PostgreSQL database
•	Row Level Security
•	API access
•	Database queries
•	Realtime features
•	Server-side/Edge Functions where required
Cloudflare R2
Cloudflare R2 will be responsible for:
•	PDF files
•	Research papers
•	Project images
•	Screenshots
•	Certificates
•	Other large attachments
The basic architecture is:
Flutter → Supabase → PostgreSQL
and
Flutter → Secure backend function → Cloudflare R2
This separation keeps structured data and large files in appropriate storage systems.
________________________________________
23. Why Use Supabase?
Supabase is suitable for DevOS because it provides a PostgreSQL relational database and several backend services in one platform.
Advantages for this project include:
•	PostgreSQL database
•	Authentication
•	Row Level Security
•	REST APIs
•	Realtime capabilities
•	Edge Functions
•	Easy integration with Flutter
•	Relational data modeling
The relational structure is particularly useful because DevOS contains connected entities such as:
Users → Courses → Assignments
Users → Skills → Topics
Users → Projects → Tasks
Users → Goals → Milestones
________________________________________
24. Why Use Cloudflare R2?
Cloudflare R2 will be used as the application's object storage layer.
It is suitable for files that should not be stored directly inside PostgreSQL.
Examples:
•	PDF research papers
•	Course materials
•	Project images
•	Screenshots
•	Certificates
•	Uploaded attachments
The PostgreSQL database stores the file metadata and reference information, while R2 stores the actual file.
Example:
PostgreSQL
Research Paper ID: 105
Title: Humanoid Robot Locomotion
File Key: research/105/paper.pdf
Cloudflare R2
research/105/paper.pdf
This creates a clean separation between structured data and file storage.
________________________________________
25. Database Design
The main PostgreSQL tables can include:
profiles
courses
course_topics
assignments
exams
skills
skill_topics
projects
project_milestones
tasks
goals
goal_milestones
notes
research
tags
entity_tags
events
learning_sessions
notifications
attachments
________________________________________
26. Entity Relationships
The basic relationship structure is:
USER
 │
 ├── Courses
 │     ├── Topics
 │     ├── Assignments
 │     └── Exams
 │
 ├── Skills
 │     └── Skill Topics
 │
 ├── Projects
 │     ├── Milestones
 │     └── Tasks
 │
 ├── Goals
 │     └── Milestones
 │
 ├── Notes
 │
 ├── Research
 │     └── Attachments
 │
 └── Events
This relational design allows DevOS to maintain connections between different types of user data.
________________________________________
27. Attachment Architecture
Files will not be stored directly inside PostgreSQL.
Instead:
Flutter Application
       │
       ▼
Supabase Authentication
       │
       ▼
Secure Function / API
       │
       ▼
Cloudflare R2
       │
       └── PDF
       └── Image
       └── Document
       └── Attachment
The PostgreSQL database will store metadata such as:
•	File name
•	File type
•	File size
•	R2 object key
•	Related user
•	Related project/research/note
•	Upload timestamp
________________________________________
28. Security
Security is an important part of DevOS.
The system will use:
Supabase Authentication
Users must authenticate before accessing private data.
Row Level Security
PostgreSQL Row Level Security policies will ensure that users can access only records belonging to their account.
Secure File Access
Cloudflare R2 credentials should not be embedded directly inside the Flutter application.
File operations should be handled through a secure server-side mechanism.
Input Validation
The application will validate:
•	Required fields
•	Dates
•	Text length
•	File types
•	File sizes
________________________________________
29. Functional Requirements
FR-01
The system shall allow users to register and authenticate.
FR-02
The system shall provide a personalized dashboard.
FR-03
The system shall allow users to create, update and delete courses.
FR-04
The system shall allow users to create and track technical skills.
FR-05
The system shall allow users to create and manage projects.
FR-06
The system shall allow users to create and manage tasks.
FR-07
The system shall allow users to create goals and milestones.
FR-08
The system shall allow users to create and manage notes.
FR-09
The system shall allow users to store research information.
FR-10
The system shall allow users to upload and manage attachments.
FR-11
The system shall provide calendar and deadline management.
FR-12
The system shall provide reminders.
FR-13
The system shall calculate basic progress statistics.
FR-14
The system shall provide search and filtering.
FR-15
The system shall securely store user data.
________________________________________
30. Non-Functional Requirements
Usability
The application should be easy to understand and navigate.
Performance
Normal application operations should respond quickly under expected project usage.
Security
Users should only have access to their own private information.
Reliability
The application should handle errors and invalid input gracefully.
Maintainability
The Flutter codebase should use modular and reusable components.
Scalability
The architecture should support additional features in future versions.
Compatibility
The application should support modern Android devices and be structured so that iOS support can be added.
________________________________________
31. Technology Stack
Layer	Technology
Mobile Frontend	Flutter
Programming Language	Dart
Backend Platform	Supabase
Database	PostgreSQL
Authentication	Supabase Auth
Database Security	PostgreSQL Row Level Security
Server-side Logic	Supabase Edge Functions
Object Storage	Cloudflare R2
API Communication	Supabase APIs / secure functions
Version Control	Git + GitHub
IDE	VS Code / Android Studio
________________________________________
32. Recommended Flutter Architecture
The application should be organized into separate layers/modules.
lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── services/
│
├── models/
│
├── repositories/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── courses/
│   ├── skills/
│   ├── projects/
│   ├── tasks/
│   ├── goals/
│   ├── notes/
│   ├── research/
│   ├── calendar/
│   └── analytics/
│
├── widgets/
│
└── main.dart
This structure will make the application easier to maintain and expand.
________________________________________
33. Minimum Viable Product (MVP)
For the Software Development 2 submission, the recommended MVP is:
1.	User authentication
2.	Dashboard
3.	Course management
4.	Skill management
5.	Project management
6.	Task management
7.	Goal management
8.	Notes
9.	Calendar/deadlines
10.	Basic analytics
11.	Supabase PostgreSQL integration
12.	Cloudflare R2 file upload
13.	Dark/light theme
14.	Search and filtering
The MVP should be completed and tested before attempting advanced features.
________________________________________
34. Future Enhancements
Future versions of DevOS may include:
•	AI-powered study assistant
•	AI-generated study plans
•	AI project recommendations
•	GitHub integration
•	Automatic project activity tracking
•	Advanced spaced-repetition revision
•	Research paper recommendations
•	PDF content search
•	Portfolio generation
•	Team project collaboration
•	Web application
•	Desktop application
•	Advanced analytics
•	Cross-device synchronization
________________________________________
35. Testing Plan
Unit Testing
Test:
•	Progress calculations
•	Data models
•	Utility functions
•	Validation logic
Widget Testing
Test:
•	Login form
•	Task forms
•	Course forms
•	Skill progress widgets
•	Dashboard components
Integration Testing
Test complete workflows such as:
Register → Login → Create Course → Add Assignment → View Dashboard
and:
Create Project → Add Task → Complete Task → Update Progress
Security Testing
Test:
•	Unauthorized access
•	Row Level Security
•	Invalid authentication
•	File access restrictions
Usability Testing
Ask several students to use the application and identify:
•	Navigation problems
•	Confusing screens
•	Missing information
•	UI issues
________________________________________
36. Development Phases
Phase 1 — Requirement Analysis
•	Finalize requirements
•	Identify users
•	Define modules
•	Prepare use cases
Phase 2 — UI/UX Design
•	Create wireframes
•	Design color system
•	Design navigation
•	Design dashboard
Phase 3 — Database Design
•	Design ER diagram
•	Create PostgreSQL tables
•	Define relationships
•	Configure Row Level Security
Phase 4 — Flutter Development
•	Project setup
•	Navigation
•	Reusable widgets
•	Theme system
Phase 5 — Authentication
•	Registration
•	Login
•	Logout
•	Profile
Phase 6 — Core Modules
Develop:
•	Courses
•	Skills
•	Projects
•	Tasks
•	Goals
•	Notes
Phase 7 — Cloud Storage
•	Configure Cloudflare R2
•	Implement secure upload
•	Store file metadata
•	Implement file retrieval
Phase 8 — Analytics & Notifications
•	Progress calculations
•	Charts
•	Reminders
•	Calendar
Phase 9 — Testing
•	Unit testing
•	Widget testing
•	Integration testing
•	Security testing
Phase 10 — Finalization
•	Bug fixing
•	UI polishing
•	Documentation
•	Presentation
•	Final deployment/build
________________________________________
37. Expected Outcome
The final outcome will be a functional cross-platform mobile application that provides students and technical learners with a centralized system for managing their academic and technical journey.
The application will demonstrate practical knowledge of:
•	Flutter
•	Dart
•	UI/UX design
•	PostgreSQL
•	Supabase
•	Authentication
•	CRUD operations
•	Row Level Security
•	API communication
•	Cloud object storage
•	File management
•	Notifications
•	Data visualization
•	Software architecture
•	Testing
________________________________________
38. Project Advantages
DevOS has several advantages compared with a basic student management application.
1.	It solves a real personal productivity problem.
2.	It combines academic and technical development.
3.	It uses a relational database for meaningful relationships.
4.	It uses dedicated object storage for files.
5.	It has a clear modular architecture.
6.	It can be developed incrementally.
7.	It can continue to evolve after the academic project.
8.	It can become a portfolio project.
9.	It provides strong material for software engineering documentation and viva.
10.	It can eventually integrate AI and external services.
________________________________________
39. Project Limitations
The first version may have some limitations:
•	Advanced AI features may not be included.
•	GitHub integration may be postponed.
•	Offline synchronization may be limited.
•	Advanced analytics may be reserved for future versions.
•	Collaboration features may not be included in the MVP.
•	iOS deployment may depend on the available development environment.
These limitations help keep the project manageable within the Software Development 2 semester.
________________________________________
40. Future Vision
The long-term vision of DevOS is to become a complete personal engineering workspace.
A future user should be able to open DevOS and immediately understand:
What am I learning?
What do I need to do?
What projects am I building?
What skills am I missing?
What should I revise?
What research am I following?
How much have I progressed?
The ultimate workflow is:
Learn → Practice → Build → Research → Measure → Improve
________________________________________
41. Project Summary
DevOS is a personal engineering and academic dashboard developed using Flutter, Supabase and Cloudflare R2.
It provides a centralized platform for managing courses, skills, projects, tasks, goals, notes, research, deadlines and progress.
Supabase provides authentication, PostgreSQL database functionality, security and backend services, while Cloudflare R2 provides scalable object storage for files and attachments.
The project combines practical software development concepts with a real-world problem, making it suitable for a Software Development 2 academic project and providing a strong foundation for future development.
________________________________________
42. Short Presentation Pitch
“DevOS is a personal engineering and academic operating system designed for students and developers. Instead of using separate applications for courses, learning, projects, tasks, notes and research, DevOS connects all of these activities in one platform. The application is developed using Flutter, with Supabase and PostgreSQL handling authentication and structured data, while Cloudflare R2 is used for file storage. Its main purpose is to help users understand not only what they need to do, but also what they are learning, what they are building and how they are progressing.”
________________________________________
43. One-Line Project Definition
DevOS is a centralized Flutter-based platform that helps students and technical learners manage their academic activities, technical skills, software projects, research and personal development in one connected system.

