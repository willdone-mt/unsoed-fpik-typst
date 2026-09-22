#import "utils.typ": *

/* binomen: marks a scientific (binomial) name.

     #binomen[Thunnus albacares]

   It looks exactly like normal italics, but it tells `title-upper`
   "this is a scientific name, keep its case". Use it for species
   names; use #emph[...] for other italic words (foreign terms, etc.). */
#let binomen(body) = [#emph(body)<binomen>]


/* title-upper: UPPERCASE a title, but keep scientific names as they are.

    #title-upper[budidaya #binomen[Thunnus albacares] sistem #emph[recirculating]]
    -> BUDIDAYA Thunnus albacares SISTEM RECIRCULATING

   Scientific names (#binomen) keep their normal case, as the naming
   convention requires. Other italic words (#emph) are uppercased
   like the rest of the title and stay italic.

   It walks through the title piece by piece and uppercases each one,
   skipping anything marked as a binomen. */
#let title-upper(it) = {
    if it == none { return none }
    if type(it) == str { return upper(it) }

    let f = it.func()
    if it.at("label", default: none) == <binomen> {
        it                                          // scientific name: leave as is
    } else if f == text {
        upper(it.text)                              // plain text: uppercase
    } else if f == _seq {
        it.children.map(title-upper).join()           // several pieces: handle each one
    } else if it.has("body") {
        f(title-upper(it.body))                       // bold, italic, etc.: keep the style, fix the inside
    } else {
        it                                          // anything else: leave as is
    }
}