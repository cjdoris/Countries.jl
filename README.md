# Countries.jl

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Test Status](https://github.com/cjdoris/Countries.jl/workflows/Tests/badge.svg)](https://github.com/cjdoris/Countries.jl/actions?query=workflow%3ATests)
[![codecov](https://codecov.io/gh/cjdoris/Countries.jl/branch/main/graph/badge.svg?token=AECCWGKRVJ)](https://codecov.io/gh/cjdoris/Countries.jl)

Julia package of information about countries, currencies and languages according to these
ISO standards:
- ISO 3166-1: Countries.
- ISO 3166-2: Country subdivisions.
- ISO 4217: Currencies.
- ISO 639-3: Languages.
- ISO 15924: Scripts.

The data can be converted to any table type, allowing for easy integration into data
science workflows.

The data is obtained from the Julia package
[`iso_codes_jll`](https://github.com/JuliaBinaryWrappers/iso_codes_jll.jl)
which makes available the data from the Debian package
[`iso-codes`](https://packages.debian.org/sid/iso-codes).

## Install

```
pkg> add Countries
```

## Example

```julia-repl
julia> using Countries

julia> all_countries()
249-element Vector{Country}:
 Country("AW", "ABW", "Aruba", 533, "Aruba", "Aruba", "🇦🇼")
 Country("AF", "AFG", "Afghanistan", 4, "Islamic Republic of Afghanistan", "Afghanistan", "🇦🇫")
 ⋮
 Country("ZM", "ZMB", "Zambia", 894, "Republic of Zambia", "Zambia", "🇿🇲")
 Country("ZW", "ZWE", "Zimbabwe", 716, "Republic of Zimbabwe", "Zimbabwe", "🇿🇼")

julia> get_language("en")
Language("en", "eng", "English", "I", "L", "English", "English", "eng")

julia> filter(x->startswith(x.alpha4, "La"), all_scripts())
5-element Vector{Script}:
 Script("Lana", "Tai Tham (Lanna)", 351)
 Script("Laoo", "Lao", 356)
 Script("Latf", "Latin (Fraktur variant)", 217)
 Script("Latg", "Latin (Gaelic variant)", 216)
 Script("Latn", "Latin", 215)

julia> using DataFrames

julia> DataFrame(all_currencies())
181×3 DataFrame
 Row │ alpha3  name                               numeric
     │ String  String                             Int16
─────┼────────────────────────────────────────────────────
   1 │ AED     UAE Dirham                             784
   2 │ AFN     Afghani                                971
  ⋮  │   ⋮                     ⋮                     ⋮
 180 │ ZMW     Zambian Kwacha                         967
 181 │ ZWL     Zimbabwe Dollar                        932
```

## Exported API

For each supported ISO standard, this package exports:
- a type (e.g. `Country`) to hold information about an instance from the standard;
- a function (e.g. `all_countries`) returning a list of all instances; and
- a lookup function (e.g. `get_country`) to get an instance from any of its codes.

Information about an instance can be obtained through its fields. All fields are strings,
except `numeric` which is an integer. Optional fields may also be `nothing`.

The lists also satisfy the
[`Tables.jl`](https://github.com/JuliaData/Tables.jl)
interface, so can be converted to your favourite table type.

| Standard | API | Fields |
| -------- | --- | ------ |
| ISO 3166-1: Countries | `Country`, `all_countries`, `get_country` | `alpha2`, `alpha3`, `name`, `numeric`, `official_name`, `common_name`, `flag` (optional) |
| ISO 3166-2: Country Subdivisions | `CountrySubdivision`, `all_country_subdivisions`, `get_country_subdivision` | `code`, `name`, `type`, `parent` (optional) |
| ISO 4217: Currencies | `Currency`, `all_currencies`, `get_currency` | `alpha3`, `name`, `numeric` |
| ISO 639-3: Languages | `Language`, `all_languages`, `get_language` | `alpha2` (optional), `alpha3`, `name`, `scope`, `type`, `common_name`, `inverted_name`, `bibliographic` |
| ISO 15924: Scripts | `Script`, `all_scripts`, `get_script` | `alpha4`, `name`, `numeric` |
