= *Implementation*

This chapter describes the practical realization of the medication tracking application that was specified in the previous chapter, together with the development workflow that the team followed to deliver it. The first part of the chapter focuses on the application itself: the technologies that were used, the way the code base is structured, and the principal screens and features that were built. The second part of the chapter focuses on the engineering process: how source code was managed, how tasks were tracked, how changes were reviewed by team members, and how the project was continuously built and released using the tooling that GitHub provides.

== Application Development

=== Technology Stack

The application is implemented as a cross-platform desktop application using the *Wails* framework, version 2.11. Wails allows a Go program to embed a native web view and to expose Go functions directly to a JavaScript frontend, which made it possible to combine the performance, type safety and packaging story of Go with the productivity of a modern web user interface. The backend is written in Go (version 1.24) and the frontend is built with *Svelte* using *Vite* as the build tool. The two layers are bridged automatically by Wails: every exported method on the Go `App` struct is generated as a typed JavaScript function under `wailsjs/go/main/App.js`, and the Svelte pages import and call those functions just as they would any local function.

For data persistence the application uses *SQLite* through the *GORM* object-relational mapper. SQLite was chosen because it stores the entire database in a single file alongside the executable, which removes the need for a separate database server and keeps installation simple for non-technical caregivers. Passwords are hashed using the *bcrypt* algorithm from `golang.org/x/crypto/bcrypt`. Client-side routing inside the Svelte application is handled by `svelte-spa-router`, which provides a small hash-based router that matches the embedded single-page nature of a Wails window.

=== Project Structure

The repository is organized as a single Go module that embeds the compiled frontend at build time using Go's `embed` package. The Go side of the application is split into two files: `main.go`, which declares the data model structs that GORM uses to generate the database schema and starts the Wails runtime, and `app.go`, which contains the `App` type and all of the methods that the frontend is allowed to call. The Svelte frontend lives under `pills/frontend/src` and is organized by feature, with one page component per route under `pages/` and a small store in `stores/auth.js` that keeps the currently authenticated user in memory and exposes `login` and `logout` helpers. @fig:project-structure shows the layout as it appears in the editor.

#figure(
  image("implementation/10.png", width: 100%),
  caption: [Project structure of the pills application as viewed in VS Code.],
) <fig:project-structure>

=== Authentication and User Management

When the application is launched the user is presented with the welcome screen shown in @fig:login. From here a user signs in with an email address and a password, or follows the link to create a new account. The form submits to the Go method `Login(email, password)`, which normalizes the email, looks up the corresponding record in the `users` table, and compares the supplied password against the stored bcrypt hash. If the credentials are valid the returned `User` object is placed in the `currentUser` writable store and the router is redirected to the dashboard; otherwise an inline error message is shown.

#figure(
  image("implementation/1.png", width: 70%),
  caption: [The welcome screen and the sign-in form.],
) <fig:login>

Account creation calls `CreateUser`, which validates that the email is not already in use, hashes the password with bcrypt, and persists a new `User` record. The role field on the user (`Admin`, `Patient`, or `Caregiver`) controls which navigation items are shown by `App.svelte` and which routes are reachable; this single source of truth removes the need to duplicate authorization checks across every page.

=== Patient Dashboard

After signing in as a patient the user is taken to the dashboard shown in @fig:patient-dashboard. The dashboard greets the user by first name, displays the current date, and summarizes today's adherence by counting the doses that are due, the doses that are still waiting, and the doses that have already been taken. The percentage in the blue card is computed reactively from the schedules that are loaded from the backend by `GetPatientSchedules`. A quick actions panel on the right gives one-click access to the most common destinations, and an upcoming-doses card lists the next scheduled medications for the day.

#figure(
  image("implementation/2.png", width: 90%),
  caption: [The patient dashboard, showing today's adherence and the upcoming doses card.],
) <fig:patient-dashboard>

=== Schedule and Calendar

The most central feature of the application from a patient's point of view is the schedule view, shown in @fig:monthly-schedule. This page is reached from the *Schedule* link in the sidebar and supports four levels of detail: daily, weekly, monthly and yearly. The monthly view is illustrated in the figure. Each cell of the calendar belongs to a day in the displayed month and shows up to three adherence dots together with a `taken/due` ratio: a filled green dot represents a dose that has been taken on time, an empty dot represents a dose that is still due, and a red dot represents a missed dose. The progress bar at the top of the view summarizes the same information for the whole month, and the navigation arrows on either side of the title move forward and backward in time without leaving the current view.

