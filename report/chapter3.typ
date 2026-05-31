= *System Design*
This chapter presents the technical architecture and design decisions underlying the medication tracking application. The system design is organized into three essential components: the database schema that structures and manages application data, the user interface design tailored for elderly users' accessibility needs, and the development tools and workflow that ensure efficient and maintainable code.


== Database Schema

The database schema defines the structural foundation for storing and managing all application data, including user profiles, medication schedules, reminder histories, and caregiver relationships. A well-designed schema ensures data integrity, efficient querying, and scalability as users add medications and accumulate historical records over time. The following entity-relationship model outlines the core tables and their relationships, emphasizing simplicity and normalization to support the application's privacy-first approach while enabling the customization and reporting features essential for effective medication management.

#set page(
  flipped: true,
)


#figure(
  image("figures/er.svg", width: 75%),
  caption: [The Database Schema],
)

#set page(
  flipped: false,
)

The User table will have the following columns:
#context {
  set text(size: 11pt)

  figure(
  table(columns:4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

  [ID],[Integer],[Primary Key (PK)],[],
  [First_Name],[String],[],[],
  [Last_Name],[String],[],[],
  [Username],[String],[],[],
  [Email],[String],[],[],
  [Password],[String],[],[],
  [Gender],[String],[],[],
  [Role],[Enum],[],[],
  [Created_At],[Timestamp],[],[],
  ),
  caption: [The User table],
)}


*ID*: The Primary Key (PK).

*First_Name:* the user's first name.

*Last_name:* the user's last name.

*Username:* The unique identifier used by the user for logging into the system.

*Email:* The user's email address.

*Password:* The user's password, which should be stored in a hashed/encrypted format for security. It must not be null.

*Gender:* Represents the user's gender (e.g., Male, Female, Other). It must not be null.

*Role:* An Enum data type. It defines the specific role or permissions of the user within the system.

*Created_At:* A Timestamp data type.







//////////////////////////////////////////////////

The   Patients table will have the following columns:
#context {
  set text(size: 11pt)
   figure(
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],


  [ID],[Integer],[Primary Key (PK)],[],
  [User_ID],[Integer],[],[Users.ID],
  [Date_of_Birth],[Date],[],[],
  [Medical_Notes],[String],[],[],
),  caption: [The  Patients table],
)}
*ID:* The Primary Key (PK).

*User_ID:* This is a Foreign Key (FK) which references the ID field in the Users table.

*Date_of_Birth:* This field records the user's date of birth.

*Medical_Notes:* This field is used to store any medical notes or additional textual information related to this record.

/////////////////////////////////////////

The   Caregivers table will have the following columns:
#context {
  set text(size: 11pt)
   figure(
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

  [ID],[Integer],[Primary Key (PK)],[],
  [User_ID],[Integer],[],[Users.ID],
  [Patient_ID],[Integer],[],[Patients.ID],
),caption: [The  Caregivers  table],
  
)}
*ID:* The Primary Key (PK) for this table.

*User_ID:* This field is a Foreign Key (FK) that references the ID column in the Users table (Users.ID).

*Patient_ID:* This field is also a Foreign Key (FK), referencing the ID column in the Patients table (Patients.ID).
//////////////////////////////////////////////

The   Admins table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

  [ID],[Integer],[Primary Key (PK)],[],
  [User_ID],[String],[],[Users.ID],
),caption: [The  Admins  table],
  
)}
*ID:* The Primary Key (PK) for this table.

*User_ID:* This field serves as a Foreign Key (FK), referencing the ID field in the Users table (Users.ID).
////////////////////////////////////////

The   Preferences table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

  [ID],[Integer],[Primary Key (PK)],[],
  [User_ID],[String],[],[Users.ID],
   [Language],[String],[],[],
  [Font_Size],[String],[],[],
  [Contrast_Mode],[String],[],[],
  [Theme],[String],[],[],
  ),caption: [The  Preferences  table],
)}
*ID:* The Primary Key (PK) for this table.

*User_ID:* This field is a Foreign Key (FK) that references the ID column in the Users table.

*Language:* Used to store the user's preferred language for the application interface.

*Font_Size:* Used to store the user's preferred font size setting. 

*Contrast_Mode:* Used to store the user's preference for display contrast.

*Theme:* Used to store the user's preferred interface theme.
////////////////////////////////////

