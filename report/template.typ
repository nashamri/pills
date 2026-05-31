#let project(
  title: "",
  subtitle: "",
  authors: (),
  supervisor: "",
  college: "",
  degree: "",
  date: none,
  logo: none,
  body,
) = {
  // Set document metadata
  set document(author: authors.map(a => a.name), title: title)
  
  // Set page formatting
  set page(
    margin: (left: 30mm, right: 30mm, top: 30mm, bottom: 30mm),
    numbering: "1",
    number-align: center,
  )
  
  // Set text formatting
  set text(font: "Libre Baskerville", lang: "en", size: 12pt)
  set par(justify: true, leading: 0.65em)
  
  // Set heading formatting
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(size: 18pt, weight: "bold")
    block(above: 2em, below: 1.5em, it)
  }
  
  show heading.where(level: 2): it => {
    set text(size: 14pt, weight: "bold")
    block(above: 1.5em, below: 1em, it)
  }
  
  show heading.where(level: 3): it => {
    set text(size: 12pt, weight: "bold")
    block(above: 1em, below: 0.75em, it)
  }
  
  // Title page
  set page(numbering: none)
  align(center)[
    // #v(1fr)
    
    #if logo != none {
      image(logo, width: 20%)
      v(1em)
    }
    
    #v(0.5em)
    #text(size: 14pt)[#college]
    
    #v(3em)
    #text(size: 22pt, weight: "bold")[#title]
    
    #if subtitle != "" {
      v(1em)
      text(size: 16pt)[#subtitle]
    }
    
    #v(3em)
    
    #text(size: 14pt, weight: "bold")[PROJECT SUPERVISOR]
    
    #v(0.5em)
    #text(size: 12pt)[#supervisor]
    
    #v(2em)
    
    #text(size: 14pt, weight: "bold")[GROUP MEMBERS]
    
    #v(0.5em)
    #for author in authors [
      #text(size: 12pt)[#author.name]
      
      #v(0.3em)
    ]
    
    #v(2em)
    
    #text(size: 11pt)[
      In fulfillment of the requirements for the degree of
      
      #degree, in the #college, Jouf University.
    ]
    
    #v(2em)
    
    #text(size: 14pt, weight: "bold")[
      #if date != none {
        date
      } else {
        datetime.today().year()
      }
    ]
    
    #v(1fr)
  ]
  
  pagebreak()
  
  // Set page numbering to Roman numerals for front matter
  set page(numbering: "i")
  counter(page).update(1)
  
  body
}
// Template for acknowledgment page
#let acknowledgment(body) = {
  pagebreak()
  
  align(center)[
    #heading(outlined: false, numbering: none)[ACKNOWLEDGMENT]
  ]
  v(3em)
  set par(
    leading: 1em,
    spacing: 2em,
    first-line-indent:(amount: 2em, all: true)
  )
  body
}

// Template for declaration page
#let declaration(body) = {
  pagebreak()
  align(center)[
    #heading(outlined: false, numbering: none)[DECLARATION]
  ]
  v(3em)
  set par(
    leading: 1em,
    spacing: 2em,
    first-line-indent:(amount: 2em, all: true)
  )
  body
}

// Template for certification page
#let certification(body) = {
  pagebreak()
  align(center)[
    #heading(outlined: false, numbering: none)[CERTIFICATION]
  ]
  v(3em)
  set par(
    leading: 1em,
    spacing: 2em,
    first-line-indent:(amount: 2em, all: true)
  )
  body
}

// Template for abstract page
#let abstract_page(body) = {
  pagebreak()
  align(center)[
    #heading(outlined: false, numbering: none)[ABSTRACT]
  ]
  v(3em)
  set par(
    leading: 1em,
    spacing: 2em,
    first-line-indent:(amount: 2em, all: true)
  )
  body
}

// Start main content with Arabic numerals
#let main_content(body) = {
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  body
}