Internally the calendar reads three pieces of information from the database. First, it calls `GetPatientSchedules` to obtain the medication schedules that apply to the current period. Each schedule contains the start date, end date, daily start hour and frequency, which are then expanded by the function `buildDailyDoseTimes` into a concrete list of dose instants. Second, the page calls `GetPatientLogs` to load the existing log entries and uses each entry's `ScheduledAtMs` field to match it against the expanded dose list. Third, when the user marks a dose as taken or untaken the page calls `LogDose` or `DeleteLog` to persist the change. Because the planned dose time is identified by its Unix-millisecond timestamp rather than by an auto-incremented identifier, the same dose can be reported multiple times without creating duplicate rows, which simplifies the logic that handles undoing a previous action.

#figure(
  image("implementation/3.png", width: 90%),
  caption: [The monthly schedule view with adherence dots and the per-month progress bar.],
) <fig:monthly-schedule>

=== Caregiver Workflow

A caregiver is a user whose role is `Caregivers` and who is therefore responsible for one or more patients. After signing in, the caregiver is presented with an extended sidebar that exposes the *Patients*, *Schedules*, *Edit Schedules* and *Users* pages. The *Patients* page (@fig:manage-patients) lists every patient that is currently linked to the caregiver's account and allows new patients to be linked by their email address. Internally the page calls `GetCaregiverPatients` to load the current list, `AddPatientByEmail` to create a new link, and `RemovePatientFromCaregiver` to remove an existing one. Each of these methods verifies on the Go side that the caller is in fact a caregiver and that the target user is in fact a patient, so that the authorization rules cannot be bypassed by editing the frontend.

#figure(
  image("implementation/9.png", width: 90%),
  caption: [The manage patients page used by caregivers to link or unlink patients.],
) <fig:manage-patients>

Once a patient is linked, the caregiver can assign medications to that patient from the *Schedules* page shown in @fig:add-schedule. The form captures the patient, the medication name and type, the dosage, the quantity per dose, the frequency in doses per day, the start hour and the start and end dates of the course of treatment, together with any free-form instructions such as "after meal, with water". As the caregiver types in the *Medication Name* field the page calls `SearchDrugInfo` after a short debounce period, which queries a built-in drug database table and returns trade names and scientific names that match the typed prefix. This allows the caregiver to select a known medication rather than risk a misspelling. When the form is submitted the page calls `CreateScheduleForPatient`, which re-verifies the caregiver-patient link, parses the dates and times, validates that the frequency is between one and five doses per day, creates the `Medication` row if it does not already exist, and finally inserts the `Schedule` row.

#figure(
  image("implementation/4.png", width: 90%),
  caption: [The medication schedule assignment form used by caregivers.],
) <fig:add-schedule>

Existing schedules can be modified through the *Edit Schedules* page shown in @fig:edit-schedules. After choosing a patient from the drop-down list the page calls `GetCaregiverPatientSchedules` to retrieve every schedule that belongs to that patient and renders them as cards that summarize the dosage, the validity window, the start hour, the daily frequency and the instructions. The *Edit* button next to each card opens an editor that pre-fills the same form fields as the creation view and calls `UpdateScheduleForPatient` on save.

#figure(
  image("implementation/5.png", width: 90%),
  caption: [The edit schedules page showing all schedules currently assigned to a patient.],
) <fig:edit-schedules>

=== Source Code Excerpts

To make the description above concrete, this section gathers a small number of representative excerpts from the source tree. Each excerpt is the verbatim contents of a file under `report/code/`, which mirrors the original code in `code/pills/` so that the same listings can be regenerated from the repository if the implementation changes. The Go listings cover the data model, the authentication flow, and the two methods that drive the schedule and the dose log; the JavaScript and Svelte listings cover the authentication store and the way a Svelte page imports and calls a Go method through the Wails bindings.

The struct definitions in @lst:models are read by GORM at startup through `db.AutoMigrate` and used to create the corresponding tables in the SQLite database. The `gorm.Model` mixin adds the primary key and the standard `CreatedAt`, `UpdatedAt` and `DeletedAt` columns to each table, the tag on `User.Email` declares a unique index that the database itself enforces, and the tag on `Schedule.Frequency` renames the column to `interval_hours` to remain compatible with the original database schema.

