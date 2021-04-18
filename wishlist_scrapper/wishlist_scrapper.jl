using HTTP, Cascadia, Gumbo
using Dates, ProgressMeter, OrderedCollections, JSON

"URL of the wishlist. It has to be a public wishlist."
const URL = "YOUR_URL_HERE"
"Filename of the output .json file."
const FILENAME = "wishlist"

"""
    exportWishlist(
        URL::String; 
        <keyword arguments>,
    )::OrderedDict{String, Dict{String, Any}}

Crawls the Book Depository webpage for the books in the given wishlist.

All data fields, but the date, will be strings. The date is a Dates object.

The price is in the format "COIN\$NUMBER", where `COIN` is a denomination code and `NUMBER` 
is the price itself in the corresponding denomination and in the format used by the 
corresponding country. For example:

"US\$20.03" is 20 US dollars and 3 cents.
"ARS\$1.839,92" is 1893 Argentinian pesos and 92 cents.

# Arguments
- `URL::String`: URL of the public wishlist.
- `sort_key::Union{String, Nothing} = nothing`: Key by which the result will be sorted.
  If `nothing` there is no sorting, otherwise the options are:
  "isbn"
  "author"
  "price"
  "published"
  "title"

# Returns
- A dictionary which keys are the ISBN codes of each book, and which entries are 
  dictionaries with the available data for each book, i.e. author, ISBN, price, etc. 
  Missing data fields will be represented by `missing`.
"""
function exportWishlist(
    URL::String; 
    sort_key::Union{String, Nothing} = nothing,
)::OrderedDict{String, Dict{String, Any}}

    # Sort key correctness check,
    (
        sort_key ∈ [nothing, "isbn", "author", "price", "published", "title"] || 
        error("$sort_key is not one of the available sort keys.")
    )

    # Final dictionary to be filled with the data.
    wishlist = OrderedDict{String, Dict{String, Any}}()

    page = 1
    prog = ProgressUnknown("Processing page")
    generate_showvalues(l_wish) = () -> [("Books collected", l_wish)]

    while true

        url = URL * string(page)
        page_html = HTTP.request("GET", url)

        body = parsehtml(String(page_html.body))
        book_list = eachmatch(
            Selector(
                "body > div.page-slide > div.content-wrap > div > div.content-block" *
                " > div > div.block > div > div > div",
            ),
            body.root,
        )
        
        if length(book_list) == 0
            ProgressMeter.finish!(prog)
            break
        end

        for book in book_list
            book_dict = Dict{String, Any}()

            basic_data = eachmatch(Selector("meta"), book)
            date = eachmatch(Selector("div.item-info > p.published"), book)
            price = eachmatch(Selector("div.item-info > div.price-wrap > p.price"), book)

            # Saves the author, title and isbn of the book.
            for data in basic_data
                if data.attributes["itemprop"] == "contributor"
                    push!(book_dict, "author" => data.attributes["content"])
                else
                    push!(
                        book_dict, 
                        data.attributes["itemprop"] => data.attributes["content"],
                    )
                end
            end

            # Saves publishing date, if available.
            if isempty(date)
                push!(book_dict, "published" => missing)
            else
                push!(book_dict, "published" => Date(nodeText(first(date)), "dd u yyyy"))
            end
            
            # Saves the price, if available.
            if isempty(price)
                push!(book_dict, "price" => missing)
            else
                push!(
                    book_dict, 
                    "price" => first(split(strip(nodeText(first(price))), '\n')),
                )
            end

            # Stores the book in the wishlist dictionary.
            push!(wishlist, book_dict["isbn"] => book_dict)
        end

        ProgressMeter.next!(prog; showvalues = generate_showvalues(length(wishlist)))

        page += 1
    end

    if isnothing(sort_key)
        return wishlist
    else
        return sort(wishlist, byvalue = true, by = x -> x[sort_key])
    end
    
end

############################################################################################
# Usage.
############################################################################################

wishlist_dict = exportWishlist(URL, sort_key = "price")

open(FILENAME * ".json", "w") do io
    JSON.print(io, wishlist_dict, 4)
end