The   Drug_Database table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

 [ID],[Integer],[Primary Key (PK)],[],
  [Name],[String],[],[],
  [Description],[String],[],[],
  [Interactions],[String],[],[],
  [Manufacturer],[String],[],[],
   [Image_Url],[String],[],[],
   ),caption: [The  Drug_Database  table],
)}
*ID:* The Primary Key (PK) for this table.

*Name:* This field stores the official name of drug.

*Description:* This field holds a detailed description of the drug, its purpose, or its uses.

*Interactions:* used to store information about how this item interacts with other items, chemicals, or conditions.

*Manufacturer:* This field records the name of the company that manufactured the drug.

*Image_Url:* This field stores the web address (URL) where an image of the drug is located, typically used for display in an application.
////////////////////////////////////

The   Medications table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

  [ID],[Integer],[Primary Key (PK)],[],
  [Drug_Info_ID],[Integer],[],[Drug_Database.ID],
  [Name],[String],[],[],
  [Type],[Enum],[],[],
  [Photo_Url],[String],[],[],
     ),caption: [The   Medications table],
)}
*ID:* The Primary Key (PK) for this table.

*Drug_Info_ID:* This field is a Foreign Key (FK) that references the ID field in the Drug_Database table.

*Name:* Used to store the name of the drug. 

*Type:* Used to store the type of the drug.
///////////////////////////////////

The   Schedules table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

 [ID],[Integer],[Primary Key (PK)],[],
 [Patient_ID],[Integer],[],[Patients.ID],
  [Medication_ID],[Integer],[],[Medications.ID],
  [Start_Date],[Timestamp],[],[],
  [End_Date],[Timestamp],[],[],
   [Start_Hour],[Timestamp],[],[],
    [Interval_Hours],[Integer],[],[],
     [Instructions],[String],[],[],
      [Dosage],[String],[],[],
       [Quantity],[Integer],[],[],
            ),caption: [The   Schedules table],
)}
*ID:* The Primary Key (PK) for the table.

*Patient_ID:* A Foreign Key (FK) referencing the ID field in the Patients table.

*Medication_ID:* A Foreign Key (FK) referencing the ID field in the Medications table.

*Start_Date:* This field records the date when the medication schedule should begin.

*End_Date:* This field records the date when the medication schedule should end.

*Start_Hour:* This is used to define the time of day (hour) the medication should be taken for the first dose. 

*Interval_Hours:* It specifies the number of hours between consecutive doses .

*Instructions:* Used to store additional guidelines for taking the medication.

*Dosage:* This defines the amount of medication to be taken (e.g., "50mg," "One pill"). It's specified as a String because it often includes units.

*Quantity:* This records the total quantity of the medication prescribed or available.
/////////////////////////////////////////

The  Logs table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

 [ID],[Integer],[Primary Key (PK)],[],
  [Schedule_ID],[String],[],[Schedules.ID],
  [Taken_At],[Timestamp],[],[],
  [Notes],[String],[],[],
 ),caption: [The    Logs table],
  
)}
*ID:* The Primary Key (PK) for the table.

*Schedule_ID:* This field is a Foreign Key (FK) that references the ID column in the Schedules table.

*Taken_At:* This field records the actual date and time when the drug was taken.

*Notes:* The data type is String. This field is used to store any additional notes or context about the verification event (e.g., "Late by 5 minutes," "Dose split in half").
/////////////////////////////////////////

The   Notifications table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: (4.4cm, auto,  auto, auto),
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

[ID],[Integer],[Primary Key (PK)],[],
[Patient_ID],[Integer],[],[Patients.ID],
[Medication_ID],[Integer],[],[Medications.ID],
  [ Notification_Sound ],[String],[],[],
  [Type],[Enum],[],[],
  [Sent_At],[Timestamp],[],[],
  [Read],[Boolean],[],[],
  ),caption: [The  Notifications table],
)}
*ID:* The Primary Key (PK) for the table.

*Patient_ID:* A Foreign Key (FK) referencing the ID in the Patients table.

*Medication_ID:* A Foreign Key (FK) referencing the ID in the Medications table.

*Notification_Sound:* Used to store the file path or name of the sound that should be played when the notification is delivered.

*Type:* Used to classify the category of the notification (e.g., "Dose Reminder," "Low Stock Alert," "System Message").

*Sent_At:* This field records the exact time and date when the notification was generated or sent.

*Read:* This flag indicates whether the user has viewed or acknowledged the notification (True for read, False for unread).
////////////////////////////////////////

The Measurements  table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon, 
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],


