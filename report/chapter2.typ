= *System Analysis*

This chapter establishes the analytical foundation for the medication tracking application by examining existing solutions, defining system requirements, and modeling user interactions. The analysis begins with a comprehensive review of current medication reminder applications to identify their strengths and limitations, particularly regarding elderly users' needs. Building on these insights, the chapter presents our proposed solution and its distinguishing features, followed by a formal specification of functional and non-functional requirements that guide system development. The latter sections detail the system's behavior through use cases, their descriptions, and sequence diagrams that illustrate the interactions between users, caregivers, and the application. This systematic analysis ensures the proposed solution is grounded in real-world needs and provides a clear roadmap for implementation.

==  Review of Current Solutions


===  Health from Apple 

Apple Health is an app that safely gathers all of your important health data in a single, private location, including activity, medication, sleep, and more. It makes it simple to monitor your health over time by allowing you to access and manage health data from your iPhone, Apple @apple-health.

#figure(
  image("figures/apple_helth_logo.webp", width: 20%),
  caption: [Apple health application logo.],
)


*Advantages*

- *Centralized Health Information:* The Apple Health app consolidates health data from various sources into one secure and accessible location on your iPhone and iPad. 

- *Comprehensive Tracking:* It tracks a wide range of metrics, including activity, sleep, heart rate, blood oxygen, and medications, providing a holistic view of your health. 

- *Advanced Analysis:* Interactive charts and advanced trend analysis allow you to visualize and understand your health data over time. 

- *Emergency Features:* Features like irregular rhythm notifications, high/low heart rate alerts, ECG app, and fall detection can provide critical alerts in emergencies. 

- *Integration with Apps:* The platform integrates with a vast ecosystem of health and fitness apps, making it a comprehensive tool for managing well-being. 

- *Data Privacy:* For users with proper security measures like two-factor authentication and pass-codes, Health app data can be end-to-end encrypted, making it harder to decrypt. 


*Disadvantages*

- *Platform Exclusivity:* The HealthKit platform is designed exclusively for Apple devices, limiting its use for users on other platforms. 

- *Accuracy Concerns:* Some sensor data, particularly for sleep quality, may have accuracy limitations, requiring careful interpretation and potentially needing additional tools for clinical use. 

- *Reliance on Technology:* Continuous monitoring requires the device to be worn, and charging can interrupt data collection, especially for sleep tracking. 

- *Device Cost:* Accessing Apple's full suite of health features requires the purchase of an Apple Watch, which can be expensive @macrumors-health.

#figure(
  image("screenshot/1add-medication-health-ios.webp",width: 85% , ),
  caption: [Apple Health: Choosing the medication type (capsule, liquid, cream, etc.)]
)
#figure(
  image("screenshot/2add-medication-health-ios.webp", width: 70% ),
  caption: [Apple Health: choose a unit from the list]
  
)

#pagebreak()

=== Medisafe

Medisafe is a leading medication engagement platform that helps patients manage their treatment journey with personalized reminders, adherence tracking, and support tools. It simplifies medication management by providing timely alerts and behavior-based interventions to improve medication adherence and persistence @medisafe-health.
#figure(
  image("figures/medisafe_logo.jpg",width: 20%),
  caption: [medisafe health logo]
)

*Advantages* 
- *Customizable Reminders:* Get reminders that stop only when you act on them, with options for sound, vibration, and "Medtones". 

- *Comprehensive Tracking:* Track medications and health measurements like blood pressure, blood glucose, weight, and pain. 

- *Medfriend Feature:* Assign a family member or friend to receive notifications if you miss a dose, providing a crucial support system. 

- *Refill Reminders: *Receive alerts when it's time to refill your prescriptions, ensuring you don't run out. 

- *Health App Integration:* Syncs with Apple's HealthKit to keep your health data organized in one place. 

- *Doctor-Friendly Reports:* Generate and share detailed progress reports with your doctor as a PDF. 

- *High User Engagement:* Medisafe is praised for its user-friendly interface, visual appeal, and engaging features, scoring well in app quality assessments. 

#pagebreak()
*Disadvantages* 

- *Premium Features:* Many of the advanced features, like unlimited Medfriends, no banner ads, and priority support, are part of the paid premium version.

- *Database Limitations:* The app's extensive medication database is US-focused, meaning some common medications in other regions may not be available and must be entered manually. 

