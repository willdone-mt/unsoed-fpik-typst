/* =========================================================================
   BASE TEMPLATE: FPIK UNSOED manuscript style

   What this file does:
     Sets up the whole look of the document: page size, margins, font,
     headings, tables, figures, bibliography, and the cover page.
     You write your content in another file; this file only controls
     how it looks.

   How to use it (at the top of your main file):

     #import "base.typ": *
     #show: manuscript.with(
       pre-title: [Modul Praktikum Oseanografi Kimia],
       doc-title: [Teknik Sampling],
       authors: ((nama: "Salma Munadhiva", nim: "L1C022038"),),
       program-studi: "Ilmu Kelautan",
       fakultas: "Perikanan dan Ilmu Kelautan",
       univ: "Universitas Jenderal Soedirman",
     )

     = Pendahuluan
     Your text here...

   The file has two parts:
     1. HELPERS:  small tools you can also use inside your own content.
     2. TEMPLATE: the `manuscript` function that styles the whole document.
   ========================================================================= */


/* Optional packages. Remove the `//` in front of a line to enable it.
   They must stay up here, outside `manuscript`, so your content file
   can use them too. */
// #import "@preview/cmarker:0.1.8"
// #import "@preview/callisto:0.2.5"
// #import "@preview/mitex:0.2.6": mitex


/* =========================================================================
   PART 1: SETTINGS
   Shared values used in several places. Change them here once,
   instead of hunting through the file.
   ========================================================================= */

#let _default-logo = image("logo-unsoed.png")   // cover logo
#let _default-csl  = "fpik_adapted_apa.csl"     // citation style file

/* Page margins. Left is wider (3.5 cm) to leave room for binding.
   `_margin-balanced` is the same margin on both sides, for an
   optional symmetric cover. */
#let _margin          = (left: 3.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)
#let _margin-balanced = (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)

#let _indent = 1.5cm   // first-line paragraph indent, list indent, heading number width


/* =========================================================================
   PART 2: HELPERS
   Small tools. They can also be imported by your content file.
   ========================================================================= */

/* Internal tool (you don't need to touch this).
   Lets the code recognise "a piece of text made of several parts".
   It must be built this way; the obvious-looking shortcut gives the
   wrong result. */
#import "utils/lib.typ": *


/* people-block: prints a list of people (authors, supervisors).

   Two ways to give the names:

     Names only -> one centred name per line
       ("Ani Haryati, S.I.K., M.Si.", "Hendrayana, S.Kel., M.Si.")

     Names with student ID (NIM) -> two columns: Nama | NIM
       ((nama: "Salma Munadhiva", nim: "L1C022038"), ...)

   You can mix both; people without a NIM get an empty NIM column.
   A single person with a NIM is printed as name, then NIM below it. */

// Read the name from an entry ("nama" or "name"; plain text works too).
#let _name-of(e) = {
    if type(e) == dictionary { e.at("nama", default: e.at("name", default: [])) } else { e }
}

// Read the NIM from an entry. Returns nothing if there isn't one.
#let _nim-of(e) = {
    if type(e) == dictionary { e.at("nim", default: none) } else { none }
}

