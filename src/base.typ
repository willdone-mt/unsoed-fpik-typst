/* ======================================================================= */
/* HELPERS (top-level, so content.typ can import them too)                 */
/* ======================================================================= */

// Sequence-element marker. NOTE: `[a b].func()` is `text`, NOT `sequence`,
// so it must be built by concatenation.
#let _seq = ([] + []).func()

/* sci-upper -------------------------------------------------------------
   Uppercases a title but leaves italic runs alone, so binomial names stay
   lowercase-correct:  #sci-upper[budidaya #emph[Thunnus albacares]]
   -> BUDIDAYA Thunnus albacares
   This replaces the commented-out `title-sci` regex attempt, which could
   not work: a regex show rule receives a text element whose `style` field
   is `auto` in markup, never "italic".                                    */
#let sci-upper(it) = {
  if it == none { return none }
  if type(it) == str { return upper(it) }
  let f = it.func()
  if f == text {
    if it.at("style", default: auto) in ("italic", "oblique") { it } else { upper(it.text) }
  } else if f == emph {
    it
  } else if f == _seq {
    it.children.map(sci-upper).join()
  } else if f == strong {
    strong(sci-upper(it.body))
  } else if it.has("body") {
    f(sci-upper(it.body))
  } else {
    it
  }
}

/* people-block ----------------------------------------------------------
   Accepts either:
     ("Ani Haryati, S.I.K., M.Si.", "Hendrayana, S.Kel., M.Si.")   -> centered lines
     ((nama: "Salma Munadhiva", nim: "L1C022038"), ...)            -> Nama | NIM table
   Mixed arrays work; rows without a NIM leave the second column blank.    */
#let _name-of(e) = {
  if type(e) == dictionary { e.at("nama", default: e.at("name", default: [])) } else { e }
}
#let _nim-of(e) = {
  if type(e) == dictionary { e.at("nim", default: none) } else { none }
}

