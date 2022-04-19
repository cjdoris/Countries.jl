module Countries

using Artifacts: @artifact_str
using DelimitedFiles: readdlm

export Country

"""
    Country(id)

A country with the given `id`.

The following are all ways to construct the UK:
```
# ISO-3166 codes
Country(826)
Country("GBR")
Country("gbr")
Country("GB")

# by name (or unambiguous partial name)
Country("United Kingdom of Great Britain and Nortern Ireland")
Country("United Kingdom")
Country("Britain")

# by alias
Countries.add_alias("UK", Country(826))
Country("uk")
```

We can retrieve information about a country by property access:
```
c = Country("GBR")
c.code    # 826
c.alpha2  # "GB"
c.alpha3  # "GBR"
c.name    # "United Kingdom of Great Britain and Northern Ireland"
```
"""
struct Country
    code::Int16
    Country(code::Integer) = new(_check_code(code))
end

struct CountryInfo
    alpha2::String
    alpha3::String
    name::String
    CountryInfo(; alpha2="", alpha3="", name="") = new(_check_alpha2(alpha2), _check_alpha3(alpha3), _check_name(name))
end

function _check_code(x)
    x = convert(Int16, x)
    1 ≤ x ≤ 999 || error("code must be between 1 and 999")
    return x
end

function _check_alpha2(x)
    x = uppercase(convert(String, x))
    if !isempty(x)
        length(x) == 2 || error("alpha2 must be empty or length 2")
        all('A' ≤ c ≤ 'Z' for c in x) || error("alpha2 must consist only of letters")
    end
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

function _check_name(x)
    x = convert(String, x)
    return x
end

const DATA_ROOT = joinpath(artifact"countries-2.5.0", "world_countries-2.5.0")

const COUNTRY_INFO = [CountryInfo() for i in 1:999]

const COUNTRY_LOOKUP = Dict{String,Country}()

Country(x::AbstractString) = get(COUNTRY_LOOKUP, x) do
    u = uppercase(x)
    get(COUNTRY_LOOKUP, x) do
        msg1 = "$(repr(x)) is not the name of a known country"
        msg2 = "you may use Countries.add_country to add a new country or Countries.add_alias to add an alias for an existing country"
        if length(u) > 3
            cs = Set{Country}()
            ks = Set{String}()
            for (k, c) in COUNTRY_LOOKUP
                if occursin(u, k)
                    push!(ks, k)
                    push!(cs, c)
                end
            end
            if isempty(cs)
                error("$msg1; $msg2")
            elseif length(cs) == 1
                #@warn "$msg1, but unambiguously matches $(repr(first(ks))); $msg2"
                return first(cs)
            else
                kk = join([repr(k) for k in ks], ", ", " or ")
                error("$msg1 (perhaps you meant one of $kk?); $msg2")
            end
        else
            error("$msg1; $msg2")
        end
    end
end

function add_default_countries()
    table = readdlm(joinpath(DATA_ROOT, "data", "countries", "en", "world.csv"), ',', String)
    @assert size(table, 2) == 4
    @assert table[1,:] == ["id", "alpha2", "alpha3", "name"]
    for i in 2:size(table, 1)
        code = parse(Int16, table[i,1])
        alpha2 = table[i,2]
        alpha3 = table[i,3]
        name = table[i,4]
        add_country(; code, alpha2, alpha3, name)
    end
end

"""
    add_country(; code, alpha2="", alpha3="", name="")

Add a country with the given `code` and optional `alpha2`, `alpha3` and `name` properties.
"""
function add_country(; code, alpha2="", alpha3="", name="")
    country = Country(code)
    info = CountryInfo(; alpha2, alpha3, name)
    # check we aren't overwriting anything
    if !isnull(country)
        error("a country with code $code already exists: $country")
    end
    aliases = [k for k0 in [info.alpha2, info.alpha3, info.name] for k in [k0, lowercase(k0), uppercase(k0)] if !isempty(k)]
    for k in aliases
        if haskey(COUNTRY_LOOKUP, k)
            c = COUNTRY_LOOKUP[k]
            error("a country with name $(repr(k)) already exists: $c")
        end
    end
    # save the info and aliases
    COUNTRY_INFO[code] = info
    for k in aliases
        COUNTRY_LOOKUP[k] = country
    end
    return
end

"""
    add_alias(name, country::Country)

Add an alias so that `Country(name)` returns `country`.
"""
function add_alias(name, country::Country)
    name = convert(String, name)
    aliases = [name, lowercase(name), uppercase(name)]
    for k in aliases
        if haskey(COUNTRY_LOOKUP, k)
            c = COUNTRY_LOOKUP[k]
            if c != country
                error("a country with alias $(repr(k)) already exists: $(repr(c))")
            end
        end
    end
    for k in aliases
        COUNTRY_LOOKUP[k] = country
    end
    return
end

add_default_countries()

function Base.getproperty(c::Country, k::Symbol)
    if k == :code
        return getfield(c, :code)
    elseif k == :info
        return COUNTRY_INFO[c.code]
    else
        return getproperty(c.info, k)
    end
end

function Base.propertynames(::Country)
    return (:code, :info, fieldnames(CountryInfo)...)
end

function Base.write(io::IO, c::Country)
    return write(io, c.code)
end

function Base.read(io::IO, ::Type{Country})
    return Country(read(io, Int16))
end

function Base.print(io::IO, c::Country)
    if !isempty(c.alpha3)
        print(io, c.alpha3)
    else
        show(io, c)
    end
end

function Base.show(io::IO, c::Country)
    if get(io, :typeinfo, Any) == Country
        if !isempty(c.alpha3)
            print(io, c.alpha3)
        elseif !isempty(c.alpha2)
            print(io, c.alpha2)
        else
            print(io, c.code)
        end
    else
        show(io, typeof(c))
        print(io, "(")
        if !isempty(c.alpha3)
            show(io, c.alpha3)
        elseif !isempty(c.alpha2)
            show(io, c.alpha2)
        else
            show(io, c.code)
        end
        print(io, ")")
    end
end

function Base.show(io::IO, ::MIME"text/plain", c::Country)
    if get(io, :compact, false)
        show(io, c)
    else
        name = isempty(c.name) ? "Invalid Country" : c.name
        code = c.code
        alpha2 = isempty(c.alpha2) ? "??" : c.alpha2
        alpha3 = isempty(c.alpha3) ? "???" : c.alpha3
        print(io, name, " (", alpha2, "/", alpha3, "/", code, ")")
    end
end

function Base.:(==)(c1::Country, c2::Country)
    c1.code == c2.code
end

function Base.hash(c::Country, h::UInt)
    hash(c.code, hash(Country, h))
end

function Base.isequal(c1::Country, c2::Country)
    isequal(c1.code, c2.code)
end

function Base.isless(c1::Country, c2::Country)
    isless(c1.code, c2.code)
end

function isnull(c::Country)
    return isempty(c.name) && isempty(c.alpha2) && isempty(c.alpha3)
end

function _each_country()
    return (Country(code) for code in 1:999)
end

function each_country()
    return (c for c in _each_country() if !isnull(c))
end

end # module
