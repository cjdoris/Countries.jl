module Countries

using DelimitedFiles

export Country

struct InvalidCountryError <: Exception
    value :: Any
    msg :: Any
end

InvalidCountryError(value) = InvalidCountryError(value, nothing)

function Base.showerror(io::IO, err::InvalidCountryError)
    print(io, "invalid country specification: ", repr(err.value))
    if err.msg !== nothing
        println(io)
        print(io, err.msg)
    end
end

invalidcountry(args...) = throw(InvalidCountryError(args...))

# download the country codes data
# TODO: use artifacts
const CSV_URL = "https://datahub.io/core/country-codes/r/country-codes.csv"
const CSV_PATH = joinpath(@__DIR__, "..", "country-codes.csv")
isfile(CSV_PATH) || Base.download(CSV_URL, CSV_PATH)

# load in the data
const DATAMATRIX = readdlm(CSV_PATH, ',', String)
const DATADICT = Dict(Symbol(x[1]) => x[2:end] for x in eachcol(DATAMATRIX))
const NUM_COUNTRIES = size(DATAMATRIX, 1) - 1

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
    (:unterm_formal_name_ar, Symbol("UNTERM Arabic Formal"), String, String, true, true),
    (:unterm_short_name_ar, Symbol("UNTERM Arabic Short"), String, String, true, true),
    (:unterm_formal_name_cn, Symbol("UNTERM Chinese Formal"), String, String, true, true),
    (:unterm_short_name_cn, Symbol("UNTERM Chinese Short"), String, String, true, true),
    (:unterm_formal_name_en, Symbol("UNTERM English Formal"), String, String, true, true),
    (:unterm_short_name_en, Symbol("UNTERM English Short"), String, String, true, true),
    (:unterm_formal_name_fr, Symbol("UNTERM French Formal"), String, String, true, true),
    (:unterm_short_name_fr, Symbol("UNTERM French Short"), String, String, true, true),
    (:unterm_formal_name_ru, Symbol("UNTERM Russian Formal"), String, String, true, true),
    (:unterm_short_name_ru, Symbol("UNTERM Russian Short"), String, String, true, true),
    (:unterm_formal_name_es, Symbol("UNTERM Spanish Formal"), String, String, true, true),
    (:unterm_short_name_es, Symbol("UNTERM Spanish Short"), String, String, true, true),
    (:cldr_name_en, Symbol("CLDR display name"), String, String, true, true),
    (:tld_name, Symbol("TLD"), String, String, false, false),
    (:wmo_code, Symbol("WMO"), String, Symbol, false, false),
    (:fips_code, Symbol("FIPS"), String, Symbol, false, false),
    (:fifa_code, Symbol("FIFA"), String, Symbol, true, false),
    (:ioc_code, Symbol("IOC"), String, Symbol, true, false),
    (:continent_code, Symbol("Continent"), String, Symbol, false, false),
    (:capital_name_en, Symbol("Capital"), String, String, false, false),
]

"""
    Country(x)

Convert `x` to a country.

The argument may be the official name, the UN short or formal name, or the ISO3166 numeric or alphabetic code names.

Countries have many properties which can be accessed like `c.property`. See `propertynames(c)` for a list of them.

The same properties can be accessed via functions `property(c)`. In this case, `c` can be anything convertible to a country. Additionally the return type of textual properties can be specified as `property(String, c)` or `property(Symbol, c)`.
"""
struct Country
    idx :: Int16
    Base.@propagate_inbounds function Country(::Val{:index}, idx::Integer)
        @boundscheck checkbounds(OFFICIAL_NAME_EN_LIST, idx)
        new(idx)
    end
end

function country_from_lookup(lookup, x)
    isnull(x) && invalidcountry(x)
    idx = get(lookup, x, 0)
    idx == 0 && invalidcountry(x)
    @inbounds Country(Val(:index), idx)
end

const PROPERTY_NAMES = tuple([x[1] for x in PROPERTIES]..., :iso3166_numeric)

Base.propertynames(x::Country, private::Bool=false) = private ? tuple(fieldnames(Country)..., PROPERTY_NAMES...) : PROPERTY_NAMES

_getproperty(x::Country, ::Val{i}) where {i} =
    getfield(x, i)

Base.getproperty(x::Country, i::Symbol) =
    _getproperty(x, Val(i))

