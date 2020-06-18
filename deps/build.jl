# download the country codes data
const CSV_URL = "https://datahub.io/core/country-codes/r/country-codes.csv"
const CSV_PATH = joinpath(@__DIR__, "country-codes.csv")
if isfile(CSV_PATH)
    @info "Country data already exists at $(repr(CSV_PATH))"
else
    @info "Downloading country data from $(repr(CSV_URL)) to $(repr(CSV_PATH))"
    Base.download(CSV_URL, CSV_PATH)
end