- *Complex Setup:* The initial setup process can be time-consuming, as you must input all medication details and can sometimes be difficult to find the correct indication for a medication.

- *No Proactive Mood/Lab Tracking:* While it tracks measurements, there's no direct, integrated feature to track mood episodes, sleep changes, or lab values (like lithium levels) to correlate with medication adherence.

- *Medfriend Data Visibility:* When you designate a Medfriend, they can see all your medications and schedules, which is a potential privacy concern. 

- *App-Based Only:* You can only manage your information and data through the app on your smartphone; there is no web portal for acces

#pagebreak()

*intro*:The comprehensive medication management platform offers five essential features designed to streamline healthcare management. Users receive customizable medication and refill reminders with personalized notification options to accommodate complex dosing schedules @medisafe-health.

#figure(
  image("screenshot/medisafe_Family_Scheduling_Tracking_2_V3.jpg"),
  caption: [All-in-One Medication Tracking and Health Monitoring Tools]
)


////////////////////////////////////////////////////////
#pagebreak()
=== MyTherapy

The MyTherapy app is a leading digital health companion designed to help users manage their medication schedules, track symptoms, and maintain overall health through reliable reminders and comprehensive documentation features. Millions of people use MyTherapy worldwide, making it one of the most popular medication management applications available today. Its core function is to ensure that patients take the right medication at the right time while offering additional support for those with chronic conditions and complex treatments.

#figure(
  image("figures/my_therapy_logo.png", width: 20%),
  caption: [My therapy application logo.],
)
*Advantages* 
- *Comprehensive Health Tracking:* MyTherapy allows users to track a wide range of health metrics, including blood pressure, blood sugar, weight, mood, and symptoms. This comprehensive tracking helps users monitor their health status and share detailed reports with healthcare providers.  

- *Medication Reminders:* The app provides timely reminders for taking medications, ensuring users adhere to their prescribed schedules. It also offers refill reminders to prevent running out of essential medications.  

- *User-Friendly Interface:* MyTherapy boasts an intuitive design, making it accessible for users of all ages. Features like barcode scanning simplify medication logging, and customizable reminder settings cater to individual needs.  

- *Team Collaboration:* The app includes a team feature that allows users to involve caregivers or family members. This collaborative approach enhances medication adherence and provides additional support.  

- *Free and Secure:* MyTherapy is free to download and use, with no hidden costs. It prioritizes user privacy and complies with stringent data protection standards, ensuring secure handling of personal health information.  

*Disadvantages* 

- *Manual Medication Entry:* Some medications may not be available in the app’s database, requiring users to manually enter details. This can be time-consuming and may lead to inaccuracies if not done carefully.  

- *Limited Symptom Tracking:* While the app offers symptom tracking, it may not cover all symptoms relevant to certain conditions. Users with specific health needs might find this feature lacking.  

- *Data Entry Effort:* Consistent data entry is essential for accurate tracking. Some users may find the process tedious, especially when logging multiple health metrics daily.  

- *Lack of Drug Interaction Warnings:* Unlike some other medication reminder apps, MyTherapy does not provide alerts for potential drug interactions, which could be a crucial feature for users on multiple medications.  

- *No Notes or Customization for Medications:* The app lacks features to add personal notes about medications or customize settings for specific dosing instructions, which might be important for users with complex medication regimens.

////////////////////////////////////////////////////////////
#pagebreak()
=== EveryDose
EveryDose is a top-rated mobile app designed to help individuals manage their daily medications easily and reliably with the help of personalized medication reminders, educational resources, and AI-powered support. The app aims to improve medication adherence and reduce the risk of missed doses or errors, supporting healthier outcomes for users.
#figure(
  image("figures/every_dose_logo.png", width: 20%),
  caption: [EveryDose application logo.]
)
*Advantages* 
- *User-Friendly Interface:* EveryDose is designed with simplicity in mind, making it accessible for users of all ages. The intuitive layout allows for easy medication tracking and reminder setup.

- *AI-Powered Virtual Assistant – Maxwell:* The app features “Maxwell,” an AI assistant that provides personalized support, answers medication-related questions, and offers reminders, enhancing user engagement and adherence.

- *Comprehensive Medication Management:* Users can input various medications, including prescriptions, over-the-counter drugs, and supplements. The app offers features like dosage instructions, refill reminders, and drug interaction alerts.

