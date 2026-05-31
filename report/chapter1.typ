// Chapter 1: Project Overview
// Medication Tracking Application for Elderly Users

= *Project Overview*

== Introduction

Medication adherence remains a critical challenge in healthcare, particularly among elderly populations who often manage multiple chronic conditions requiring complex medication regimens. Research indicates that approximately 50% of elderly patients do not take their medications as prescribed @cutler2018economic @jin2008factors @osterberg2005adherence, leading to adverse health outcomes, increased hospitalizations, and higher healthcare costs estimated at \$100-300 billion annually in the United States alone @iuga2014adherence @nehi2009thinking @viswanathan2012interventions. This non-adherence is associated with approximately 125,000 preventable deaths annually and accounts for at least 10% of hospitalizations @mcdonnell2002hospital. The non-adherence stems from various factors including forgetfulness, confusion about medication schedules, difficulty reading prescription labels, and lack of caregiver oversight @yap2016medication @ruppar2016medication.

The elderly population faces unique challenges in medication management due to age-related cognitive decline, visual impairments, and the complexity of managing multiple medications simultaneously—a phenomenon known as polypharmacy. Polypharmacy, commonly defined as the regular use of five or more medications @masnoon2017polypharmacy, is prevalent among older adults, with approximately 44% of men and 57% of women older than 65 years taking five or more prescription and/or nonprescription medications per week @kantor2015trends. Studies show that adherence rates decrease significantly with increased dosing frequency, dropping from approximately 80% for once-daily medications to 50% for medications taken four times daily @claxton2001systematic. These challenges are compounded when caregivers are not physically present to provide reminders and oversight, creating a gap in medication adherence monitoring.

Digital health solutions have emerged as promising tools to address these challenges. However, most existing medication tracking applications are designed for general audiences and fail to account for the specific needs of elderly users, such as larger interface elements, simplified navigation, and persistent reminder systems. Furthermore, many solutions lack the caregiver integration necessary for effective remote monitoring and intervention.

This project addresses these gaps by developing a dedicated medication tracking application specifically designed for elderly users and their caregivers. Built using modern web technologies (JavaScript, HTML, CSS, Svelte) with a Go backend through the Wails framework, the application can be deployed both as native desktop applications and as a web application accessible through browsers. By combining accessibility-focused design principles with robust tracking and notification features, the application aims to improve medication adherence rates and enhance the quality of care for elderly patients.

== Project Scope

The scope of this project encompasses the design, development, and implementation of a cross-platform medication tracking application tailored for elderly users and their caregivers. The application will be deployable both as native desktop applications and as a web application, leveraging web technologies through the Wails framework.

*In Scope:*

- Development of native desktop applications compatible with Windows, macOS, and Linux operating systems using the Wails framework
- Web application deployment accessible through modern web browsers
- User registration and authentication system for both patients and caregivers
- Comprehensive medication management features including adding, editing, and deleting medication records
- Flexible scheduling system supporting various medication intervals (daily, weekly, custom intervals)
- Multi-modal notification and reminder system with customizable alerts
- Medication adherence logging and tracking capabilities
- Caregiver dashboard for monitoring multiple patients
- Historical reporting and data visualization features
- PDF report generation for healthcare provider consultations
- Medication quantity tracking and refill reminder system
- Health measurement tracking (blood pressure, glucose levels)
- Multi-language support (Arabic and English)
- Barcode scanning functionality for medication entry
- Drug database integration for simplified medication lookup
- Drug interaction warning system
- Accessibility-optimized user interface design
- Local data storage ensuring privacy and offline functionality

*Out of Scope:*

- Native mobile applications (iOS/Android apps using native frameworks)
- Cloud-based synchronization or backup services
- Telemedicine or video consultation features
- Prescription management or electronic prescribing
- Insurance claim processing
- Medication ordering or pharmacy integration
- Wearable device integration
- AI-powered health prediction or diagnosis features


== Problem Description

The aging global population faces significant challenges in managing their medication regimens effectively. This problem manifests across several dimensions:

*1. Medication Non-Adherence*

Elderly patients frequently miss doses, take incorrect amounts, or discontinue medications prematurely. This non-adherence results from cognitive challenges, forgetfulness, and confusion about complex medication schedules involving multiple drugs with different dosing requirements.

*2. Polypharmacy Complexity*

Many elderly individuals take five or more medications daily, each with unique timing, dosage, and administration requirements. Managing this complexity without proper tools leads to errors, missed doses, and potential drug interactions.

*3. Communication Gap Between Patients and Caregivers*

Family caregivers often lack real-time visibility into their elderly relatives' medication adherence, particularly when not living in the same household. This gap prevents timely intervention when doses are missed and reduces overall care effectiveness.

*4. Accessibility Barriers in Existing Solutions*

Current medication tracking applications typically feature small fonts, complex navigation, and interfaces designed for younger, tech-savvy users. These design choices create significant barriers for elderly users with visual impairments, reduced motor control, or limited technological experience.

*5. Lack of Comprehensive Tracking*

Many elderly patients and their healthcare providers lack detailed records of medication adherence patterns, making it difficult to identify problems, adjust treatment plans, or provide accurate information during medical appointments.