#let people-block(entries, width: 11cm, row-gutter: 0.65em) = {
    if entries == none or entries.len() == 0 { return }

    let has-nim = entries.any(e => _nim-of(e) != none)

    if entries.len() == 1 and has-nim {
        // One person: name, then NIM on the next line.
        _name-of(entries.first())
        linebreak()
        _nim-of(entries.first())
    } else if has-nim {
        // Several people with NIMs: two-column table.
        block(width: width, grid(
            columns: (1fr, auto),
            column-gutter: 1em,
            row-gutter: row-gutter,
            align: left,
            ..entries
                .map(e => (_name-of(e), _nim-of(e)))
                .flatten()
                .map(x => if x == none [] else [#x]),
        ))
    } else {
        // Names only: one per line.
        entries.map(e => [#_name-of(e)]).join(linebreak())
    }
}


/* tabel: a table with a numbered caption ("Tabel 1. ...").

   Use it for wide or long tables. It uses slightly smaller text and
   tighter cells so the columns fit the page. Long tables continue onto
   the next page, and the header row repeats automatically.

     #tabel(
       caption: [Ringkasan region BGC],        // use [ ], not " "
       columns: (auto, 1.8fr, 1fr, 2.2fr, 1.5fr),
       align: (center + horizon, left + horizon, ..),
       table.header([*Region*], ..),
       [Region 1], ..
     )

   Options:
     size        text size inside the table
     cell-inset  space around the text in each cell
     gutter      gap between columns
   Everything else is passed on to a normal Typst `table`. */
#let tabel(
    caption: none,
    size: 9pt,
    cell-inset: (x: 0.45em, y: 0.5em),
    gutter: 0pt,
    ..args
) = figure(
    {
        set text(size: size)
        set table(inset: cell-inset, column-gutter: gutter)
        table(..args)
    },
    caption: caption,
    kind: table,
)


/* =========================================================================
   PART 3: TEMPLATE
   `manuscript` styles the whole document. Every option below has a
   default, so you only fill in the ones you need.
   ========================================================================= */

#let manuscript(
    /* Cover: title ------------------------------------------------------- */
    cover: true,               // false = no cover page
    pre-title: none,           // small line above the title, e.g. "Modul Praktikum ..."
    doc-title: none,           // main title (also saved as the PDF title)
    subtitle: none,            // extra line under the logo, not bold
    logo: _default-logo,       // none = no logo
    logo-width: 2.5cm,
    title-width: 12cm,         // max width of the title before it wraps

    /* Cover: people ------------------------------------------------------ */
    author-label: [Oleh:],     // text above the author names
    authors: (),               // see `people-block` above for the format
    supervisor-label: none,    // e.g. [Asisten:] or [Dosen Pembimbing:]
    supervisors: (),
    people-width: 10cm,        // width of the Nama | NIM table

    /* Cover: institution (bottom of the page, printed in CAPITALS) ------- */
    program-studi: none,       // "Ilmu Kelautan" -> PROGRAM STUDI ILMU KELAUTAN
    fakultas: none,            // "Perikanan dan Ilmu Kelautan" -> FAKULTAS ...
    univ: none,                // full university name
    place: none,               // city, e.g. "Purwokerto" (optional)
    date: auto,                // auto = today
    year: auto,                // auto = the year from `date`

    /* Cover: spacing ----------------------------------------------------- */
    cover-balanced-margins: false, // true = equal left/right margins on the cover only
    gap-title-logo: 4em,
    gap-logo-subtitle: 2em,
    gap-subtitle-authors: 4em,
    gap-authors-supervisors: 2em,

    body,                      // your content (filled in automatically by #show)
) = {

/* ---------------------------------------------------------------------
    DOCUMENT INFO
    Works out the date and year, and saves title/author/date in the
    PDF properties.
    --------------------------------------------------------------------- */

let _date = if date == auto { datetime.today() } else { date }
let _year = if year != auto { str(year) } else if _date != none { str(_date.year()) } else { none }

set document(
    ..(if doc-title != none { (title: doc-title) }),
    author: authors.map(_name-of).filter(n => type(n) == str),  // plain-text names only
    ..(if _date != none { (date: _date) }),
)


/* ---------------------------------------------------------------------
    PAGE AND TEXT
    A4 paper, Book Antiqua 12 pt, Indonesian language. The language
    setting makes Typst write "Gambar", "Tabel", "Bagian", etc.
    --------------------------------------------------------------------- */

set page(paper: "a4", margin: _margin)

/* If Book Antiqua isn't installed, the next similar font in the list
    is used, so the document still compiles. */
set text(
    font: ("Book Antiqua", "Palatino Linotype", "TeX Gyre Pagella"),
    size: 12pt,
    lang: "id",
)




/* ---------------------------------------------------------------------
    PARAGRAPHS AND LISTS
    Justified text, double spacing, and a 1 cm indent on the first line
    of every paragraph (including the first one after a heading).
    Lists are indented 1 cm with slightly tighter line spacing.
    --------------------------------------------------------------------- */

set par(
    first-line-indent: (amount: _indent, all: true),
    justify: true,
    leading: 2em,    // space between lines inside a paragraph
    spacing: 2em,    // space between paragraphs
)

set enum(indent: _indent, spacing: 1.5em)   // numbered lists (1. 2. 3.)
set list(indent: _indent, spacing: 1.5em)   // bullet lists
show enum: set par(leading: 1.5em)
show list: set par(leading: 1.5em)


/* ---------------------------------------------------------------------
    HEADINGS

    Level 1  (= Pendahuluan)     -> new page, centred, bold, 14 pt, CAPITALS
                                    with a Roman numeral: "I. PENDAHULUAN"
    Level 2  (== Latar Belakang) -> bold,    "1.1  Latar Belakang"
    Level 3+ (=== ...)           -> regular, "1.1.1  ..."

    To remove the number from one heading, add <nonumber> after it:
        = Daftar Pustaka <nonumber>
    --------------------------------------------------------------------- */

/* Numbering rule: level 1 gets no number here (its Roman numeral is
    added below); deeper levels get "1.1.", "1.1.1.", and so on. */
set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 { none } else { n.map(str).join(".") + "." }
})