- *Family and Caregiver Support:* The Family Hub feature allows users to manage multiple profiles, making it easier for caregivers to monitor and support loved ones’ medication adherence.

- *Cross-Platform Synchronization:* EveryDose supports synchronization across multiple devices, ensuring users have access to their medication information wherever they go.

- *Free Access with Optional Premium Features:* The core functionalities of the app are free, with optional premium features available for users seeking advanced tools and customization.
#pagebreak()
*Disadvantages* 

- *Occasional Notification Glitches:* Some users have reported issues with notifications persisting even after marking medications as taken. While these glitches are infrequent, they can be disruptive.

- *Limited Advanced Features in Free Version:* While the free version offers essential medication tracking, certain advanced features, such as detailed analytics and enhanced customization, are only available through the premium subscription.  

- *Data Entry for Complex Regimens:* Users with intricate medication schedules may find manual data entry time-consuming, especially when dealing with multiple medications and varying dosages.


=== Round Health
Round Health is a thoughtfully designed medication reminder app aimed at making it easier to remember to take your medicines and vitamins so you can stay healthy with less stress. The app organizes all of your medications and supplements in one place and features a clean, intuitive interface that accommodates even complex dosing schedules.
#figure(
  image( "figures/round_health_logo.jpg", width: 20%),
  caption: [Round Health application logo.],
)


*Advantages:* 

- *Simple and Elegant Design:* It is considered one of the most beautiful apps in its category. It uses a simple, circular design to display medications and their schedules, making the interface easy to read and pleasing to the eye. User experience is the top priority here.

- *Complete Focus on Privacy:*
 It does not require you to create an account or provide any personal information (no email, no name). All your data is saved locally on your device and synced securely via your iCloud account between your devices (iPhone and Apple Watch).

- * Flexible Dose Management:*
 It allows you to easily add medications and vitamins, specifying flexible and variable schedules to suit different treatment types.
 
- * Tracks Remaining Medication Quantity:*
 You can enter the total quantity of the medication when you add it, and the app will remind you when it's time to refill the prescription.


*Disadvantages:*

- *Available for Apple Devices Only:*
  The app is exclusive to the iOS ecosystem. This means that Android users cannot use it, which is a major drawback that makes it unsuitable for a huge segment of users.

- *Completely Lacks Advanced Features:*
 It is even simpler than other basic apps. It does not have any kind of reporting, symptom tracking, data sharing with family, or drug interaction checks. It is simply a beautiful and effective reminder tool.

- *No Backup Option Outside of iCloud:*
 Since the app does not use its own accounts, the only way to save and sync your data is through iCloud. If you don't use iCloud, your data will remain on a single device.

/////////////////////////////////////////////////
=== Dosecast
Dosecast is a highly flexible and user-friendly medication management app designed to help you remember to take your medications, vitamins, , exactly when needed. With millions of downloads, Dosecast is recognized for its reliable notifications, customizable reminders, medication tracking, and support for complex schedules, making it a trusted companion for users around the world
#figure(
  image( "figures/dosecast.jpg", width: 20%),
  caption: [Dosecast application logo.],
)

*Advantages:* 

 - *Flexible and Advanced Scheduling:*
  High Customization: This is Dosecast's strongest feature. You can set reminders for doses taken every few hours, daily, on specific days of the week, or even every set number of days or weeks (e.g., every 3 days or every two weeks).
 
- *Smart and Persistent Reminders:*
 Nagging Reminders: If you don't record that you've taken your dose, the app will continue to send consecutive notifications until you respond to it.
 Dose Tracking and History Log:
 The app records every dose you take with the exact time and date. This log is very useful for sharing with your doctor to track your treatment adherence.

- *Drug Database:*
  It includes a built-in drug database, which simplifies the process of entering medication names.

*Disadvantages:*
- *Free Version Limitations:*
  Many advanced and important features, such as complex scheduling, data syncing across devices, and managing medications for family members, are only available in the paid version (Pro Edition). The free version may be very limited for some users.
  Somewhat Outdated Design:
  Compared to modern apps like Medisafe or MyTherapy, Dosecast's interface looks a bit old and lacks visual appeal, which might not be pleasing to some users.
 
