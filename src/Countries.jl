module Countries

using DelimitedFiles

export Country

# download the country codes data
global const CSV_URL = "https://datahub.io/core/country-codes/r/country-codes.csv"
global const CSV_PATH = joinpath(@__DIR__, "..", "country-codes.csv")
isfile(CSV_PATH) || Base.download(CSV_URL, CSV_PATH)

# load in the data
global const DATAMATRIX = readdlm(CSV_PATH, ',', String)
global const DATADICT = Dict(Symbol(x[1]) => x[2:end] for x in eachcol(DATAMATRIX))
global const NUM_COUNTRIES = size(DATAMATRIX, 1) - 1

isnull(x::Integer) = iszero(x)
isnull(x::AbstractString) = isempty(x)
isnull(x::Symbol) = x == Symbol("")

function make_lookup(xs; aliases=x->(x,))
    ys = Dict{eltype(xs), Int}()
    for (i,x) in enumerate(xs)
        isnull(x) && continue
        for x2 in aliases(x)
            j = get(ys, x2, i)
            j == i || @error "clash" i j x x2
            ys[x2] = i
        end
    end
    ys
end

make_strings_lookup(xs) = make_lookup(xs, aliases=x->(x, lowercase(x), uppercase(x)))

function make_int_lookup(xs)
    ys = zeros(Int, maximum(xs))
    for (i,x) in enumerate(xs)
        isnull(x) && continue
        @assert ys[x] == 0
        ys[x] = i
    end
    ys
end

global const PROPERTIES = [
    (:iso3166_numeric, Symbol("ISO3166-1-numeric"), Int, Int, true, false),
    (:official_name_ar, Symbol("official_name_ar"), String, String, true, true),
    (:official_name_cn, Symbol("official_name_cn"), String, String, true, true),
    (:official_name_en, Symbol("official_name_en"), String, String, true, true),
    (:official_name_es, Symbol("official_name_es"), String, String, true, true),
    (:official_name_fr, Symbol("official_name_fr"), String, String, true, true),
    (:official_name_ru, Symbol("official_name_ru"), String, String, true, true),
    (:iso3166_alpha2, Symbol("ISO3166-1-Alpha-2"), String, Symbol, true, true),
    (:iso3166_alpha3, Symbol("ISO3166-1-Alpha-3"), String, Symbol, true, true),
    (:unterm_arabic_formal, Symbol("UNTERM Arabic Formal"), String, String, true, true),
    (:unterm_arabic_short, Symbol("UNTERM Arabic Short"), String, String, true, true),
    (:unterm_chinese_formal, Symbol("UNTERM Chinese Formal"), String, String, true, true),
    (:unterm_chinese_short, Symbol("UNTERM Chinese Short"), String, String, true, true),
    (:unterm_english_formal, Symbol("UNTERM English Formal"), String, String, true, true),
    (:unterm_english_short, Symbol("UNTERM English Short"), String, String, true, true),
    (:unterm_french_formal, Symbol("UNTERM French Formal"), String, String, true, true),
    (:unterm_french_short, Symbol("UNTERM French Short"), String, String, true, true),
    (:unterm_russian_formal, Symbol("UNTERM Russian Formal"), String, String, true, true),
    (:unterm_russian_short, Symbol("UNTERM Russian Short"), String, String, true, true),
    (:unterm_spanish_formal, Symbol("UNTERM Spanish Formal"), String, String, true, true),
    (:unterm_spanish_short, Symbol("UNTERM Spanish Short"), String, String, true, true),
    (:cldr_display_name, Symbol("CLDR display name"), String, String, true, true),
    (:tld_name, Symbol("TLD"), String, String, false, false),
    (:wmo_name, Symbol("WMO"), String, String, false, false),
    (:fips_name, Symbol("FIPS"), String, String, false, false),
    (:fifa_name, Symbol("FIFA"), String, String, true, false),
    (:ioc_name, Symbol("IOC"), String, String, true, false),
    (:continent_name, Symbol("Continent"), String, String, false, false),
    (:capital_name, Symbol("Capital"), String, String, false, false),
]