[ID],[Integer],[Primary Key (PK)],[],
[Patient_ID],[Integer],[],[Patients.ID],
[Caregiver_ID],[Integer],[],[Caregivers.ID],
  [Type],[Enum],[],[],
  [Value],[String],[],[],
    [Measured_At],[Timestamp],[],[],
     [Notes],[String],[],[],
       ),caption: [The   Measurements table],
)}
*ID:* The Primary Key (PK) for the table.

*Patient_ID:* A Foreign Key (FK) referencing the ID field in the Patients table.

*Caregiver_ID:* A Foreign Key (FK) referencing the ID field in the Caregivers table.

*Type:* It is used to define the kind of measurement recorded .

*Value:* This field stores the actual value of the measurement.

*Measured_at:* This records the exact date and time when the measurement was taken.

*Notes:* Used to store any additional remarks or context related to the measurement.
//////////////////////////////////////////

The  Report table will have the following columns:
#context {
  set text(size: 11pt)
  figure(
    
  
  table(columns: 4,
  align: center + horizon,  
  table.header[*Filed Name*][*Data Type*][*Constraints*][*FK*],

[ID],[Integer],[Primary Key (PK)],[],
[Caregiver_ID],[Integer],[],[Caregivers.ID],
 [Patient_ID],[Integer],[],[Patients.ID],
  [File_Path],[String],[],[],
  [Generated_At],[Timestamp],[],[],
     ),caption: [The Report table],
  
)}
*ID:* The Primary Key (PK) for the table.

*Caregiver_ID:* A Foreign Key (FK) referencing the ID field in the Caregivers table.

*Patient_ID:* A Foreign Key (FK) referencing the ID field in the Patients table. 

*File_Path:* This field is used to store the actual file path within the storage system or the URL where the generated report document is located.

*Generated_At:* This records the exact date and time when the report file was created or generated.
 
/////////////////////////////////////

== UI Desing

@dashboard-ui shows a dashboard that features a large display of Today's Adherence of the patient. It includes counters for Total Meds, Waiting, and Taken, along with a "Quick Actions" section for My Medicines, Full Schedule, and Add New Medication.

#figure(
  image("screenshot/homescreenweb.png"),
  caption: [The UI of the dashboard]
)<dashboard-ui>



#figure(
  image("screenshot/homephon.png", width: 33%),
  caption: [Mobile Home Screen .]
)<homephone>

@caledarweb: A monthly view for December 2025 to track the medication schedule. Colored dots on the dates indicate the status of doses (Completed, Pending, Missed) as defined in the Status Legend.
#figure(
  image("screenshot/caledarweb.png", width: 80%),
  caption: [Web Calendar UI]
)<caledarweb>

#figure(
  
  image("screenshot/calnderphone.png", width: 30%),
  caption: [Mobile Calendar UI.]
)

@addweb : A comprehensive screen for adding a new medication, including "Quick Add" options (Scan Box/Barcode), fields for Name, Dosage, Type, Classification, Frequency, a Refill Reminder setting, and a Notes section
#figure(
  image("screenshot/نسخة من screen.png"),
  caption: [Add New Medicine UI web.]
)<addweb>

#figure(
  image("screenshot/add_medcine.png"),
  caption: [Add New Medicine UI.]
)

#pagebreak()
== Development Tools and Workflow

This section describes the primary development tools, programming languages, and frameworks used in building the medication tracking application, as well as the workflow and version control practices employed throughout the development process.

=== Go Programming Language

Go (also known as Golang) is a statically typed, compiled programming language designed by Google engineers Robert Griesemer, Rob Pike, and Ken Thompson @golang2024. First released in 2009, Go was created to address shortcomings in other languages while maintaining their strengths, particularly for building reliable and efficient software at scale.

#image("figures/go-logo.png", width: 100%, height: 30%)

*Key Features of Go:*

+ *Simplicity and Readability:* Go features a clean, minimalist syntax that emphasizes code readability and maintainability. The language deliberately omits complex features found in other languages, making it easier to learn and reducing the likelihood of bugs @donovan2015go.

+ *Strong Static Typing:* Go's type system catches many errors at compile time, improving code reliability and reducing runtime errors. The language supports type inference, making code concise while maintaining type safety.

+ *Fast Compilation:* Go compiles extremely quickly to native machine code, enabling rapid development cycles. The entire Go standard library and most projects compile in seconds, significantly improving developer productivity.

