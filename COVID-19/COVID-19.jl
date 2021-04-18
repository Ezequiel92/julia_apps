using Plotly, HTTP, CSV, DataFrames, Dates

"Data source."
const SOURCE = "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/jhu/"

"File names for the different data types."
const FILE = Dict(
    "Number of new cases" => "new_cases.csv",
    "Number of new cases per million" => "new_cases_per_million.csv",
    "Number of new deaths" => "new_deaths.csv",
    "Number of new deaths per million" => "new_deaths_per_million.csv",
    "Total number of cases" => "total_cases.csv",
    "Total number of cases per million" => "total_cases_per_million.csv",
    "Total number of deaths" => "total_deaths.csv",
    "Total number of deaths per million" => "total_deaths_per_million.csv",
)

"""
    function smoothTimeSeries(
        data::Vector{Float64},
        dates::Vector{Dates.Date}; 
        <keyword arguments>
    )::Tuple{Vector{Dates.Date}, Vector{Float64}}

Smooth `data` with a moving window of width `width`.

# Arguments
- `data::Vector{Float64}`: y axis data to be smoothed.
- `dates::Vector{Dates.Date}`: x axis data.
- `width::Int64 = 3`: Width of the moving window.

# Returns
- Tuple with two Arrays, the first is the x-axis data smooth out, and the second is the 
  y-axis data trim down to have the same length as the x-axis data.
"""
function smoothTimeSeries(
    data::Vector{Float64},
    dates::Vector{Dates.Date};
    width::Int64 = 3,
)::Tuple{Vector{Dates.Date}, Vector{Float64}}

    window_range = 1:width:(length(data) - width + 1)

    new_x = [dates[i + round(Int64, width / 2)] for i in window_range]
    new_y = [round(sum(data[i:(i + width - 1)]) / width) for i in window_range]

    return new_x, new_y
end

"""
    function covid19Plot(country::String, data_type::String; <keyword arguments>)::Nothing

Produce a Plotly bar plot with a time series of `data_type` for a given `country`.

# Arguments
- `country::String`: Country for which the data will be plotted. The name has to be in 
  English and the first letter must be uppercase. For a list of available location see
  https://github.com/owid/covid-19-data/blob/master/public/data/jhu/locations.csv.
- `data_type::String`: Type of data to be plotted. Available types are:
  "Number of new cases"
  "Number of new cases per million"
  "Number of new deaths"
  "Number of new deaths per million"
  "Total number of cases"
  "Total number of cases per million"
  "Total number of deaths"
  "Total number of deaths per million"
- `width::Int64 = 1`: Width of the moving window used to smooth out the data.
- `file_name::String = "COVID-19"`: Name of the output HTML file.

# Examples
```julia-repl
julia> covid19Plot("Argentina", "Number of new cases", width = 3)

julia> covid19Plot("Australia", "Total number of deaths per million", width = 7)

```
"""
function covid19Plot(
    country::String, 
    data_type::String; 
    width::Int64 = 1,
    file_name::String = "COVID-19",
)::Nothing

    # Get raw data from OWID.
    raw_dataframe = CSV.File(HTTP.get(SOURCE * FILE[data_type]).body) |> DataFrame

    # Data availability check.
    (
        country in names(raw_dataframe) ||
        error("Country '$country' was not found in the database.
              Refer to https://github.com/owid/covid-19-data/blob/master/public/data/jhu/locations.csv")
    )

    # Smooth the data with a moving window of width `width`.
    x, y = smoothTimeSeries(
        coalesce.(raw_dataframe[!, country], 0.0),
        raw_dataframe.date;
        width,
    )

    # Prepare the plot.
    data = bar(; x, y)
    layout = Layout(
        title = "$data_type in $country",
        titlefont_size = 28,
        xaxis = attr(
            title = "Date",
            titlefont_size = 24,
            tickfont_size = 18,
            automargin = true,
        ),
        yaxis = attr(
            title = "$data_type",
            titlefont_size = 24,
            tickfont_size = 18,
            automargin = true,
        ),
        marker = attr(color = "rgb(60, 100, 150)", opacity = 0.6),
        line = attr(color = "rgb(25, 25, 25)", width = 1.5),
    )

    # Plot the data.
    savefig(plot(data, layout), file_name * ".html")

    return nothing
end

############################################################################################
# Usage.
############################################################################################

covid19Plot("Argentina", "Number of new cases", width = 7, file_name = "COVID-19")