const ORIG_STRING_LOOKUP = Dict{String, Int}()

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
        isglobal && @eval merge!((a,b) -> a==b ? a : error("clash while merging lookups $(repr(a)) $(repr($name))"), ORIG_STRING_LOOKUP, $lookupname)
        if type === String
            @eval Country(::Val{$(QuoteNode(name))}, x::AbstractString) = country_from_lookup($lookupname, x)
            @eval Country(::Val{$(QuoteNode(name))}, x::Symbol) = country_from_lookup($symlookupname, x)
        elseif type === Int
            @eval Country(::Val{$(QuoteNode(name))}, x::Integer) = country_from_lookup($symlookupname, x)
        end
    end
    @eval _getproperty(x::Country, ::Val{$(QuoteNode(name))}) = $name(x)
end


Country(x::Country) = x

const STRING_LOOKUP = copy(ORIG_STRING_LOOKUP)
const SYMBOL_LOOKUP = Dict{Symbol, Int}(Symbol(x) => y for (x,y) in STRING_LOOKUP)

"""
    add_alias(name, country::Country)

Adds `name` as a global alias for `country`, so that calling `Country(name)` returns `country`.

Consider raising an issue to fix this permanently: https://github.com/cjdoris/Countries.jl.
"""
function add_alias(x::AbstractString, c::Country)
    STRING_LOOKUP[x] = c.idx
    STRING_LOOKUP[lowercase(x)] = c.idx
    STRING_LOOKUP[uppercase(x)] = c.idx
    SYMBOL_LOOKUP[Symbol(x)] = c.idx
    SYMBOL_LOOKUP[Symbol(lowercase(x))] = c.idx
    SYMBOL_LOOKUP[Symbol(uppercase(x))] = c.idx
    return
end

add_alias(x::Symbol, c::Country) =
    add_alias(string(x), c)

"""
    add_to_blacklist(name)

Adds `name` to the blacklist of aliases, so that `Country(name)` always raises an error.

Consider raising an issue to fix this permanently: https://github.com/cjdoris/Countries.jl.
"""
function add_to_blacklist(x::AbstractString)
    STRING_LOOKUP[x] = -1
    STRING_LOOKUP[lowercase(x)] = -1
    STRING_LOOKUP[uppercase(x)] = -1
    SYMBOL_LOOKUP[Symbol(x)] = -1
    SYMBOL_LOOKUP[Symbol(lowercase(x))] = -1
    SYMBOL_LOOKUP[Symbol(uppercase(x))] = -1
    return
end

add_to_blacklist(x::Symbol) =
    add_to_blacklist(string(x))

function Country(x::AbstractString)
    isnull(x) && invalidcountry(x)

    # look up x
    idx = get(STRING_LOOKUP, x, 0)
    idx > 0 && @goto done
    idx < 0 && invalidcountry(x)

    # look up lowercase(x)
    idx = get(STRING_LOOKUP, lowercase(x), 0)
    idx > 0 && @goto keep
    idx < 0 && invalidcountry(x)

    # now search for a match
    idxs = Set{Int}()
    for (y,idx) in pairs(ORIG_STRING_LOOKUP)
        if idx > 0 && occursin(lowercase(x), lowercase(y))
            push!(idxs, idx)
        end
    end
    if length(idxs) == 1 && length(x) > 3
        idx = first(idxs)
        @warn "assuming $(repr(x)) is $(repr(Country(Val(:index), idx))); see `add_alias` or `add_to_blacklist`"
        @goto keep
    elseif isempty(idxs)
        invalidcountry(x)
    else
        invalidcountry(x, "maybe you meant one of $(sort(Country.(Val(:index), collect(idxs))))")
    end

    @label keep
    c = @inbounds Country(Val(:index), idx)
    add_alias(x, c)
    return c

    @label done
    return @inbounds Country(Val(:index), idx)
end

function Country(x::Symbol)
    isnull(x) && invalidcountry(x)

    idx = get(SYMBOL_LOOKUP, x, 0)
    idx > 0 && return @inbounds Country(Val(:index), idx)
    x in SYMBOL_BLACKLIST && invalidcountry(x)

    return Country(string(x))
end

Country(x::Integer) = country_from_lookup(ISO3166_NUMERIC_LOOKUP, x)

global const ALL_COUNTRIES = Country[Country(x) for x in ISO3166_ALPHA2_LIST if !isnull(x)]

Base.print(io::IO, x::Country) = print(io, cldr_name_en(x))

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