- *Lack of Additional Health Features:*
 The app focuses almost entirely on medication reminders. Unlike other apps, it does not provide extra features for tracking vital signs (like blood pressure or glucose levels), logging symptoms, or monitoring physical activity.
 
- *Persistent Notifications Can Be Annoying:*
   The feature that is considered a strength (the recurring reminders) might be found annoying or excessive by some users, especially if they already receive many notifications on their phones.

- *Can Be Complex for New Users:*
 The abundance of customization options when setting up doses can be confusing at first for users who are looking for a very simple app.
 
== Our Solution

The proposed medication tracking application addresses the identified challenges through a solution designed specifically for elderly users and their caregivers. The following subsections detail the key features that distinguish this solution from existing alternatives in the market.

#pagebreak()
=== Cross-platform:

Cross-platform compatibility is a key feature of modern medication reminder apps, ensuring users can access their data and reminders across multiple devices and operating systems seamlessly:
Many apps support both iOS and Android platforms, allowing a wide range of smartphone users to utilize the service.

Apps like Medisafe, MyTherapy, EveryDose, and Dosecast offer cross-platform functionality, syncing data between phones, tablets, and wearable devices. Cross-platform support often includes integration with Apple Health on iOS and Google Fit on Android to consolidate health data.

Limited cross-platform apps like Apple Health and Round Health restrict usage to specific ecosystems, which can be a disadvantage.

Our solution will be develop as a cross-platform app to attract a broader user base, including those managing health across family members or caregivers using different devices. The choice of a cross-platform medication app enhances flexibility, user experience, and long-term commitment to medication adherence.

=== Privacy
Privacy is a critical feature in medication reminder apps, ensuring user data is protected and secure. Most apps, including
popular ones like Medisafe, MyTherapy, and Dosecast, comply with international standards such as HIPAA and GDPR to safeguard personal health information. Data encryption is applied both on the device and during transmission to prevent unauthorized access. Users have control over what information is shared and with whom, such as family members or healthcare providers. Many apps implement authentication methods to further protect sensitive data. Privacy policies are transparent and readily available, explaining how data is collected and used. Some apps offer anonymous usage without needing registration. Regular updates and audits help maintain security standards. Overall, these measures build user trust and comply with legal privacy requirements, protecting users’ confidential medication and health data effectively.

=== Open-Source

The application is developed and distributed as open-source software, meaning its complete source code is publicly accessible, auditable, and modifiable by anyone. This transparency stands in stark contrast to proprietary medication tracking applications where users must trust vendors with sensitive health information without any ability to verify how their data is handled. By adopting an open-source model, the project invites scrutiny from the global developer community, security researchers, and healthcare professionals who can examine the codebase to ensure it meets the highest standards of data protection and functionality. This collaborative approach not only enhances security through collective oversight but also accelerates innovation as contributors worldwide can suggest improvements, fix bugs, and add features that benefit all users.

=== Customizations
Recognizing that elderly users have diverse needs and preferences, the application provides extensive customization capabilities that enhance both usability and effectiveness. Users can personalize their medication reminders by assigning distinct notification sounds for different medications or times of day, helping them immediately identify which medication requires attention without needing to check their device. 

Furthermore, the user interface itself offers flexibility in layout, font sizes, contrast ratios, and button dimensions, allowing caregivers to configure the application to match the specific accessibility requirements of individual users. This degree of customization ensures that the application adapts to the user.


=== Cost

Most medication reminder apps follow a freemium pricing model, providing a free basic tier with core features like medication reminders and schedules. Paid plans unlock premium functions such as multiple alerts, snooze options, sharing with caregivers, exporting reports, and integration with wearables. Monthly subscription prices typically range from about 3 to 10 USD, equivalent to roughly 15–40 SAR per month in Saudi Arabia. Free versions suffice for simple medication regimens; premium upgrades benefit those managing multiple drugs or requiring detailed reports.

In contrast to the prevailing freemium model adopted by most medication reminder applications, our solution is offered completely free of charge with no premium tiers or subscription fees. All features—including multiple medication tracking, customizable alerts, caregiver sharing capabilities, and comprehensive reporting—are available to every user without financial barriers. This approach is particularly significant for elderly users and their families, who may be managing fixed incomes or already facing substantial healthcare expenses. By eliminating cost as a barrier to entry, the application ensures that effective medication management tools remain accessible to all users regardless of their economic circumstances. The open-source nature of the project sustains this free model while fostering community-driven improvements and transparency, allowing the solution to serve its primary goal of improving health outcomes rather than generating revenue.

