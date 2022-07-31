module Countries

import JSON3
import iso_codes_jll

export Country, all_countries
export CountrySubdivision, all_country_subdivisions
export Currency, all_currencies
export Language, all_languages
export Script, all_scripts


### CORE

_json_path(name) = joinpath(iso_codes_jll.iso_codes_dir::String, "json", "iso_$name.json")

__load_json(name) = open(JSON3.read, _json_path(name))[name]

const _Items = typeof(__load_json("3166-1"))
const _Item = typeof(__load_json("3166-1")[1])

_load_json(name) = __load_json(name)::_Items

_parse_json(::Type{T}, name) where {T} = T[_parse(T, item)::T for item::_Item in _load_json(name)]

_getstr(item, key) = item[key]::String
_getstr(item, key, dflt) = get(item, key, dflt)::Union{String,typeof(dflt)}
_getnum(item, key) = parse(Int16, _getstr(item, key))


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

function _parse(::Type{Country}, item::_Item)
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


### ISO 3166-2 COUNTRY SUBDIVISIONS

struct CountrySubdivision
    code::String
    name::String
    type::String
    parent::Union{String,Nothing}
end

function _parse(::Type{CountrySubdivision}, item::_Item)
    code = _getstr(item, :code)
    name = _getstr(item, :name)
    type = _getstr(item, :type)
    parent = _getstr(item, :parent, nothing)
    return CountrySubdivision(code, name, type, parent)
end

const all_country_subdivisions = _parse_json(CountrySubdivision, "3166-2")


### ISO 4217 CURRENCIES

struct Currency
    alpha3::String
    name::String
    numeric::Int16
end

function _parse(::Type{Currency}, item::_Item)
    alpha3 = _getstr(item, :alpha_3)
    name = _getstr(item, :name)
    numeric = _getnum(item, :numeric)
    return Currency(alpha3, name, numeric)
end

const all_currencies = _parse_json(Currency, "4217")


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

function _parse(::Type{Language}, item::_Item)
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


### ISO 15924 SCRIPTS

struct Script
    alpha4::String
    name::String
    numeric::Int16
end

function _parse(::Type{Script}, item::_Item)
    alpha4 = _getstr(item, :alpha_4)
    name = _getstr(item, :name)
    numeric = _getnum(item, :numeric)
    return Script(alpha4, name, numeric)
end

const all_scripts = _parse_json(Script, "15924")

### ISO LOOKUP FUNCTIONS

for (t, db, n) in ((:Country, :all_countries, :country), (:CountrySubdivision, :all_country_subdivisions, :country_subdivision), (:Currency, :all_currencies, :currency), (:Language, :all_languages, :language), (:Script, :all_scripts, :script))
    f = Symbol("lookup_$n")
    @eval begin
        export $f
        
        """
            $($f)(field_name::Symbol, lookup_value)
        
        Find the first $($t) whose `field_name` has value `lookup_value`.
        
        # Example
        
        ```julia
        $($f)(:name, "Some $($t) Name")
        ```
        """
        function $f(field_name::Symbol, lookup_value)
            field_name ∉ fieldnames($t) && throw(ArgumentError("Field $field_name does not exist for type $($t)"))
            i = findfirst($db) do x
                v = getfield(x, field_name)
                !isnothing(v) && v == lookup_value
            end
            return isnothing(i) ? i : $db[i]
        end
    end
end

end # module