#[
  #set text(size: 9pt)
  #figure(
    raw(read("code/models.go"), lang: "go", block: true),
    caption: [GORM data-model declarations (excerpt from `pills/main.go`).],
  ) <lst:models>
]

The `Login` method in @lst:login is the entry point of the authentication flow. It normalizes the supplied email, looks up the corresponding user, and either compares the password against the stored bcrypt hash or, for legacy plain-text passwords inherited from earlier development versions, transparently upgrades the stored value to a bcrypt hash on first successful login.

#[
  #set text(size: 9pt)
  #figure(
    raw(read("code/login.go"), lang: "go", block: true),
    caption: [The `Login` method and the bcrypt helper (excerpt from `pills/app.go`).],
  ) <lst:login>
]

The `CreateScheduleForPatient` method in @lst:create-schedule is called by the *Schedules* page when a caregiver submits the medication assignment form. Note how the method first calls `verifyCaregiverPatientLink` to make sure that the caller is actually allowed to schedule medication for this patient, then parses the date and time strings that come from the HTML inputs, validates the daily frequency, creates the `Medication` row if it does not already exist, and finally inserts the `Schedule` row.

#[
  #set text(size: 9pt)
  #figure(
    raw(read("code/create_schedule.go"), lang: "go", block: true),
    caption: [Creating a medication schedule for a linked patient (excerpt from `pills/app.go`).],
  ) <lst:create-schedule>
]

The `LogDose` method in @lst:log-dose persists a single take-or-skip decision made by the patient on the schedule view. The combination of `schedule_id` and the planned `scheduled_at_ms` is treated as a natural key: if a row already exists it is updated in place, and if not a new one is inserted. This idempotent behavior is what allows the user to repeatedly mark and unmark a dose without producing duplicate log entries.

#[
  #set text(size: 9pt)
  #figure(
    raw(read("code/log_dose.go"), lang: "go", block: true),
    caption: [Idempotent dose logging (excerpt from `pills/app.go`).],
  ) <lst:log-dose>
]

On the frontend side, the small store in @lst:auth-store holds the currently authenticated user. Importing `Login` from the auto-generated `wailsjs/go/main/App.js` module turns the Go method into an ordinary asynchronous JavaScript function: there is no manual HTTP layer between the two languages because the call is dispatched by the Wails runtime directly. The `currentUser` writable store is consumed reactively from `App.svelte` to decide which sidebar items and which routes are available.

#[
  #set text(size: 9pt)
  #figure(
    raw(read("code/auth_store.js"), lang: "js", block: true),
    caption: [Authentication store (`pills/frontend/src/stores/auth.js`).],
  ) <lst:auth-store>
]

The Svelte component in @lst:welcome shows the login form itself, taken from `Welcome.svelte`. The `handleLogin` function calls the `login` helper from the store and surfaces a friendly error message if the call fails; the rest of the markup is bound to the local variables `email`, `password` and `isLoading` so that the user-visible state always reflects the underlying logic.

#[
  #set text(size: 9pt)
  #figure(
    raw(read("code/welcome.svelte"), lang: "svelte", block: true),
    caption: [The login form on the welcome page (excerpt from `pills/frontend/src/pages/Welcome.svelte`).],
  ) <lst:welcome>
]

Finally, @lst:home-load illustrates the typical pattern that the patient dashboard and the calendar use to read data from the backend: the Go method is imported just like any other JavaScript function, called from inside `onMount`, and its result is stored in a local variable that the rest of the component renders.

#[
  #set text(size: 9pt)
  #figure(
    raw(read("code/home_load.svelte"), lang: "svelte", block: true),
    caption: [Loading schedules from the Go backend in a Svelte page (excerpt from `pills/frontend/src/pages/Home.svelte`).],
  ) <lst:home-load>
]

== Development Workflow

Beyond writing the code itself, an important part of the project was the engineering process that the team adopted to coordinate the work of three contributors and to keep the software in a continuously releasable state. The source code is hosted in a public GitHub repository at #link("https://github.com/nashamri/pills")[`github.com/nashamri/pills`], which acts as the single point of integration for all of the tools that are described in the following sections.

=== Version Control with Git and GitHub