show <nonumber>: set heading(numbering: none)

// Headings never get the 1 cm first-line indent.
show heading: set par(first-line-indent: 0pt)

show heading: it => {
    let num = counter(heading).at(it.location())   // e.g. (1, 2) for heading 1.2

    if it.level == 1 {
        // Level 1: chapter title
        pagebreak(weak: true)   // start on a new page (no blank page if already at the top)
        set align(center)
        set par(leading: 0.5em)

        let title = if it.numbering != none {
            title-upper([#numbering("I", num.first()). #it.body])
        } else {
            title-upper(it.body)
        }
        block(text(size: 14pt, weight: "bold", title))
        v(2em)

    } else {
        // Level 2 and deeper: section titles
        let weight = if it.level == 2 { "bold" } else { "regular" }
        set text(size: 12pt, weight: weight)
        set par(leading: 1em)

        v(1em)
        if it.numbering != none {
            // Number in a fixed 1 cm column, so all titles line up.
            grid(
                columns: (_indent, 1fr),
                numbering(it.numbering, ..num),
                it.body,
            )
        } else {
            block(width: 100%, it.body)
        }
        v(1em)
    }
}


/* ---------------------------------------------------------------------
    TABLE OF CONTENTS  (#outline())
    No indent. Chapter entries are bold and in CAPITALS, but scientific
    names in italics keep their normal case (same rule as the headings).
    --------------------------------------------------------------------- */

set outline(indent: 0em)

/* Rebuilds a chapter entry piece by piece so only the title text is
    capitalised: the entry still links to its page, keeps the dotted
    line, and shows the page number. */
show outline.entry.where(level: 1): it => strong(link(
    it.element.location(),
    it.indented(it.prefix(), {
        title-upper(it.body())
        [ ]
        box(width: 1fr, it.fill)
        sym.wj                // keeps the page number on the same line
        it.page()
    }),
))
show outline: set block(spacing: 1em)
show outline: set par(leading: 1em, first-line-indent: 0pt)


/* ---------------------------------------------------------------------
    FIGURES AND CAPTIONS

    Captions look like:  Gambar 1. Caption text
                        Tabel 1. Caption text
    ("Gambar 1" / "Tabel 1" in bold)

    Images: caption BELOW.  Tables: caption ABOVE (scientific convention).
    --------------------------------------------------------------------- */

set figure(supplement: [Gambar])
show figure.where(kind: table): set figure(supplement: [Tabel])
show figure.where(kind: table): set figure.caption(position: top)

show figure.caption: it => {
    set par(leading: 0.65em, justify: true, first-line-indent: 0pt)
    strong(it.supplement)
    [ ]
    strong(context it.counter.display(it.numbering))
    [. ]
    it.body
}

show figure: set block(spacing: 2em, breakable: true)   // long tables may continue on the next page
show figure: set par(leading: 1em, first-line-indent: 0pt)


/* ---------------------------------------------------------------------
    TABLES
    Scientific "three-line" style:
        a thick line on top, a thick line under the header row,
        and a thick line at the bottom. No other lines.
    --------------------------------------------------------------------- */

set table(
    stroke: (x, y) => if y == 0 { (bottom: 1.5pt) },   // line under the header row only
    column-gutter: 5pt,
    inset: 1em,
)

/* Top and bottom lines, drawn around the whole table.
    - breakable: lets a long table continue on the next page
        instead of being cut off.
    - width 100%: needed when columns use "fr" widths, otherwise
        the table runs past the right margin. */
show table: it => {
    let cols = it.at("columns", default: auto)
    let has-fr = type(cols) == array and cols.any(c => type(c) == fraction)
    block(
        width: if has-fr { 100% } else { auto },
        breakable: true,
        stroke: (top: 1.5pt, bottom: 1.5pt),
        it,
    )
}

// Text inside table cells: 11 pt, tighter lines, no indent.
show table.cell: set text(size: 11pt)
show table.cell: set par(leading: 0.5em, first-line-indent: 0pt)


/* ---------------------------------------------------------------------
    BIBLIOGRAPHY  (Daftar Pustaka)
    No first-line indent; space between entries.
    --------------------------------------------------------------------- */

set bibliography(style: _default-csl)

show bibliography: set par(
    leading: 1em, 
    first-line-indent: 0pt, 
    spacing: 2em
)


/* ---------------------------------------------------------------------
    AUTO-EXPAND ABBREVIATIONS
    Replaces common chat shorthand in the final PDF:
        yg -> yang,  dgn -> dengan,  utk -> untuk
    Only whole words are replaced, so words that merely contain
    these letters are left alone.
    --------------------------------------------------------------------- */

show regex("\\byg\\b"): "yang"
show regex("\\bdgn\\b"): "dengan"
show regex("\\butk\\b"): "untuk"


/* ---------------------------------------------------------------------
    COVER PAGE
    From top to bottom:
        pre-title, title, logo, subtitle, authors, supervisors,
        and the institution block at the bottom of the page.
    Anything left as `none` or empty is skipped.
    --------------------------------------------------------------------- */

if cover {
    page(
        margin: if cover-balanced-margins { _margin-balanced } else { _margin },
        numbering: none,
        header: none,
        footer: none,
        {
            set align(center)
            set par(leading: 0.65em, spacing: 0.65em, first-line-indent: 0pt, justify: false)

            // Title block
            block(width: title-width, {
                if pre-title != none {
                    text(size: 12pt, weight: "bold", title-upper(pre-title))
                    v(4em)
                }
                if doc-title != none {
                    text(size: 14pt, weight: "bold", title-upper(doc-title))
                }
            })

            // Logo
            if logo != none {
                v(gap-title-logo)
                box(width: logo-width, logo)
            }

            // Subtitle
            if subtitle != none {
                v(gap-logo-subtitle)
                text(size: 12pt, subtitle)
            }

            // Authors (bold)
            if authors.len() > 0 {
                v(if logo != none { gap-subtitle-authors } else { gap-title-logo })
                text(weight: "bold", {
                    if author-label != none { author-label; linebreak() }
                    people-block(authors, width: people-width)
                })
            }

            // Supervisors (regular)
            if supervisors.len() > 0 {
                v(gap-authors-supervisors)
                if supervisor-label != none { supervisor-label; linebreak() }
                people-block(supervisors, width: people-width)
            }

            // Institution block, pushed to the bottom of the page.
            v(1fr)
            text(weight: "bold", {
                let lines = ()
                if program-studi != none { lines.push(upper[Program Studi #program-studi]) }
                if fakultas != none      { lines.push(upper[Fakultas #fakultas]) }
                if univ != none          { lines.push(upper[#univ]) }
                if place != none         { lines.push(upper[#place]) }
                if _year != none         { lines.push([#_year]) }
                lines.join(linebreak())
            })
        },
    )
}

body
}