=== Internationalization

Internationalization in medication reminder apps ensures the app’s usability and relevance to users worldwide, adapting to different languages, cultures, and regional healthcare systems. Major apps support multiple languages, enabling users from diverse backgrounds to understand and navigate the interface easily. For instance, MyTherapy supports over 30 languages and is available in 120 countries.

Our solution will offer support mainly for Enlgish and Arabic language to help with localization adjustments of date/time formats, units of measurement, and notifications and all UI elements.


////////////////////
== Comparisons table
#context {
  set text(size: 11pt)
  table(columns: 7,
  align: center + horizon,
  table.header[*App*][*Cross-Platform?*][*Privacy?*][*Open-source?*][*Customization?*][*Cost*?][*I18n?*],
  
  [Apple Health],[No],[Partially],[No],[No],[Paid],[Yes],
 
  [Medisafe],[Yes],[Partially],[Partially],[Yes],[Free],[Yes],
  
  [MyTherapy],[Yes],[Partially],[No],[Partially],[Free],[Yes],
 
  [EveryDose],[Yes],[Partially],[No],[Yes],[Partially Free],[Yes],
 
  [Round Health],[No],[Partially],[No],[No],[Yes],[No],
  
  [Dosecast],[Yes],[Partially],[No],[No],[Partially Free],[No],
 
  [Our Soltion],[Yes],[Yes],[Yes],[Yes],[Yes],[Yes],
)}
#pagebreak()
== Functional Requirements

#context {
  set text(size: 10pt)
  table(columns: (2cm, 1.9cm, auto),
  inset: 0.2cm,
  align: (center + horizon, center + horizon, left + horizon),
  table.header[*ID*][*Priority* \ * Low: 1 \ High: 10*][#align(center)[*Requirement*]],
[FREQ-1],[10],[The patient and caregiver should be able to register a new account.], 
[FREQ-2],[10],[The patient and caregiver should be able to login and logout of the system.], 
[FREQ-3],[10],[The caregiver should be able to add / delete  medication (name, type, dosage, quantity).], 
[FREQ-4],[10],[The caregiver should be able to set a flexible medication schedule (daily, weekly, every 'x' hours, etc.).], 
[FREQ-5],[10],[The system must send reminder notifications to the patient at the scheduled time.], 
[FREQ-6],[9],[The patient should be able to log the status of a dose (taken, skipped, snoozed).], 
[FREQ-7],[9],[The caregiver should be able to add one or more patients to their account.], 
[FREQ-8],[9],[The caregiver should receive a notification if the patient misses a dose.], 
[FREQ-9],[8],[The system must allow users to customize notification sounds, including options for loud or persistent tones to ensure they are heard.],
[FREQ-10],[8],[The system should track the remaining quantity of the medication.], 
[FREQ-11],[8],[The system must send a refill reminder when the medication is running low.], 
[FREQ-12],[7],[The caregiver should be able to track additional health measurements (e.g., blood pressure, blood glucose).], 
[FREQ-13],[7],[The caregiver should be able to view a history log of taken and skipped doses.], 
[FREQ-14],[7],[The caregiver should be able to generate PDF reports to share with the doctor.], 
[FREQ-15],[6],[The system should ease the entry of new medications by scanning bar-codes.], 
[FREQ-16],[5],[The system should provide a drug database to search from, to ease the entry of new medications.], 
[FREQ-17],[4],[The system should provide drug interaction warnings when adding a new medication.], 
[FREQ-18],[7],[The system must support multiple languages (At least Arabic and English) to improve internationalization.],

)
}

== Non-Functional Requirements