The repository is managed with *Git* and uses a feature-branch workflow: the `main` branch always reflects a working version of the application, and every change is first developed on a dedicated branch named after the feature or fix it implements (for example `edit-schedules`, `user-ui`, `fix-ci`). When a feature branch is ready the author opens a pull request against `main`, and once the change has been reviewed and the automated build has passed it is merged. @fig:git-graph shows the resulting history visualized with the *Git Graph* extension; the multiple colored lanes correspond to the feature branches that have been merged over the lifetime of the project, and the labels on the right of each commit identify the author. Over the course of the project the team produced *110 commits* across *4 contributors*.

#figure(
  image("implementation/11.png", width: 100%),
  caption: [The Git history of the project visualized with the Git Graph extension.],
) <fig:git-graph>

@fig:github-repo shows the public landing page of the repository. From this view the team and any external reader can see the README, navigate the source tree, switch between branches and tags, and inspect the latest release on the right-hand side. At the time of writing the repository contains *5 tags* and *4 published releases* (`v0.0.1`, `v0.0.2`, `v0.0.3` and `v0.5.0`), which were produced automatically by the release workflow that is described later in this section.

#figure(
  image("implementation/6.png", width: 100%),
  caption: [The GitHub landing page of the pills repository.],
) <fig:github-repo>

=== Issue Tracking

Every feature, bug and enhancement that was discussed by the team was captured as an *issue* on GitHub before any code was written for it. Using issues in this way turned an otherwise informal conversation into a permanent record that can be searched, filtered and referenced from commits and pull requests. @fig:github-issues shows a sample of the closed issues; the titles, written in Arabic, describe items such as enabling caregivers to edit patient schedules, displaying the user name and role in the top bar, restricting the *View Users* page to administrators, and persisting whether a dose has actually been taken. Over the course of the project *33 issues* were opened and subsequently closed, which together describe the full scope of the work that was carried out.

#figure(
  image("implementation/8.png", width: 100%),
  caption: [A sample of the closed issues used to plan and track the work.],
) <fig:github-issues>

=== Pull Requests and Code Review

All changes to the `main` branch entered the code base through a *pull request*. A pull request collects the commits on a feature branch into a single unit that can be reviewed, commented on and tested before it is merged. This had two practical benefits for the team: it gave every change a second pair of eyes before it reached the main branch, and it created a permanent narrative of why a particular set of changes was made, linked to the issue that motivated it. @fig:github-prs shows the list of closed pull requests; titles such as "تم اضافة خيار تعديل الدواء لمقدم الرعاية" (added the option to edit medications for the caregiver) and "fix release action" make the intent of each change clear at a glance. In total the project accumulated *40 closed pull requests*, of which *34* were merged into `main`.

#figure(
  image("implementation/7.png", width: 100%),
  caption: [The list of pull requests used to review and merge feature branches.],
) <fig:github-prs>

=== Continuous Integration with GitHub Actions

To make sure that the application could always be compiled the team configured two *GitHub Actions* workflows under `.github/workflows/`. The first workflow, `build.yml`, defines the *Build Check* job that runs on every pull request targeting `main`. It checks out the source code on an Ubuntu runner, installs Go 1.24, Node.js 20 and the GTK and WebKit development libraries that Wails depends on, installs the Wails CLI, and runs `wails build`. Because this job is required to pass before a pull request can be merged, broken code is caught at review time rather than after it has reached the main branch. The recent history of the workflow shows that every pull request that has been merged into `main` has been verified by this job, with build times of about three minutes per run.

The second workflow, `release.yml`, defines the *Build and Release* job and is triggered whenever a tag of the form `vX.Y.Z` is pushed to the repository. It uses a build matrix to compile the same source code three times in parallel: once on Ubuntu 22.04, once on macOS, and once on Windows. Each platform produces a binary that is uploaded as an artifact (`pills-linux`, `pills-macos.zip` and `pills-windows.exe`), and a final `release` job downloads the three artifacts and attaches them to a new GitHub Release using the `softprops/action-gh-release` action. This made it possible to publish the four official releases of the project, `v0.0.1`, `v0.0.2`, `v0.0.3` and `v0.5.0`, without anyone having to compile or sign the binaries by hand on each operating system. Together with the issue tracker and the pull-request based review process, the two CI workflows give the project a complete and repeatable path from a planned issue to a published, cross-platform release.