+ *Built-in Concurrency:* Go provides first-class support for concurrent programming through goroutines and channels. Goroutines are lightweight threads managed by the Go runtime, allowing thousands of concurrent operations with minimal overhead. This makes Go particularly suitable for building responsive applications that handle multiple tasks simultaneously @golang2024concurrency.

+ *Garbage Collection:* Go includes an efficient garbage collector that automatically manages memory allocation and deallocation, reducing memory leaks and simplifying memory management without significant performance overhead.

+ *Cross-Platform Compilation:* Go supports cross-compilation, allowing developers to build executables for different operating systems and architectures from a single development machine. This feature is particularly valuable for our cross-platform application targeting Windows, macOS, and Linux.

+ *Standard Library:* Go includes a comprehensive standard library covering common tasks such as file I/O, networking, cryptography, string manipulation, and more. This reduces dependency on external libraries and ensures consistent behavior across platforms.

+ *Performance:* As a compiled language, Go produces efficient native binaries with performance comparable to C and C++, making it suitable for performance-critical applications.

*Go in This Project:*

In the medication tracking application, Go serves as the backend language, handling:
- Business logic and application state management
- SQLite database operations for local data storage
- Medication scheduling algorithms and reminder logic
- Notification system implementation
- Data encryption and security functions
- File generation (PDF reports, CSV exports)
- System integration for platform-specific features

Go's reliability, performance, and ease of deployment make it an ideal choice for the backend of a critical healthcare application where data integrity and system stability are paramount.

=== Wails Framework

Wails is a modern framework for building desktop applications using Go and web technologies @wails2024. Created by Lea Anthony, Wails allows developers to build native desktop applications with Go backends and web-based frontends (HTML, CSS, JavaScript), combining the performance and reliability of Go with the flexibility and rich UI capabilities of web technologies.

#image("figures/wails.png", width: 100%, height: 35%)

*Key Features of Wails:*

+ *Native Desktop Applications:* Wails produces truly native desktop applications for Windows, macOS, and Linux, not just web applications wrapped in a browser. Applications have native menus, system tray integration, and platform-specific features.

+ *Go Backend Integration:* Wails provides seamless communication between the Go backend and JavaScript frontend through a binding system. Go functions can be called directly from JavaScript with automatic type conversion and error handling @wails2024bindings.

+ *Modern Frontend Support:* Wails supports modern JavaScript frameworks including React, Vue, Svelte, and vanilla JavaScript. This allows developers to use familiar web development tools and practices while building desktop applications.

+ *Small Binary Size:* Unlike Electron-based applications, Wails applications have significantly smaller binary sizes because they use the operating system's native webview rather than bundling an entire browser engine. This results in faster startup times and lower memory usage.

+ *Live Development:* Wails includes a development mode with hot-reload functionality, allowing developers to see changes instantly without rebuilding the entire application.

+ *Native Dialogs and Menus:* Wails provides Go APIs for native system dialogs (open file, save file, message boxes) and native application menus, ensuring the application feels native to each platform.

+ *Asset Embedding:* Frontend assets (HTML, CSS, JavaScript, images) are embedded directly into the compiled binary, resulting in a single executable file that's easy to distribute.

+ *Event System:* Wails includes a bidirectional event system allowing both the frontend and backend to emit and listen for events, facilitating reactive programming patterns.

+ *No External Dependencies:* Wails applications require no runtime dependencies on the target system, making deployment straightforward and reducing compatibility issues.

*Wails in This Project:*

The medication tracking application leverages Wails to:
- Create native desktop applications for Windows, macOS, and Linux from a single codebase
- Bridge the Go backend (handling medication logic, database operations, notifications) with the Svelte frontend (providing the user interface)
- Utilize native system features such as notifications, file dialogs, and system tray integration
- Achieve small application size and fast startup times critical for user experience
- Enable rapid development through hot-reload functionality
- Produce standalone executables requiring no installation of additional runtimes

Wails' architecture aligns perfectly with the project's requirements for cross-platform compatibility, native performance, and ease of deployment.

=== Svelte Frontend Framework

Svelte is a modern JavaScript framework for building user interfaces, created by Rich Harris @svelte2024. Unlike traditional frameworks like React or Vue that do most of their work in the browser, Svelte is a compiler that converts declarative components into highly efficient JavaScript code that directly manipulates the DOM.

#image("figures/svelte-logo.jpg", width: 100%, height: 35%)

*Key Features of Svelte:*

+ *Compile-Time Framework:* Svelte shifts work from runtime to compile time, producing highly optimized vanilla JavaScript code. This results in smaller bundle sizes and better runtime performance compared to traditional frameworks @harris2019svelte.