#context {
  set text(size: 10pt)
      table(columns: (2cm, 1.9cm, auto),
  inset: 0.2cm,
  align: (center + horizon, center + horizon, left + horizon),
  table.header[*ID*][*Priority* \ * Low: 1 \ High: 10*][#align(center)[*Requirement*]],
  [NREQ-1],[10],[The UI must be designed with large, clear fonts, easy-to-press buttons, and high contrast ratios to ensure readability and ease of use for elderly users.] ,
  [NREQ-2],[10],[All user data must be completely private and not shared with any party unless the user gives explicit consent.] ,
  [NREQ-3],[10],[The core reminder functionality (notifications) must operate reliably even if the device is offline from the internet.] ,
  [NREQ-4],[10],[The application should be cross-platform, and working on major operating systems (Linux, Window, MacOS, iOS, Android, etc.).] , 
  [NREQ-5],[9],[Medication reminder notifications must be delivered at the scheduled time (with a tolerance of +/- 10 seconds).] ,
  [NREQ-6],[9],[The application must be open-source to allow for community contributions and auditing.] ,
  [NREQ-7],[6],[The application should launch (cold start) in under 3 seconds.] ,
)}
#pagebreak()
=== Stakeholders
In this project the medication tracking application for elderly users involves three primary stakeholder groups, each with distinct roles and responsibilities that ensure effective medication management and patient safety.
////////////////////////////////////////////////

- *Patients*:
Patients (Elderly Users) Elderly patients are the primary end-users who directly interact with the medication tracking system to manage their medication regimens. Their responsibilities include receiving and responding to medication reminders, logging when medications are taken, and maintaining adherence to prescribed schedules. Elderly patients benefit from features designed specifically for age-related challenges, including large fonts, high-contrast displays, simplified navigation, voice notifications, and customizable alerts. They can track their medication history, view organized medication lists, and receive refill reminders to ensure continuity of care. Common challenges elderly patients face include forgetfulness, cognitive decline, difficulty understanding complex medication schedules, and physical limitations, which the application must address through intuitive design

//////////////////////////////////////
- *Caregiver*:
Caregivers Caregivers play a critical support role in organizing medication schedules, managing prescription refills, and monitoring adherence for elderly patients. They require shared access to medication schedules, real-time progress tracking, and adherence notifications to monitor patient compliance and intervene when issues arise. Caregivers coordinate communication among patients, families, healthcare providers, and pharmacists to ensure seamless information exchange about medications. They assist with gathering medication-related information, creating medication lists and reminders, and organizing complex drug regimens. The application should provide caregivers with remote monitoring capabilities, missed dose notifications, and the ability to share adherence data with healthcare providers. Research shows that caregiver involvement significantly improves medication adherence, with female caregivers and first-degree relatives showing particularly positive impacts.
//////////////////////
#pagebreak()
- *System Admin*:
System Administrators System administrators are responsible for maintaining the technical infrastructure, security, and operational stability of the medication tracking application. Their core responsibilities include managing IT infrastructure including servers, networks, and security systems, ensuring system availability, reliability, and performance. They must ensure compliance with healthcare regulations and data security standards, including HIPAA and other privacy requirements. System administrators perform regular system updates, backups, and maintenance, monitor system performance and troubleshoot issues, and maintain user access administration and permissions. They conduct regular security audits to identify vulnerabilities, review system logs, and report malicious or suspicious activity. Additional responsibilities include managing user accounts for patients and caregivers, ensuring data protection and secure data environments, providing technical support for all system users, and documenting system configurations and creating technical documentation.

== Use Cases