"""
    Country(x)

Convert `x` to a country.

The argument may be the official name, the UN short or formal name, or the ISO3166 numeric or alphabetic code names.

Countries have many properties which can be accessed like `c.property`. See `propertynames(c)` for a list of them.

The same properties can be accessed via functions `property(c)`. In this case, `c` can be anything convertible to a country. Additionally the return type of textual properties can be specified as `property(String, c)` or `property(Symbol, c)`.
"""
struct Country
    idx :: Int
    Base.@propagate_inbounds function Country(::Val{:index}, idx::Integer)
        @boundscheck checkbounds(OFFICIAL_NAME_EN_LIST, idx)
        new(convert(Int, idx))
    end
end

function country_from_lookup(lookup, x)
    isnull(x) && error("$(repr(x)) is not a valid country")
    idx = get(lookup, x, 0)
    idx == 0 && error("$(repr(x)) is not a valid country")
    @inbounds Country(Val(:index), idx)
end

global const PROPERTY_NAMES = tuple([x[1] for x in PROPERTIES]..., :iso3166_numeric)

Base.propertynames(x::Country, private::Bool=false) = private ? tuple(fieldnames(Country)..., PROPERTY_NAMES...) : PROPERTY_NAMES

_getproperty(x::Country, ::Val{i}) where {i} =
    getfield(x, i)

Base.getproperty(x::Country, i::Symbol) =
    _getproperty(x, Val(i))

global const STRING_LOOKUP = Dict{String, Int}()

for (name, col, type, otype, isunique, isglobal) in PROPERTIES
    uname = Symbol(uppercase(string(name)))
    listname = Symbol(uname, :_LIST)
    lookupname = Symbol(uname, :_LOOKUP)
    symlistname = Symbol(uname, :_SYMBOL_LIST)
    symlookupname = Symbol(uname, :_SYMBOL_LOOKUP)
    rawdata = DATADICT[col]
    if type === String
        data = rawdata
        @eval global const $listname = $data
        @eval global const $symlistname = Symbol.($listname)
        @eval $name(::Type{String}, x::Country) = @inbounds $listname[x.idx]
        @eval $name(::Type{Symbol}, x::Country) = @inbounds $symlistname[x.idx]
    elseif type === Int
        data = Int[isempty(x) ? 0 : parse(Int, x) for x in rawdata]
        @eval global const $listname = $data
        @eval $name(::Type{Int}, x::Country) = @inbounds $listname[x.idx]
    else
        error()
    end
    @eval $name(T::Type, x::Country) = throw(MethodError($name, (T,x)))
    @eval $name(T::Type, x) = $name(T, Country(x))
    @eval $name(x) = $name($otype, x)
    if isunique
        if type === String
            @eval global const $lookupname = make_strings_lookup($listname)
        else
            @eval global const $lookupname = make_lookup($listname)
        end
        isglobal && @eval merge!((a,b) -> a==b ? a : error("clash while merging lookups $(repr(a)) $(repr($name))"), STRING_LOOKUP, $lookupname)
        if type === String
            @eval Country(::Val{$(QuoteNode(name))}, x::AbstractString) = country_from_lookup($lookupname, x)
            @eval Country(::Val{$(QuoteNode(name))}, x::Symbol) = country_from_lookup($symlookupname, x)
        elseif type === Int
            @eval Country(::Val{$(QuoteNode(name))}, x::Integer) = country_from_lookup($symlookupname, x)
        end
    end
    @eval _getproperty(x::Country, ::Val{$(QuoteNode(name))}) = $name(x)
end

global const SYMBOL_LOOKUP = Dict{Symbol, Int}(Symbol(x) => y for (x,y) in STRING_LOOKUP)

Country(x::Country) = x
Country(x::AbstractString) = country_from_lookup(STRING_LOOKUP, x)
Country(x::Symbol) = country_from_lookup(SYMBOL_LOOKUP, x)
Country(x::Integer) = country_from_lookup(ISO3166_NUMERIC_LOOKUP, x)

global const ALL_COUNTRIES = Country[Country(x) for x in ISO3166_ALPHA2_LIST if !isnull(x)]

Base.print(io::IO, x::Country) = print(io, cldr_display_name(x))

Base.show(io::IO, x::Country) =
    if get(io, :typeinfo, Union{}) == typeof(x)
        print(io, iso3166_alpha3(x))
    else
        print(io, typeof(x), "(", repr(string(iso3166_alpha3(x))), ")")
    end

function Base.show(io::IO, ::MIME"text/plain", x::Country)
    show(io, x)
    print(io, ": ", official_name_en(x))
end

Base.isless(x::Country, y::Country) = isless(iso3166_alpha3(x), iso3166_alpha3(y))

end # module