*6. Privacy Concerns*

Existing commercial solutions often require cloud connectivity and data sharing, raising privacy concerns among elderly users and their families who may be uncomfortable with sensitive health data being stored on external servers.

*7. Offline Dependency*

Some elderly users may have unreliable internet connections or prefer systems that function independently of online services. Many current solutions fail to operate effectively in offline scenarios.

These interconnected problems create a clear need for a specialized solution that addresses the unique requirements of elderly medication management while maintaining simplicity, reliability, and respect for user privacy.

== Project Objectives

The primary objectives of this project are:

*1. Improve Medication Adherence*

Develop a system that significantly reduces missed doses through reliable, timely notifications and easy-to-use logging features, ultimately improving health outcomes for elderly users.

*2. Enhance Caregiver Oversight*

Enable caregivers to monitor medication adherence remotely, receive alerts for missed doses, and access comprehensive adherence reports without requiring constant physical presence.

*3. Create an Accessible User Interface*

Design an interface specifically optimized for elderly users, featuring large fonts, high contrast ratios, simplified navigation, and intuitive controls that accommodate age-related visual and motor challenges.

*4. Ensure Cross-Platform Compatibility*

Build an application that functions seamlessly across Windows, macOS, and Linux as native desktop applications, as well as through web browsers, ensuring accessibility regardless of the user's platform preference.

*5. Maintain User Privacy and Data Security*

Implement local data storage solutions that keep all medication and health information completely private, with no mandatory cloud synchronization or third-party data sharing.

*6. Provide Comprehensive Medication Management*

Support complex medication schedules, track multiple medications simultaneously, manage medication quantities, and provide timely refill reminders.

*7. Facilitate Healthcare Provider Communication*

Generate detailed, professional PDF reports of medication adherence history that patients and caregivers can share with doctors and healthcare providers during consultations.

*8. Simplify Medication Entry*

Reduce the burden of data entry through barcode scanning, drug database integration, and streamlined input processes.

*9. Ensure System Reliability*

Create a robust system that operates reliably offline, delivers notifications with high precision, and maintains data integrity even under various failure scenarios.

*10. Support Internationalization*

Implement multi-language support starting with Arabic and English to serve diverse user populations and improve global accessibility.

*11. Promote Open-Source Development*

Develop the application as an open-source project to encourage community contributions, enable security auditing, and ensure long-term sustainability and improvement.

== Proposed Solution

To address the identified problems and achieve the stated objectives, this project proposes developing a specialized medication tracking application using modern, cross-platform technologies.

*Technical Architecture:*

The application will be built using the Wails framework, which combines a Go backend with a Svelte frontend using standard web technologies (JavaScript, HTML, CSS). This architecture enables the creation of both native desktop applications and web applications from a single codebase. This approach provides several advantages:

- *Go Backend:* Handles business logic, data storage, notification scheduling, and system interactions with high performance and reliability
- *Svelte Frontend:* Delivers a responsive, accessible user interface built with modern web technologies (JavaScript, HTML, CSS) with minimal overhead and excellent performance
- *Wails Framework:* Enables native desktop application development with platform-specific optimizations while maintaining the same codebase for web deployment
- *Web Technologies:* Using standard web technologies (HTML, CSS, JavaScript) ensures the application can be deployed as both desktop applications and accessible through web browsers

*System Components:*

+ *User Management System*
  - Separate account types for patients and caregivers
  - Secure authentication with encrypted credential storage
  - Support for caregivers managing multiple patient profiles

+ *Medication Management Module*
  - Comprehensive medication database with details (name, type, dosage, quantity)
  - Flexible scheduling engine supporting various intervals
  - Barcode scanning integration for quick medication entry
  - Drug database lookup for automated information retrieval
  - Drug interaction checking system

+ *Notification and Reminder Engine*
  - High-precision scheduled notifications (±10 seconds accuracy)
  - Customizable notification sounds including persistent alerts
  - Multi-level reminder system (initial alert, snooze, escalation)
  - Desktop notification integration using native OS features

+ *Adherence Tracking System*
  - Simple, large-button interface for logging dose status
  - Automatic tracking of taken, skipped, and snoozed doses
  - Medication quantity depletion tracking
  - Automated refill reminders

+ *Caregiver Dashboard*
  - Multi-patient overview with real-time status
  - Missed dose alert system
  - Historical adherence visualization
  - Health measurement tracking integration

+ *Reporting and Analytics*
  - Comprehensive adherence history logs
  - PDF report generation with professional formatting
  - Data visualization for pattern identification
  - Exportable reports for healthcare providers

+ *Data Storage Layer*
  - Local SQLite database for all user data
  - Encrypted storage for sensitive information
  - No cloud dependency or mandatory internet connectivity
  - Privacy-first architecture

*Deployment Model:*

The application will be distributed through two deployment channels:

+ *Desktop Applications:* Standalone installers for Windows, macOS, and Linux, requiring no additional dependencies or runtime installations. Updates will be managed through a simple check-and-download mechanism that respects user privacy.

+ *Web Application:* Accessible through modern web browsers, allowing users to access the application without installation. The web version will maintain the same functionality and user interface as the desktop applications, ensuring a consistent experience across deployment methods.

