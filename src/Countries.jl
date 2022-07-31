module Countries

import JSON3
import iso_codes_jll

export Country, all_countries, get_country
export CountrySubdivision, all_country_subdivisions, get_country_subdivision
export Currency, all_currencies, get_currency
export Language, all_languages, get_language
export Script, all_scripts, get_script


### CORE

_json_path(name) = joinpath(iso_codes_jll.iso_codes_dir::String, "json", "iso_$name.json")

_load_json(name) = open(JSON3.read, _json_path(name))[name]

_parse_json(::Type{T}, name) where {T} = T[_parse(T, item) for item in _load_json(name)]

_getstr(item, key) = item[key]::String
_getstr(item, key, dflt) = get(item, key, dflt)::Union{String,typeof(dflt)}
_getnum(item, key) = parse(Int16, _getstr(item, key))

function _make_lookup(keys, items)
    strs = Dict{String,Int}()
    ints = Dict{Int,Int}()
    for i in eachindex(items)
        for k in keys(items[i])
            if k isa Integer
                @assert get(ints, k, i) == i
                ints[k] = i
            elseif k isa String
                for k2 in (k, uppercase(k), lowercase(k))
                    @assert get(strs, k2, i) == i
                    strs[k2] = i
                end
            else
                @assert k === nothing
            end
        end
    end
    if isempty(ints)
        ints = nothing
    end
    return (strs, ints)
end

_lookup(k::AbstractString, list, (strs, nums)) = list[strs[k]]
_lookup(k::Integer, list, (strs, nums)) = nums === nothing ? error("$(eltype(list)) does not have a numeric code") : list[nums[k]]


### ISO 3166-1 COUNTRIES

struct Country
    alpha2::String
    alpha3::String
    name::String
    numeric::Int16
    official_name::String
    common_name::String
    flag::Union{String,Nothing}
end

function _parse(::Type{Country}, item)
    alpha2 = _getstr(item, :alpha_2)
    alpha3 = _getstr(item, :alpha_3)
    name = _getstr(item, :name)
    numeric = _getnum(item, :numeric)
    official_name = _getstr(item, :official_name, name)
    common_name = _getstr(item, :common_name, name)
    flag = _getstr(item, :flag, nothing)
    return Country(alpha2, alpha3, name, numeric, official_name, common_name, flag)
end

const all_countries = _parse_json(Country, "3166-1")

const _lookup_countries = _make_lookup(x -> (x.alpha2, x.alpha3, x.flag, x.numeric,), all_countries)

get_country(k) = _lookup(k, all_countries, _lookup_countries)


### ISO 3166-2 COUNTRY SUBDIVISIONS

struct CountrySubdivision
    code::String
    name::String
    type::String
    parent::Union{String,Nothing}
end

function _parse(::Type{CountrySubdivision}, item)
    code = _getstr(item, :code)
    name = _getstr(item, :name)
    type = _getstr(item, :type)
    parent = _getstr(item, :parent, nothing)
    return CountrySubdivision(code, name, type, parent)
end

const all_country_subdivisions = _parse_json(CountrySubdivision, "3166-2")

const _lookup_country_subdivisions = _make_lookup(x -> (x.code,), all_country_subdivisions)

get_country_subdivision(k) = _lookup(k, all_country_subdivisions, _lookup_country_subdivisions)


### ISO 4217 CURRENCIES

struct Currency
    alpha3::String
    name::String
    numeric::Int16
end

function _parse(::Type{Currency}, item)
    alpha3 = _getstr(item, :alpha_3)
    name = _getstr(item, :name)
    numeric = _getnum(item, :numeric)
    return Currency(alpha3, name, numeric)
end

const all_currencies = _parse_json(Currency, "4217")

const _lookup_currencies = _make_lookup(x -> (x.alpha3, x.numeric,), all_currencies)

get_currency(k) = _lookup(k, all_currencies, _lookup_currencies)


### ISO 639-3 LANGUAGES

struct Language
    alpha2::Union{String,Nothing}
    alpha3::String
    name::String
    scope::String
    type::String
    common_name::String
    inverted_name::String
    bibliographic::Union{String,Nothing}
end

function _parse(::Type{Language}, item)
    alpha2 = _getstr(item, :alpha_2, nothing)
    alpha3 = _getstr(item, :alpha_3)
    name = _getstr(item, :name)
    scope = _getstr(item, :scope)
    type = _getstr(item, :type)
    common_name = _getstr(item, :common_name, name)
    inverted_name = _getstr(item, :inverted_name, name)
    bibliographic = _getstr(item, :bibliographic, nothing)
    return Language(alpha2, alpha3, name, scope, type, common_name, inverted_name, bibliographic)
end

const all_languages = _parse_json(Language, "639-3")

const _lookup_languages = _make_lookup(x -> (x.alpha2, x.alpha3, x.bibliographic,), all_languages)

get_language(k) = _lookup(k, all_languages, _lookup_languages)


### ISO 15924 SCRIPTS

struct Script
    alpha4::String
    name::String
    numeric::Int16
end

function _parse(::Type{Script}, item)
    alpha4 = _getstr(item, :alpha_4)
    name = _getstr(item, :name)
    numeric = _getnum(item, :numeric)
    return Script(alpha4, name, numeric)
end

const all_scripts = _parse_json(Script, "15924")

const _lookup_scripts = _make_lookup(x -> (x.alpha4, x.numeric, x.name), all_scripts)

get_script(k) = _lookup(k, all_scripts, _lookup_scripts)

end # module
