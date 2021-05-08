using HTTP, Cascadia, Gumbo
using Dates, ProgressMeter, OrderedCollections, JSON

"""
    parse_price(price_number::AbstractString)::Union{Missing, Float64}

Parse a string representing a price as a floating point number.

It smartly considers the position of the ',' and '.' to infer the 
convention for thousands and cents.

# Arguments
- `price_number::AbstractString`: The price to be parsed.

# Returns
- The price as a floating point number.

# Examples
```julia-repl
julia> parse_price("1.789,56")
1789.56

julia> parse_price("8,536.96")
8536.96

julia> parse_price("42.69")
42.69

julia> parse_price("5.698")
5698.0

julia> parse_price("42,88")
42.88

julia> parse_price("1,256")
1256.0
```
"""
function parse_price(price_number::AbstractString)::Union{Missing, Float64}

    dot_bool = occursin('.', price_number)
    comma_bool = occursin(',', price_number)

    if comma_bool && dot_bool
        first = price_number[findfirst(r"[.,]", price_number)]
        if first == ","
            return parse(Float64, replace(price_number, ',' => "")) 
        elseif first == "."
            return parse(
                Float64, 
                replace(
                    replace(price_number, '.' => ""), 
                    ',' => ".", 
                    count = 1,
                ),
            ) 
        else
            println("Could't parse: ", number_st)
            return missing
        end
    elseif dot_bool || comma_bool
        cents = rsplit(price_number, ['.', ',']; limit = 2)[2]
        if length(cents) > 2
            return parse(Float64, replace(price_number, r"[.,]" => "")) 
        end
        return parse(Float64, replace(price_number, ',' => "."))
    else
        return parse(Float64, price_number)
    end

end

"""
    export_wishlist(
        URL::String; 
        <keyword arguments>,
    )::Union{Nothing, OrderedDict{String, Dict{String, Any}}}

Crawls a Book Depository public wishlist, saving its books in a JSON.

All data fields, except the date and price, will be strings. The date is a Dates object and 
the price is a Float64.

# Arguments
- `URL::String`: URL of the public wishlist.
- `sort_key::Union{String, Nothing} = nothing`: Key by which the result will be sorted.
  If `nothing` there is no sorting, otherwise the options are:
  "isbn": Standard numerical order (lower first) even though this field is a string.
  "author": Standard alphabetical order.
  "price": Standard numerical order (lower first), with missings together at the end. 
  "published": Older first.
  "title": Standard alphabetical order.

# Returns
- A dictionary which keys are the ISBN codes of each book, and which entries are 
  dictionaries with the available data for each book, i.e. author, ISBN, price, etc. 
  Missing data fields will be represented by `missing`.
  Return `nothing` if no books were detected.
"""
function export_wishlist(
    URL::String; 
    sort_key::Union{String, Nothing} = nothing,
)::Union{OrderedDict{String, Dict{String, Any}}, Nothing}

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

        url = URL * "?page=" * string(page)
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
                push!(book_dict, "coin" => missing)
            else
                price_str = first(split(strip(nodeText(first(price))), '\n'))
                price_number = match(r"\d*[.,]\d*([.,]\d*)?", price_str).match
                value = parse_price(price_number)
                push!(book_dict, "price" => value)
                push!(book_dict, "coin" => replace(price_str, price_number => ""))
            end

            # Stores the book in the wishlist dictionary.
            push!(wishlist, book_dict["isbn"] => book_dict)
        end

        ProgressMeter.next!(prog; showvalues = generate_showvalues(length(wishlist)))

        page += 1
    end

    if length(wishlist) == 0
        println("I couldn't detect any books! Check the url.")
        return nothing
    else
        println("\nFinished processing $(length(wishlist)) books!")
    end

    if isnothing(sort_key)
        return wishlist
    else
        return sort(wishlist, byvalue = true, by = x -> x[sort_key])
    end
    
end

############################################################################################
# Usage
############################################################################################

"URL of the wishlist. It has to be a public wishlist."
const URL = "https://www.bookdepository.com/wishlists/XXXXXXX"

"Filename of the output .json file."
const FILENAME = "wishlist"

wishlist_dict = export_wishlist(URL, sort_key = "price")

if wishlist_dict !== nothing

    # Create output path if it doesn't exist
    folderpath = mkpath(joinpath(@__DIR__, "../output"))
    filepath = joinpath(folderpath, FILENAME * ".json")

    open(filepath, "w") do io
        JSON.print(io, wishlist_dict, 4)
    end

end
