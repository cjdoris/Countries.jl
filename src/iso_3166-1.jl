module ISO_3166_1

import ..Common: DATA_ROOT, STRICT

### constructors

"""
    Country(id)

A country with the given `id`.

It is canonically represented by its alpha2 code, such as "GB". Two countries with
the same code are identically equal.

The following are all ways to construct the UK:
```julia
# ISO-3166 codes
Country(826)
Country("GBR")
Country("gbr")
Country("GB")

# by name (or unambiguous partial name)
Country("United Kingdom of Great Britain and Northern Ireland")
Country("United Kingdom")
Country("Britain")

# by alias
alias_country("England", "GB")
Country("england")
```
"""
struct Country
    idx::Int16
    Country(::Val{:new}, idx::Int16) = new(idx)
end

const ALPHA2 = [string(c1, c2) for c1 in 'A':'Z' for c2 in 'A':'Z']
const COUNTRIES = [Country(Val(:new), Int16(i)) for (i,_) in enumerate(ALPHA2)]
const ASSIGNED = [false for _ in ALPHA2]
const ALPHA3 = ["" for _ in ALPHA2]
const NUMERIC = [Int16(0) for _ in ALPHA2]
const NAME = ["" for _ in ALPHA2]

const LOOKUP = Dict{String,Country}(zip(ALPHA2, COUNTRIES))
const LOOKUP_NUM = Dict{Int16,Country}()
const LOOKUP_CACHE = Dict{String,Country}()

const AMBIG = Dict{String,Country}()

_lookup_error(x, extra="") = error("$(repr(x)) is not a recognized country name$extra; you can use new_country to define a new country or alias_country to define an alias for an existing country")

Country(x::AbstractString) = get!(LOOKUP_CACHE, x) do
    u = uppercase(x)
    get(LOOKUP, u) do
        if length(u) > 3
            ks = String[]
            cs = Set{Country}()
            for (k, c) in LOOKUP
                if occursin(u, k)
                    push!(ks, k)
                    push!(cs, c)
                end
            end
            if length(cs) == 1 && !STRICT[]
                c = only(cs)
                AMBIG[x] = c
                return c
            elseif isempty(ks)
                _lookup_error(x)
            else
                sort!(ks, by=Country)
                kk = join([repr(k) for k in ks], ", ", " or ")
                _lookup_error(x, " (perhaps you meant $kk)")
            end
        else
            _lookup_error(x)
        end
    end
end

Country(x::Integer) = get(LOOKUP_NUM, x) do
    error("$x is not a recognized country code")
end

Country(x::Country) = x


### inspect countries

"""
    country_numeric(country)

The numeric code of the given country.

Example:
```julia-repl
julia> country_numeric("GBR")
826
```
"""
country_numeric(c) = @inbounds NUMERIC[Country(c).idx]

"""
    country_alpha2(country)

The alpha2 code of the given country.

Example:
```julia-repl
julia> country_alpha2("GBR")
"GB"
```
"""
country_alpha2(c) = @inbounds ALPHA2[Country(c).idx]

"""
    country_alpha3(country)

The alpha3 code of the given country.

Example:
```julia-repl
julia> country_alpha3("United Kingdom")
"GBR"
```
"""
country_alpha3(c) = @inbounds ALPHA3[Country(c).idx]

"""
    country_name(country)

The name of the given country.

Example:
```julia-repl
julia> country_name("GB")
"United Kingdom of Great Britain and Northern Ireland"
```
"""
country_name(c) = @inbounds NAME[Country(c).idx]

"""
    country_assigned(country)

True if the given country is assigned.

Example:
```julia-repl
julia> country_assigned("GB")
true

julia> country_assigned("ZZ")
false
```
"""
country_assigned(c) = @inbounds ASSIGNED[Country(c).idx]

"""
    each_country()

Iterator over each assigned country.

Example:
```julia-repl
julia> collect(each_country())
250-element Vector{Country}:
 AD: Andorra
 AE: United Arab Emirates
 ⋮
 ZM: Zambia
 ZW: Zimbabwe
```
"""
function each_country()
    return (c for c in COUNTRIES if country_assigned(c))
end


### overload Base

function Base.print(io::IO, c::Country)
    print(io, country_alpha2(c))
end

function Base.show(io::IO, c::Country)
    if get(io, :typeinfo, Any) == Country
        print(io, country_alpha2(c))
    else
        show(io, Country)
        print(io, "(")
        show(io, country_alpha2(c))
        print(io, ")")
    end
end