#context {
  set text(size: 11pt)
  table(columns: 4,
  align: center + horizon, 
  table.header[*ID*][*Use case*][*Requirement*][*Actor*],

  [UC-1],[Register user profile],[FREQ-1],[Patients, Caregivers],
 
  [UC-2],[Login to system],[FREQ-2],[Patients, Caregivers],
  
  [UC-3],[Logout from system],[FREQ-2],[Patients, Caregivers],

  [UC-4],[Reset password/security questions],[FREQ-2],[Patients, Caregivers],
 
  [UC-5],[Add medication],[FREQ-3],[ Caregivers],
  
  [UC-6],[Delete medication],[FREQ-3],[Caregivers],

  [UC-7],[Set dosage instructions],	[FREQ-3],[ Caregivers],
  
  [UC-8],[Set medication schedule],[FREQ-4],[ Caregivers],

  [UC-9],[Receive medication reminder],[FREQ-5],[Patients],

  [UC-10],[Set up backup reminders],[FREQ-5],[Caregivers],

  [UC-11],[Confirm medication taken],[FREQ-6],[Patients, Caregivers],

  [UC-12],[Manage multiple user profiles],[FREQ-7],[Caregivers],

  [UC-13],[	Receive missed dose alerts],[FREQ-8],[Patients, Caregivers],

  [UC-14],[Configure notification settings],[FREQ-9],[Patients, Caregivers],

  [UC-15],[Set custom alert tones],[FREQ-9],[Patients, Caregivers],

  [UC-16],[Refill reminder notification],[FREQ-11],[Patients, Caregivers],

  [UC-17],[Set medication refill date],[FREQ-11],[Caregivers],

  [UC-18],[Track side effects],[FREQ-12],[Patients, Caregivers],
 
  [UC-19],[Log vital signs],[FREQ-12],[Patients, Caregivers],
 
  [UC-20],[View medication history],[FREQ-13],[Patients, Caregivers],
  
  [UC-21],[Calculate adherence rate],[FREQ-13],[Patients, Caregivers],
 
  [UC-22],[Monitor patient adherence],[FREQ-13],[Caregivers],

  [UC-23],[Generate adherence report],[FREQ-14],[Patients ],

  [UC-24],[Share report with doctor],[FREQ-14],[Patients, Caregivers],

  [UC-25],[Scan medication barcode],[FREQ-15],[Caregivers],
 
  [UC-26],[	Record medication photos],[FREQ-15],[Patients, Caregivers],
  
  [UC-27],[View medication information],[FREQ-16],[Patients, Caregivers],
    
  [UC-28],[Adjust font size/contrast],[FREQ-18],[ Caregivers],
  
  [UC-29],[Enable multi-language support],[FREQ-18],[Patients, Caregivers],
 
  
)
}

#pagebreak()
== Use Case Descriptions
#context {
  set text(size: 11pt)
  figure(
  table(columns: 2,
  align: left + horizon,
  table.header[*Use Case*][UC-1 : Register user profile],
[*Related Requirements*],[FREQ-1],
[*Participating Actors*],[Patients, Caregivers],
[*Brief Description*],[The user registers their personal details to create a new account in the system.],
[*Relationships*],[],
[*Preconditions*],[User not registered],
[*Normal Flow*],[1. User provides personal info.
2.System stores data.],
[*Alternative Flow*],[1. User enters invalid info.

2.System prompts correction.],
[*Postconditions*],[User profile created.],
),
caption: [Register user profile]
)
}

#context {
  set text(size: 11pt)
  figure(
  table(columns: 2,
  align: left + horizon, 
  table.header[*Use Case*][UC-2 : Login to system],
[*Related Requirements*],[FREQ-2],
[*Participating Actors*],[Patients, Caregivers],
[*Brief Description*],[The user logs into the system using their registered credentials to access their account.],
[*Relationships*],[],
[*Preconditions*],[User registered],
[*Normal Flow*],[1. User enters credentials.
2.System validates and logs in.],
[*Alternative Flow*],[1.Invalid credentials.

2.User retries.],
[*Postconditions*],[User logged in.],

),
caption: [Login to system]
)
}


