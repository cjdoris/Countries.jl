module ISO_3166_1

import ..Common

struct Country
    code::Int16
    Common.construct(::Type{Country}, code::Int16) = new(code)
end

Common.code_type(::Type{Country}) = Common.Alpha2()
Common.lookup_length(::Type{Country}) = 4
Common.database(::Type{Country}) = DB

const DB = Common.Database{Country}(fields=(alpha2=String, alpha3=String, name=String, numeric=Int16, official_name=String, common_name=String))

Country(x::Country) = x
Country(x::AbstractString) = Common.lookup(Country, x)

country_alpha3(x) = Common.get_field(:alpha3, Country(x), "")

country_alpha2(x) = Common.get_field(:alpha2, Country(x), "")

country_name(x) = Common.get_field(:name, Country(x), "")

country_official_name(x) = Common.get_field(:official_name, Country(x), "")

country_common_name(x) = Common.get_field(:common_name, Country(x), "")

country_numeric(x) = Common.get_field(:numeric, Country(x), zero(Int16))

country_assigned(x) = Common.assigned(Country(x))

function new_country(; alpha2, alpha3="", name="", numeric=0, official_name="", common_name="")
    # validate the inputs
    alpha3 = isempty(alpha3) ? "" : Common.validate_code(Common.Alpha3(), alpha3)
    alpha2 = Common.validate_code(Common.Alpha2(), alpha2)
    name = convert(String, name)
    official_name = convert(String, official_name)
    common_name = convert(String, common_name)
    numeric = convert(Int16, numeric)
    if !(0 ≤ numeric ≤ 999)
        error("numeric must be between 0 and 999")
    end
    if isempty(official_name)
        official_name = name
    end
    if isempty(common_name)
        common_name = name
    end
    country = Country(alpha2)
    # add the new fields
    Common.new_entry(country; alpha2, alpha3, name, numeric, common_name, official_name)
end

const DATA_PATH = joinpath(Common.DATA_ROOT, "iso_3166-1.tsv")

let
    for line in readlines(DATA_PATH)
        row = split(line, '\t')
        alpha2 = row[1]
        alpha3 = row[2]
        name = row[3]
        official_name = row[6]
        common_name = row[7]
        numeric = parse(Int16, row[4])
        new_country(; alpha3, alpha2, name, numeric, official_name, common_name)
    end
end

# """
#     alias_country(alias, country)

# Register an alias for the given country so that `Country(alias)` returns `country`.

# Example:
# ```julia-repl
# julia> alias_country("England", "GBR")

# julia> Country("england")
# GB: United Kingdom of Great Britain and Northern Ireland
# ```
# """
# function alias_country(name, country)
#     name = convert(String, name)
#     uname = uppercase(name)
#     country = Country(country)
#     if length(name) < 4
#         error("alias=$(repr(name)) too short, must have length at least 4")
#     end
#     if haskey(LOOKUP, uname)
#         if LOOKUP[uname] != country
#             error("alias=$(repr(name)) already used by country=$(Country(name))")
#         end
#         return
#     end
#     LOOKUP[uname] = country
#     empty!(LOOKUP_CACHE)
#     return
# end

# ### precompile

# for country in Any["GB", "GBR", "United Kingdom", 826, Country("GB"), Country("ZZ")]
#     Country(country)
#     country_alpha2(country)
#     country_alpha3(country)
#     country_assigned(country)
#     country_name(country)
#     country_numeric(country)
# end
# for country in ["GB", "gb", "Gb", "FOO", "foo", "Foo", "FOOO", "fooo", "Fooo"]
#     try
#         Country(country)
#     catch
#     end
# end
# collect(each_country())
# empty!(AMBIG)

end