function Base.show(io::IO, ::MIME"text/plain", c::Country)
    if get(io, :compact, false)
        show(io, c)
    else
        print(io, country_alpha2(c), ": ", country_assigned(c) ? country_name(c) : "(Unassigned Country)")
    end
end

function Base.write(io::IO, c::Country)
    return write(io, c.idx)
end

function Base.read(io::IO, ::Type{Country})
    return Country(Val(:new), read(io, Int16))
end

function Base.:(==)(c1::Country, c2::Country)
    c1.idx == c2.idx
end

function Base.hash(c::Country, h::UInt)
    hash(c.idx, hash(Country, h))
end

function Base.isequal(c1::Country, c2::Country)
    isequal(c1.idx, c2.idx)
end

function Base.isless(c1::Country, c2::Country)
    isless(c1.idx, c2.idx)
end


### new countries

function _check_numeric(x)
    x = convert(Int16, x)
    0 ≤ x ≤ 999 || error("numeric must be between 0 and 999")
    return x
end

function _check_alpha2(x)
    x = uppercase(convert(String, x))
    length(x) == 2 || error("alpha2 must be length 2")
    all('A' ≤ c ≤ 'Z' for c in x) || error("alpha2 must consist only of letters")
    return x
end

function _check_alpha3(x)
    x = uppercase(convert(String, x))
    if !isempty(x)
        length(x) == 3 || error("alpha3 must be empty or length 3")
        all('A' ≤ c ≤ 'Z' for c in x) || error("alpha3 must consist only of letters")
    end
    return x
end

"""
    new_country(; alpha2, alpha3="", numeric=0, name="")

Register a new country with the given data.

Example:
```julia-repl
julia> new_country(alpha2="ZZ", alpha3="ZZZ", numeric=999, name="Zedland")

julia> Country("zzz")
ZZ: Zedland
```
"""
function new_country(; alpha2, alpha3="", numeric=0, name="")
    alpha2 = _check_alpha2(alpha2)
    alpha3 = _check_alpha3(alpha3)
    numeric = _check_numeric(numeric)
    name = convert(String, name)
    uname = uppercase(name)
    country = Country(alpha2)
    idx = country.idx
    # check none of the info clashes
    if ASSIGNED[idx]
        error("country=$(repr(country)) already assigned")
    end
    if haskey(LOOKUP, alpha3)
        error("alpha3=$(repr(alpha3)) already used by country=$(Country(alpha3))")
    end
    if haskey(LOOKUP, uname)
        error("name=$(repr(name)) already used by country=$(Country(name))")
    end
    if haskey(LOOKUP_NUM, numeric)
        error("numeric=$numeric already used by country=$(Country(numeric))")
    end
    # assign
    ASSIGNED[idx] = true
    ALPHA3[idx] = alpha3
    NUMERIC[idx] = numeric
    NAME[idx] = name
    # lookup
    for k in [alpha3, uname]
        if !isempty(k)
            LOOKUP[k] = country
        end
    end
    if numeric > 0
        LOOKUP_NUM[numeric] = country
    end
    empty!(LOOKUP_CACHE)
    return
end

"""
    alias_country(alias, country)

Register an alias for the given country so that `Country(alias)` returns `country`.

Example:
```julia-repl
julia> alias_country("England", "GBR")

julia> Country("england")
GB: United Kingdom of Great Britain and Northern Ireland
```
"""
function alias_country(name, country)
    name = convert(String, name)
    uname = uppercase(name)
    country = Country(country)
    if length(name) < 4
        error("alias=$(repr(name)) too short, must have length at least 4")
    end
    if haskey(LOOKUP, uname)
        if LOOKUP[uname] != country
            error("alias=$(repr(name)) already used by country=$(Country(name))")
        end
        return
    end
    LOOKUP[uname] = country
    empty!(LOOKUP_CACHE)
    return
end


### populate default countries at precompile-time

const DATA_PATH = joinpath(DATA_ROOT, "iso_3166-1.tsv")

let
    for line in readlines(DATA_PATH)
        row = split(line, '\t')
        numeric = parse(Int16, row[4])
        alpha2 = row[1]
        alpha3 = row[2]
        name = row[3]
        new_country(; numeric, alpha2, alpha3, name)
    end
end

### precompile

for country in Any["GB", "GBR", "United Kingdom", 826, Country("GB"), Country("ZZ")]
    Country(country)
    country_alpha2(country)
    country_alpha3(country)
    country_assigned(country)
    country_name(country)
    country_numeric(country)
end
for country in ["GB", "gb", "Gb", "FOO", "foo", "Foo", "FOOO", "fooo", "Fooo"]
    try
        Country(country)
    catch
    end
end
collect(each_country())
empty!(AMBIG)

end