///////////////////////////////////////
#pagebreak()
#context {
  set text(size: 11pt)
  figure(
  table(columns: 2,
  align: left + horizon, 
  table.header[*Use Case*][UC-11 : Confirm medication taken],
[*Related Requirements* ],[FREQ-6],
[*Participating Actors* ],[Patients, Caregivers],
[*Brief Description* ],[The user confirms that they have taken the medication at the scheduled time set by the system.],
[*Relationships*],[],
[*Preconditions*],[Medication schedule exists],
[*Normal Flow*],[1. User confirms medication.

2. System logs confirmation.
],
[*Alternative Flow*],[1.User fails to confirm.

2.System sends reminder.],
[*Postconditions*],[Medication confirmed.],


),
caption: [Confirm medication taken]
)
}
#pagebreak()
///////////////////////////////////////
#context {
  set text(size: 11pt)
  figure(
  table(columns: 2,
  align: left + horizon, 
  table.header[*Use Case*][UC-9 :  Receive medication reminder],
[*Related Requirements* ],[FREQ-5],
[*Participating Actors* ],[Patients],
[*Brief Description* ],[The system sends a reminder to the user about taking the medication at the scheduled time.],
[*Relationships*],[],
[*Preconditions*],[Medication schedule exists],
[*Normal Flow*],[System sends reminder at scheduled time.],
[*Alternative Flow*],[User ignores reminder.

System sends follow-up.],
[*Postconditions*],[Reminder sent.],


),
caption: [Receive medication reminder]
)
}
///////////////////////////////////////
#context {
  set text(size: 11pt)
  figure(
  table(columns: 2,
  align: left + horizon, 
  table.header[*Use Case*][UC-9: View medication history],
[*Related Requirements*],[FREQ-13],
[*Participating Actors*],[Patients, Caregivers],
[*Brief Description*],[The user views the history of medications that have been taken.],
[*Relationships*],[],
[*Preconditions*],[User logged in],
[*Normal Flow*],[1. User requests medication history.
2.System displays history.],
[*Alternative Flow*],[1.No history available.

2.System displays a message.],
[*Postconditions*],[Medication history displayed.],


),
caption: [View medication history]
  )
}
#pagebreak()
///////////////////////////////////////
#figure(
  
  table(columns: 2,
  align: left + horizon, 
  table.header[*Use Case*][UC-21: Track adherence rate],
[*Related Requirements* ],[FREQ-15],
[*Participating Actors* ],[Patients, Caregivers],
[*Brief Description*],[The system calculates and displays the user’s adherence rate to their medication schedule.],
[*Relationships*],[],
[*Preconditions*],[Medication taken],
[*Normal Flow*],[1.System calculates 
adherence

2.Displays adherence 
.rate],
[*Alternative Flow*],[.No data available
System prompts user to input medication details],
[*Postconditions*],[Adherence rate displayed],

  
),
caption: [Track adherence rate]
)
///////////////////////////////////////
#figure(
  table(columns: 2,
  align: left + horizon, 
  table.header[*Use Case*][UC-16 : Configure notification settings],
[*Related Requirements* ],[FREQ-9],
[*Participating Actors* ],[Patients, Caregivers],
[*Brief Description* ],[The user configures how they want to receive medication reminders and notifications.],
[*Relationships*],[],
[*Preconditions*],[User logged in],
[*Normal Flow*],[1.User selects 
notification preferences

2.System saves settings],
[*Alternative Flow*],[User cancels settings
System retains previous
settings],
[*Postconditions*],[Settings .configured],

  
),
caption: [Configure notification settings]
)
///////////////////////////////////////

#figure(
    table(columns: 2,
  align: left + horizon, 
  table.header[*Use Case*][UC-26 : Record medication photos],
[*Related Requirements* ],[FREQ-15],
[*Participating Actors* ],[Patients, Caregivers],
[*Brief Description* ],[The user takes photos of the medication to document the medication being taken.],
[*Relationships*],[],
[*Preconditions*],[Medication
scheduled],
[*Normal Flow*],[1.User takes a photo of 
the medication ,
2. System stores the ],
[*Alternative Flow*],[User doesn't take photo
System prompts for
photo],
[*Postconditions*],[Photo recorded],
 
),
  caption: [Record medication photos]  
  )

#set page(
  flipped: true,
)


#figure(
  image("figures/use-case-diagram.svg", width: 100%),
  caption: [Use Case Diagram],
)

#set page(
  flipped: false,
)

 

///////////////////////////////////////




== Sequence Diagrams
Sequence diagrams provide a detailed view of how system components interact over time to accomplish specific tasks within the application. Unlike use cases that describe what the system does, sequence diagrams illustrate the precise order of messages and operations exchanged between actors, user interface components, business logic, and the database layer. These diagrams clarify the dynamic behavior of critical workflows such as adding medications, triggering reminders, and managing caregiver access, helping identify potential bottlenecks and ensuring all necessary interactions are accounted for during implementation. The following diagrams represent the key scenarios identified in the use cases, offering a technical blueprint for developers to understand the temporal flow and dependencies within the system.

#figure(
  image("seq_diagrams/login.png"),
  caption: [Sequence Diagram of Login]
)

#figure(
  image("seq_diagrams/add_medication.png"),
  caption: [Sequence Diagram of adding medication]
)

#figure(
  image("seq_diagrams/confirm.png"),
  caption: [Sequence Diagram of confirmation of taking the medication]
)

#figure(
  image("seq_diagrams/reminder.png"),
  caption: [Sequence Diagram of reminder evet to take the medication]
)

#figure(
  image("seq_diagrams/missed.png"),
  caption: [Sequence Diagram of missing a dosage]
)

#figure(
  image("seq_diagrams/report.png"),
  caption: [Sequence Diagram of generating report]
)
