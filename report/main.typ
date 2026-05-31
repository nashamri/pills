#import "template.typ": *

#let title = "Medication Tracking Application for Elderly Users"
#let supervisor = "Dr. Nasser Alshammari"
#let authors = ((name: "Ahmad Nasser Almekawed"),
    (name: "Saud Ahmad Aldandn"),
    (name: "Fahad Farhan Alshammari"),
    (name: "Abdulaziz Mohammad Alrudhi"))
#let degree = "Bachelor of Computer Science"

#show: project.with(
  title: title,
  authors: authors,
  supervisor: supervisor,
  college: "College of Computer and Information Sciences",
  degree: degree,
  date: "2025",
  logo: "logo.png",
)

#acknowledgment[
  We express our respect and  sharp thanks for the honor of:
Our supervisor for giving us the opportunity
to achieve our Bachelor of Science Degree.

We thank all the project committee  members who have sacrificed their time in reviewing this work, and  more largely, for the interest which they carried to this project documentation.

We could like to say special thanks to all our families. Our very dear parents, nobody can compensate for their sacrifices, that they agreed for our education and for our good being.

We also make a point of presenting our recognition and our thanks to any person who helped us in all our studies
]

#declaration[
We hereby declare that this software, neither as a whole nor as a part has been copied out from any source. It is further declared that we have developed this software and accompanied report entirely on the basis of our personal efforts. If any part of this project is proved to be copied out from any source or found to be reproduction of some other. We will stand by the consequences. No portion of the work presented has been submitted in support of any application for any other degree or qualification of this or any other university or institute of learning. 
]

#certification[
It is certified that the contents and form of the project entitled *#title* submitted by #authors.map(a => [*#a.name*]).slice(0, -1).join(", ") and #authors.map(a => [*#a.name*]).last() has been found satisfactory for the requirements.

#v(3em)


#align(center)[
for the award of the degree of

#text(size: 14pt)[ *#degree* ]

]

#v(5em)
*Supervisor*: #supervisor

*Committee Member 1*: ............................................................

*Committee Member 2*: ............................................................

*Date*: .............................................

]

#abstract_page[
Medication adherence remains a critical challenge in healthcare, particularly among elderly populations who often manage multiple chronic conditions requiring complex medication schedules. Research indicates that approximately 50% of elderly patients do not take their medications as prescribed, leading to adverse health outcomes, increased hospitalizations, and higher healthcare costs estimated at \$100-300 billion annually in the United States alone. This non-adherence stems from various factors including forgetfulness, confusion about medication schedules, difficulty reading prescription labels, and lack of caregiver oversight. Current medication tracking applications fail to account for the specific needs of elderly users, such as larger interface elements, simplified navigation, and persistent reminder systems.

The system will feature comprehensive medication schedule management, intelligent reminder notifications, real-time adherence tracking, caregiver monitoring capabilities, and secure local data storage. The interface will emphasize accessibility with large fonts, high contrast ratios, simplified navigation, and large touch buttons suitable for elderly users with visual and motor impairments. Key functionalities include flexible medication scheduling supporting various intervals, barcode scanning for quick medication entry, drug database integration, drug interaction warnings, medication quantity tracking with refill reminders, health measurement logging (blood pressure, glucose), and professional PDF report generation for healthcare provider consultations. The system will support multiple languages including Arabic and English with proper right-to-left (RTL) text support.

This project involves developing a user-friendly medication tracking application designed specifically for elderly users and their caregivers. The application will be built using Go programming language with the Wails framework to create cross-platform applications deployable as native desktop applications for Windows, macOS, and Linux, as well as a web application accessible through modern browsers. The technical architecture combines a high-performance Go backend for business logic and data management with a Svelte frontend built using modern web technologies (JavaScript, HTML, CSS), enabling dual deployment from a single codebase while maintaining optimal performance and user experience across all platforms.

]

// Table of Contents
#pagebreak()
#outline(
  title: [TABLE OF CONTENTS],
  indent: auto,
)

// List of Figures
#pagebreak()
#outline(
  title: [LIST OF FIGURES],
  target: figure.where(kind: image),
)

// List of Tables
#pagebreak()
#outline(
  title: [LIST OF TABLES],
  target: figure.where(kind: table),
)


// #include "abbrvs.typ"

#main_content[

#set heading(numbering: "1.1")
#set page(
  header: context {
    // Check if there's a level 1 heading on the current page
    let page-headings = query(selector(heading.where(level: 1)).after(here()))
    
    // If there's a heading coming up on this page, don't show header
    if page-headings.len() > 0 and page-headings.first().location().page() == here().page() {
      return
    }
    
    let headings = query(selector(heading.where(level: 1)).before(here()))
    if headings.len() > 0 {
      let current = headings.last()
      grid(
        columns: (1fr, 1fr),
        align(left)[Chapter #counter(heading).at(current.location()).first(): #current.body],
      )
      v(-0.5em)
      line(length: 100%)
    }
  }
)

#include "chapter1.typ"
#include "chapter2.typ"
#include "chapter3.typ"
#include "chapter4.typ"
#include "chapter5.typ"
#include "refs.typ"

]
