
#set page(
  width: 80cm,
  height: 200cm,
  margin: (x: 0.8in, y: 0.8in),
  fill: white,
)

#set text(font: "TeX Gyre Pagella", size: 35pt)

#let enable-shadows = true

#import "@preview/shadowed:0.3.0": shadow

// ---- Style helpers --------------------------------------------------------

#let section-title(body) = block(
  width: 100%,
  inset:  15pt,
  stroke: (2pt + rgb("#80519e")),
  radius: 15pt,
)[
  #set text(size: 55pt, weight: "bold", fill: rgb("#80519e"))
  #align(center)[#body]
]

#let card-block(body) = block(
  width: 100%,
  fill: rgb("#fafafa"),
  stroke: 0.5pt + rgb("#d0d0d0"),
  inset: 14pt,
  radius: 15pt,
)[
  #set par(justify: true)
  #body
]

#let card(body) = if enable-shadows {
  shadow(
    dx: 0pt,
    dy: 4pt,
    blur: 22pt,
    fill: rgb(0, 0, 0, 40),
    radius: 15pt,
  )[#card-block(body)]
} else {
  card-block(body)
}

#let bullet-card(title, body) = card[
    *#title* #body
]

// ---- Header ---------------------------------------------------------------

#grid(
  columns: (1fr, 1fr, 1fr),
  align: (left + horizon, center + horizon, right + horizon),
  image("figuers/vision2030.svg", width: 15cm),
  image("figuers/logo.svg", width: 15cm),
  // Institutional text
  [
    #set text(size: 25pt, weight: "bold")
    #align(center, 
        [Kingdom of Saudi Arabia \
         Ministry of Education \
         Jouf University \
         College of Computer and Information Science \
         Department of Computer Science])
  ],
)

#v(12pt)

// ---- Title row ------------------------------------------------------------

#grid(
  columns: (1fr, 2.5fr, 1fr),
  align: (left + horizon, center + horizon, right + horizon),
  [
    #set text(size: 27pt)
    *Students Names:*
    - Ahmad Nasser Almekawed
    - Saud Ahmad Aldandn
    - Fahad Farhan Alshammari
    - Abdulaziz Mohammad Alrudhi
  ],
  [
      #set text(size: 70pt, weight: "bold", font: "TeX Gyre Pagella")
    *Medication Tracking Application \
    for Elderly Users*
  ],
  [
    #set text(size: 27pt)
    *Supervisor* \
    Dr. Nasser Alshammari
  ],
)

#v(20pt)

// ---- Body: three-column layout --------------------------------------------