#let people-block(entries, width: 11cm, row-gutter: 0.65em) = {
  if entries == none or entries.len() == 0 { return }
  let tabular = entries.any(e => _nim-of(e) != none)
  if entries.len() == 1 and _nim-of(entries.at(0)) != none {
    _name-of(entries.at(0))
    linebreak()
    _nim-of(entries.at(0))
  } else if tabular {
    block(width: width, grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      row-gutter: row-gutter,
      align: (left, left),
      ..entries.map(e => (_name-of(e), _nim-of(e))).flatten().map(x => if x == none [] else [#x]),
    ))
  } else {
    entries.map(e => [#_name-of(e)]).join(linebreak())
  }
}

/* tabel ----------------------------------------------------------------
   Wrapper for wide/long tables. Shrinks type and cell padding so fr columns
   actually fit the text block, then wraps in a figure so it gets "Tabel N."
   Long tables flow across pages and table.header() repeats automatically.

     #tabel(
       caption: [Ringkasan region BGC],   // MUST be [ ], not " "
       columns: (auto, 1.8fr, 1fr, 2.2fr, 1.5fr),
       align: (center + horizon, left + horizon, ..),
       table.header([*Region*], ..),
       [Region 1], ..
     )                                                                    */
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
  supplement: auto,
)

/* ======================================================================= */
/* TEMPLATE                                                                */
/* ======================================================================= */

#let _default-logo = image("logo-unsoed.png")

#let manuscript(
  /* --- cover: title block ------------------------------------------- */
  cover: true,
  pre-title: none,          // "Modul Praktikum Oseanografi Kimia"
  doc-title: none,          // "Teknik Sampling : Pengukuran dan Pengambilan Sampel"
  subtitle: none,           // optional extra line, not bold
  logo: _default-logo,
  logo-width: 2.5cm,
  title-width: 12cm,        // measure the title wraps in; keeps it off the margins

  /* --- cover: people ------------------------------------------------- */
  author-label: [Oleh:],
  authors: (),
  supervisor-label: none,   // e.g. [Asisten:] or [Dosen Pembimbing:]
  supervisors: (),
  people-width: 10cm,

  /* --- cover: institution footer ------------------------------------- */
  program-studi: none,      // "Ilmu Kelautan"   -> "PROGRAM STUDI ILMU KELAUTAN"
  fakultas: none,           // "Perikanan dan Ilmu Kelautan" -> "FAKULTAS ..."
  univ: none,               // full string, printed as-is (uppercased)
  place: none,              // "Purwokerto" — omitted on the FPIK example cover
  date: auto,               // auto = datetime.today()
  year: auto,               // auto = derived from `date`

  /* --- cover: geometry ----------------------------------------------- */
  cover-balanced-margins: false, // ignore the 3,5 cm binding margin on the cover
  gap-title-logo: 4em,
  gap-logo-subtitle: 2em,
  gap-subtitle-authors: 4em,
  gap-authors-supervisors: 2em,

  body,
) = {

/* ====================================================================== */
/* SETUP                                                                  */
/* ====================================================================== */

/* Code Setup ----------------------------------------------------------- */

// NOTE: these were `import` (no #) *inside* the function body, which scopes
// them to the template only — content.typ could never see them — and they
// were unused. Uncomment at TOP LEVEL (above this #let) if you need them.
// #import "@preview/cmarker:0.1.8"
// #import "@preview/callisto:0.2.5"
// #import "@preview/mitex:0.2.6": mitex

/* Document metadata ---------------------------------------------------- */

let _date = if date == auto { datetime.today() } else { date }
let _year = if year == auto {
  if _date == none { none } else { str(_date.year()) }
} else { str(year) }

set document(
  title: if doc-title == none { "" } else { doc-title },
  author: authors.map(_name-of).filter(n => type(n) == str),
  ..(if _date == none { (:) } else { (date: _date) }),
)

/* Document Formatting -------------------------------------------------- */

// @note batas kiri 3,5 cm  -> binding margin
set page(
  paper: "a4",
  margin: (left: 3.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
)
set text(font: "Book Antiqua", size: 12pt)
set text(lang: "id") // Instantly changes 'section' references to 'Bagian'
set bibliography(style: "fpik_adapted_apa.csl")

/* Title Formatting ----------------------------------------------------- */

// 1. Set text style and alignment
show title: set align(center)
show title: set text(size: 14pt, weight: "bold")

// 2. Set spacing around the title block
show title: set block(
  above: 2em,   // Space pushing the title down from the top margin or logo
  below: 3em    // Space pushing the body text or abstract down away from the title
)

// 3. Set leading between lines (if the title wraps into multiple lines)
show title: set par(leading: 0.5em)

// Master uppercase rule — now italic-safe via sci-upper, handles 'auto'
show title: it => {
  let final-content = if it.body == auto { document.title } else { it.body }
  block(sci-upper(final-content))
}

/* General Body Text Formatting ----------------------------------------- */

set par(
    // KUNCI UTAMA: Menggunakan dictionary (amount, all: true)
    // Ini memaksa indentasi pada SETIAP paragraf pertama di mana pun.
    first-line-indent: (amount: 1cm, all: true),
    justify: true,
    leading: 2em,
    spacing: 2em
)

set enum(indent: 1cm, spacing: 1.5em)
show enum: it => { set par(leading: 1.5em); it }

set list(indent: 1cm, spacing: 1.5em)
show list: it => { set par(leading: 1.5em); it }

/* Style Heading (Disederhanakan, Tanpa Hack Manual) -------------------- */

// 1. MASTER HEADING CONFIGURATION

set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 { none } else { n.map(str).join(".") }
})

// Strip the default native bold from ALL headings first
show heading: set text(weight: "regular")
// Headings must never inherit the 1cm body first-line indent
show heading: set par(first-line-indent: 0pt)

// 2. DYNAMIC HEADING TEMPLATE ENGINE