+ *Reactive by Default:* Svelte's reactivity is built into the language syntax. Variable assignments automatically trigger UI updates without requiring special APIs or hooks, making code more intuitive and reducing boilerplate.

+ *No Virtual DOM:* Unlike React and Vue, Svelte doesn't use a virtual DOM. Instead, it generates code that surgically updates the DOM when state changes, resulting in faster updates and better performance.

+ *Component-Based Architecture:* Svelte uses a component-based architecture where each component is a self-contained unit combining HTML, CSS, and JavaScript. Components are highly reusable and maintainable.

+ *Scoped Styling:* CSS written in Svelte components is automatically scoped to that component, preventing style conflicts and making it easier to reason about styles.

+ *Small Bundle Sizes:* Because Svelte compiles away the framework itself, the resulting JavaScript bundles are significantly smaller than equivalent React or Vue applications, leading to faster load times.

+ *Built-in Transitions and Animations:* Svelte includes first-class support for transitions and animations, making it easy to create smooth, polished user interfaces without external libraries.

+ *Stores for State Management:* Svelte provides a simple but powerful store system for managing application state that works seamlessly with the reactive system.

+ *Accessibility Features:* Svelte includes built-in accessibility warnings during development, helping developers create more accessible applications.

*Svelte in This Project:*

The medication tracking application uses Svelte for the frontend, providing:
- A highly responsive user interface despite the focus on large components for accessibility
- Small bundle sizes ensuring fast application startup, critical for elderly users
- Reactive UI updates for real-time medication tracking and notifications
- Component-based architecture for building reusable UI elements (buttons, forms, medication cards)
- Built-in transitions for smooth navigation and feedback
- Simplified state management for tracking medication schedules and user preferences
- Accessibility-focused development with built-in warnings

Svelte's performance characteristics and intuitive programming model make it ideal for building the accessible, responsive interface required for elderly users.

=== Version Control and Development Workflow

The development of the medication tracking application follows industry best practices for software development, utilizing Git for version control and GitHub for collaboration and project management.

*Git Version Control:*

Git is a distributed version control system that tracks changes to source code throughout the development process @chacon2014pro. It enables:
- Complete history of all code changes with the ability to revert to previous versions
- Branching and merging for parallel development of features
- Collaboration among multiple developers without conflicts
- Backup and redundancy of the entire codebase

*GitHub Platform:*

GitHub serves as the central repository hosting platform and provides additional development tools @github2024:

+ *Repository Hosting:* The project's source code is hosted on GitHub, providing a central, cloud-based location accessible to all team members.

+ *Issue Tracking:* GitHub Issues is used to track bugs, feature requests, and tasks. Each issue can be assigned to team members, labeled for categorization, and linked to specific code changes.

+ *Pull Requests:* Code changes are submitted through pull requests, allowing for code review, discussion, and automated testing before merging into the main codebase.

+ *Project Boards:* GitHub Projects provides Kanban-style boards for organizing and prioritizing work, tracking progress from planning through completion.

+ *Documentation:* The repository includes comprehensive documentation in Markdown format, including README files, setup instructions, and API documentation.

+ *Continuous Integration:* GitHub Actions can be configured to automatically build, test, and validate code changes, ensuring quality and preventing regressions.

*Development Workflow:*

The project follows a structured Git workflow:

+ *Feature Branches:* Each new feature or bug fix is developed in a dedicated branch created from the main branch. This isolates changes and allows multiple features to be developed in parallel.

+ *Commit Messages:* All commits follow a consistent format describing what was changed and why, creating a clear history of the project's evolution.

+ *Code Reviews:* Pull requests are reviewed by team members before merging, ensuring code quality, sharing knowledge, and catching potential issues early.

+ *Main Branch Protection:* The main branch is protected, requiring pull request approval and passing tests before changes can be merged.

+ *Release Tags:* Stable releases are tagged with version numbers following semantic versioning (e.g., v1.0.0), making it easy to identify and deploy specific versions.

+ *Documentation Updates:* Documentation is updated alongside code changes to ensure it remains accurate and helpful.

This structured workflow ensures:
- Traceability of all changes
- Collaboration efficiency among team members
- Code quality through review processes
- Ability to rollback problematic changes
- Clear project history for academic documentation
- Best practices aligned with industry standards

The combination of Git for version control and GitHub for collaboration provides a robust foundation for developing, testing, and maintaining the medication tracking application throughout its lifecycle.