#grid(
    columns: (1fr, 1.4fr, 1fr),
  column-gutter: 24pt,
  row-gutter: 20pt,

  // ============================== LEFT COLUMN ==============================
  [
    #section-title[Abstract]
    #card[
      Medication adherence remains a critical challenge in healthcare,
      particularly among elderly populations who often manage multiple
      chronic conditions requiring complex medication schedules. Research
      indicates that approximately 50% of elderly patients do not take their
      medications as prescribed, leading to adverse health outcomes,
      increased hospitalizations, and higher healthcare costs estimated at
      \$100-300 billion annually in the United States alone.

      This project develops a user-friendly medication tracking application designed specifically for elderly users and their caregivers. The application is cross-platform deployable as native desktop applications for Windows, macOS, and Linux, as well as a web application accessible through modern browsers.
    ]

    #v(1fr)
    #section-title[Features]
    #card[
      The system features comprehensive medication schedule management,
      intelligent reminder notifications, adherence tracking,
      caregiver monitoring capabilities, and secure local data storage. The
      interface emphasize accessibility with large fonts, high contrast
      ratios, simplified navigation, and large touch buttons suitable for
      elderly users with visual and motor impairments. Key functionalities
      include flexible medication scheduling supporting various intervals,
      quick medication entry, drug database
      integration, drug interaction warnings, medication quantity tracking
      with refill reminders, health measurement logging (blood pressure,
      glucose), and professional PDF report generation for healthcare
      provider consultations. The system supports multiple languages
      including Arabic and English with proper right-to-left (RTL) text
      support.
    ]

    #v(1fr)

    #section-title[Objectives]
    #card[
      *Improve Adherence:* Reduce missed doses through reliable, persistent
      reminders and simplified tracking.

      *Enhance Accessibility:* Implement large fonts, high contrast
      interfaces, and intuitive navigation for seniors.

      *Empower Caregivers:* Enable remote monitoring and instant missed
      dose alerts for peace of mind.

      *Privacy First:* Prioritize local data storage (SQLite) to ensure
      sensitive health data remains private.

      *Cross-Platform:* Native support for Windows, macOS, Linux, and Web
      from a single efficient codebase.
    ]

    #v(1fr)

    #section-title[System Architecture]
    #card[
      This project involves developing a user-friendly medication tracking
      application designed specifically for elderly users and their
      caregivers. The application will be built using Go programming
      language with the Wails framework to create cross-platform
      applications deployable as native desktop applications for Windows,
      macOS, and Linux, as well as a web application accessible through
      modern browsers. The technical architecture combines a high-performance
      Go backend for business logic and data management with a Svelte
      frontend built using modern web technologies (JavaScript, HTML, CSS),
      enabling dual deployment from a single codebase.
    ]

    #v(1fr)

    #section-title[Conclusion]
    #card[
      We designed and implemented a solution that bridges the gap between
      elderly patients and caregivers. By prioritizing privacy,
      accessibility, and maintaining a free cost model, we addressed some of the
      shortcomings of current solutions.
    ]

  ],

  // ============================ MIDDLE COLUMN ==============================
  [

    #section-title[Application Interface]
    #card[
      #align(center)[
        #image("figuers/screenshots/1.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/2.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/3.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/4.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/5.png", width: 100%)

        #v(12pt)
        #image("figuers/screenshots/9.png", width: 100%)
      ]
    ]

    #v(1fr)

    #section-title[Technologies]
    #let tool(img, name, w: 140%) = align(center)[
      #image(img, width: w, height: 4cm, fit: "contain")
      #v(6pt)
      *#name*
    ]
    #card[
      #grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 10pt,
        tool("figuers/go-logo.png", "Golang"),
        tool("figuers/wails.png", "Wails"),
        tool("figuers/svelte-logo.jpg", "Svelte"),
      )
      #v(18pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 12pt,
        tool("figuers/html.png", "HTML"),
        tool("figuers/css.svg", "CSS"),
        tool("figuers/js.png", "JavaScript"),
      )
    ]

  ],

  // ============================ RIGHT COLUMN ===============================
  [

    #section-title[Development Workflow]
    #card[
      #align(center)[
          #image("figuers/GitHub-Logo.svg", width: 100%)
        #image("figuers/screenshots/6.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/7.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/8.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/10.png", width: 100%)
        #v(12pt)
        #image("figuers/screenshots/11.png", width: 100%)
      ]
    ]

    #v(1fr)

    #section-title[Acknowledgments]
    #card[
      We express our respect and thanks for our supervisor for
      giving us the opportunity to achieve our Bachelor of Science Degree.

      We thank all the project committee members who have sacrificed their
      time in reviewing this work, and more largely, for the interest which
      they carried to this project documentation.

      We would like to say special thanks to all our families. Our very
      dear parents, nobody can compensate for their sacrifices, that they
      agreed for our education and for our good being.

      We also make a point of presenting our recognition and our thanks to
      any person who helped us in all our studies.
    ]

    #v(1fr)

    #section-title[References]
    #card[
      #set text(size: 13pt)
      #set par(leading: 0.55em)

      [1] R. L. Cutler, F. Fernandez-Llimos, M. Frommer, C. Benrimoj, and
      V. Garcia-Cardenas, "Economic impact of medication non-adherence by
      disease groups: a systematic review," _BMJ Open_, vol. 8, no. 1,
      p. e016982, 2018, doi: 10.1136/bmjopen-2017-016982.

      #v(4pt)
      [2] J. Jin, G. E. Sklar, V. Min Sen Oh, and S. Chuen Li, "Factors
      affecting therapeutic compliance: A review from the patient's
      perspective," _Therapeutics and Clinical Risk Management_, vol. 4,
      no. 1, pp. 269-286, 2008.

      #v(4pt)
      [3] L. Osterberg and T. Blaschke, "Adherence to medication," _New
      England Journal of Medicine_, vol. 353, no. 5, pp. 487-497, 2005,
      doi: 10.1056/NEJMra050100.

      #v(4pt)
      [4] A. O. Iuga and M. J. McGuire, "Adherence and health care costs,"
      _Risk Management and Healthcare Policy_, vol. 7, pp. 35-44, 2014,
      doi: 10.2147/RMHP.S19801.

      #v(4pt)
      [5] New England Healthcare Institute, "Thinking outside the pillbox:
      A system-wide approach to improving patient medication adherence for
      chronic disease," Cambridge, MA, Research Brief, 2009.

      #v(4pt)
      [6] M. Viswanathan et al., "Interventions to improve adherence to
      self-administered medications for chronic diseases in the United
      States: A systematic review," _Annals of Internal Medicine_, vol.
      157, no. 11, pp. 785-795, 2012, doi:
      10.7326/0003-4819-157-11-201212040-00538.

      #v(4pt)
      [7] P. J. McDonnell and M. R. Jacobs, "Hospital admissions resulting
      from preventable adverse drug reactions," _Annals of
      Pharmacotherapy_, vol. 36, no. 9, pp. 1331-1336, 2002, doi:
      10.1345/aph.1A333.

      #v(4pt)
      [8] A. F. Yap, T. Thirumoorthy, and Y. H. Kwan, "Medication
      adherence in the elderly," _Journal of Clinical Gerontology and
      Geriatrics_, vol. 7, no. 2, pp. 64-67, 2016, doi:
      10.1016/j.jcgg.2015.05.001.

      #v(4pt)
      [9] T. M. Ruppar, P. S. Cooper, D. R. Mehr, J. M. Delgado, and J. M.
      Dunbar-Jacob, "Medication adherence interventions improve heart
      failure mortality and readmission rates: Systematic review and
      meta-analysis of controlled trials," _Journal of the American Heart
      Association_, vol. 5, no. 6, p. e002606, 2016, doi:
      10.1161/JAHA.115.002606.

      #v(4pt)
      [10] N. Masnoon, S. Shakib, L. Kalisch-Ellett, and G. E. Caughey,
      "What is polypharmacy? A systematic review of definitions," _BMC
      Geriatrics_, vol. 17, no. 1, p. 230, 2017, doi:
      10.1186/s12877-017-0621-2.

      #v(4pt)
      [11] E. D. Kantor, C. D. Rehm, J. S. Haas, A. T. Chan, and E. L.
      Giovannucci, "Trends in prescription drug use among adults in the
      United States from 1999-2012," _JAMA_, vol. 314, no. 17,
      pp. 1818-1831, 2015, doi: 10.1001/jama.2015.13766.

      #v(4pt)
      [12] A. J. Claxton, J. Cramer, and C. Pierce, "A systematic review
      of the associations between dose regimens and medication compliance,"
      _Clinical Therapeutics_, vol. 23, no. 8, pp. 1296-1310, 2001, doi:
      10.1016/S0149-2918(01)80109-0.

      #v(4pt)
      [13] "Apple." [Online]. Available: https://www.apple.com/

      #v(4pt)
      [14] "MacRumors." [Online]. Available:
      https://www.macrumors.com/how-to/add-medication-health-app-ios/

      #v(4pt)
      [15] "medisafe." [Online]. Available: https://www.medisafe.com/

      #v(4pt)
      [16] The Go Authors, "The Go Programming Language." [Online].
      Available: https://go.dev/

      #v(4pt)
      [17] A. A. Donovan and B. W. Kernighan, _The Go Programming
      Language_. Addison-Wesley Professional, 2015.

      #v(4pt)
      [18] The Go Authors, "Effective Go: Concurrency." [Online].
      Available: https://go.dev/doc/effective_go\#concurrency

      #v(4pt)
      [19] L. Anthony and Wails Contributors, "Wails - Build Desktop
      Applications Using Go." [Online]. Available: https://wails.io/

      #v(4pt)
      [20] L. Anthony and Wails Contributors, "Wails v2 Documentation:
      Binding." [Online]. Available:
      https://wails.io/docs/reference/runtime/intro

      #v(4pt)
      [21] R. Harris and Svelte Contributors, "Svelte - Cybernetically
      Enhanced Web Apps." [Online]. Available: https://svelte.dev/

      #v(4pt)
      [22] R. Harris, "Rethinking reactivity," in _YGLF (You Gotta Love
      Frontend) Conference_, Vilnius, Lithuania, 2019.

      #v(4pt)
      [23] S. Chacon and B. Straub, _Pro Git_, 2nd ed. Apress, 2014.
      [Online]. Available: https://git-scm.com/book/en/v2

      #v(4pt)
      [24] GitHub, Inc., "GitHub: Where the World Builds Software."
      [Online]. Available: https://github.com/
    ]
  ],
)