show heading: it => {
    if it.level == 1 { // --- HEADING 1 (BAB) ---
        pagebreak(weak: true)
        set align(center)

        let title-content = if it.numbering != none {
            let bab_num = numbering("I", counter(heading).at(it.location()).first())
            sci-upper([#bab_num. #it.body])
        } else {
            sci-upper(it.body)
        }

        // Force bold explicitly inside the text element
        block(text(size: 14pt, weight: "bold", title-content))
        v(2em)

    } else { // --- HEADING 2, 3, AND BELOW ---
        v(1em)

        let heading-weight = if it.level == 2 { "bold" } else { "regular" }

        set par(leading: 1em)

        if it.numbering != none {
            // Numbered heading -> Use strict 1cm layout alignment columns
            grid(
                columns: (1cm, 1fr),
                gutter: 0pt,
                text(size: 12pt, weight: heading-weight,
                     numbering(it.numbering, ..counter(heading).at(it.location()))),
                text(size: 12pt, weight: heading-weight, it.body)
            )
        } else {
            // Unnumbered heading -> Flush against left margin, no indent
            block(width: 100%, text(size: 12pt, weight: heading-weight, it.body))
        }
        v(1em)
    }
}

show <nonumber> : set heading(numbering: none)
// use <nonumber> to make heading not numbered!

/* Daftar-daftar Isi ---------------------------------------------------- */

// Un-commented and made valid: inside a code block the leading `#` must go.
set outline(indent: 0em)
show outline.entry.where(level: 1): it => strong(upper(it))
show outline: set block(spacing: 1em)
show outline: set par(leading: 1em, first-line-indent: 0pt)

/* Visual Style Figure -------------------------------------------------- */

// Single source of truth for captions. The old file had a `show figure:`
// rebuild PLUS a global `show figure.caption.where(kind: image)` rule; the
// two fought each other, and the table branch emitted the literal string
// "cap.supplement". `set text(lang: "id")` already gives "Gambar"/"Tabel"
// through `it.supplement`, so no manual prefix table is needed.
show figure.caption: it => {
  set par(leading: 0.65em, justify: true, first-line-indent: 0pt)
  strong(it.supplement)
  [ ]
  strong(context it.counter.display(it.numbering))
  [. ]
  it.body
}

show figure: set block(spacing: 2em, breakable: true)  // long tables may span pages
show figure: set par(leading: 1em, first-line-indent: 0pt)

// Tabel: caption di ATAS (konvensi ilmiah), gambar: caption di bawah
show figure.where(kind: table): set figure.caption(position: top)

/* TABLES --------------------------------------------------------------- */

// header / hline / content
set table(
    stroke: (x, y) => {
        if y == 0 { (bottom: 1.5pt) } // Header bottom line
        else { (x: 0pt, y: 0pt) }     // All standard interior grid lines
    },
    column-gutter: 5pt,
    inset: 1em,
)
// Outer top/bottom rules. MUST be `breakable: true`, otherwise a table taller
// than one page is clipped instead of flowing. `width: 100%` is required when
// the table uses fr columns: inside an auto-width block, fr resolves against
// infinite space and the columns overflow the right margin.
show table: it => {
    let cols = it.at("columns", default: auto)
    let has-fr = type(cols) == array and cols.any(c => type(c) == fraction)
    block(
        width: if has-fr { 100% } else { auto },
        breakable: true,
        stroke: (top: 1.5pt, bottom: 1.5pt),
        radius: 0pt,
        it,
    )
}
show table.cell: set par(leading: 1em, first-line-indent: 0pt)
show table.cell: set text(size: 11pt)

/* Daftar Pustaka ------------------------------------------------------- */

show bibliography: set par(leading: 1em, first-line-indent: 0pt, spacing: 2em)

/* ====================================================================== */
/* AUTOFIX ABBREVIATION                                                   */
/* ====================================================================== */

show "yg": "yang"

/* ====================================================================== */
/* COVER                                                                  */
/* ====================================================================== */

if cover {
  page(
    margin: if cover-balanced-margins {
      (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    } else {
      (left: 3.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    },
    numbering: none,
    header: none,
    footer: none,
    {
      set align(center)
      set par(leading: 0.65em, spacing: 0.65em, first-line-indent: 0pt, justify: false)

      // --- title block ---
      block(width: title-width, {
        if pre-title != none {
          text(size: 12pt, weight: "bold", sci-upper(pre-title))
          v(4em)
        }
        if doc-title != none {
          text(size: 14pt, weight: "bold", sci-upper(doc-title))
        }
      })

      // --- logo ---
      if logo != none {
        v(gap-title-logo)
        box(width: logo-width, logo)
      }

      // --- subtitle ---
      if subtitle != none {
        v(gap-logo-subtitle)
        text(size: 12pt, weight: "regular", subtitle)
      }

      // --- people ---
      if authors.len() > 0 {
        v(if logo != none { gap-subtitle-authors } else { gap-title-logo })
        text(weight: "bold", {
          if author-label != none { author-label; linebreak() }
          people-block(authors, width: people-width)
        })
      }
      if supervisors.len() > 0 {
        v(gap-authors-supervisors)
        if supervisor-label != none { supervisor-label; linebreak() }
        people-block(supervisors, width: people-width)
      }

      // --- institution footer, pinned to the bottom margin ---
      v(1fr)
      text(weight: "bold", {
        let lines = ()
        if program-studi != none { lines.push(upper[Program Studi #program-studi]) }
        if fakultas != none { lines.push(upper[Fakultas #fakultas]) }
        if univ != none { lines.push(upper[#univ]) }
        if place != none { lines.push(upper[#place]) }
        if _year != none { lines.push([#_year]) }
        lines.join(linebreak())
      })
    },
  )
}

  body
}
