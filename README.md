# Countries.jl

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliahub.com/docs/Countries/)
[![Test Status](https://github.com/cjdoris/Countries.jl/workflows/Tests/badge.svg)](https://github.com/cjdoris/Countries.jl/actions?query=workflow%3ATests)
[![codecov](https://codecov.io/gh/cjdoris/Countries.jl/branch/main/graph/badge.svg?token=AECCWGKRVJ)](https://codecov.io/gh/cjdoris/Countries.jl)

Julia package for handling the countries on Earth.

Includes functions to convert between different representations of countries, such as
ISO-3166 codes (alpha2, alpha3 and numeric), country names, and the new `Country` type.

All 249 countries/territories/etc. in ISO-3166 are defined by default. It is possible to add
more user-defined countries or add aliases for existing countries.

## Install

```
pkg> add Countries
```

## Example

```julia-repl
julia> using Countries

julia> country_alpha2.(["united kingdom", "france", "germany"])
3-element Vector{String}:
 "GB"
 "FR"
 "DE"

julia> country_alpha3.(["united kingdom", "france", "germany"])
3-element Vector{String}:
 "GBR"
 "FRA"
 "DEU"

julia> country_numeric.(["united kingdom", "france", "germany"])
3-element Vector{Int16}:
 826
 250
 276

julia> country_name.(["united kingdom", "france", "germany"])
3-element Vector{String}:
 "United Kingdom of Great Britain and Northern Ireland"
 "France"
 "Germany"

julia> Country.(["united kingdom", "france", "germany"])
3-element Vector{Country}:
 GB: United Kingdom of Great Britain and Northern Ireland
 FR: France
 DE: Germany
```

## Documentation

```julia
Country(id)
```

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

---

```julia
country_numeric(country)
```

The numeric code of the given country.

Example:
```julia-repl
julia> country_numeric("GBR")
826
```

---

```julia
country_alpha2(country)
```

The alpha2 code of the given country.

Example:
```julia-repl
julia> country_alpha2("GBR")
"GB"
```

---

```julia
country_alpha3(country)
```

The alpha3 code of the given country.

Example:
```julia-repl
julia> country_alpha3("United Kingdom")
"GBR"
```

---

```julia
country_name(country)
```

The name of the given country.

Example:
```julia-repl
julia> country_name("GB")
"United Kingdom of Great Britain and Northern Ireland"
```

---

```julia
country_assigned(country)
```

True if the given country is assigned.

Example:
```julia-repl
julia> country_assigned("GB")
true

julia> country_assigned("ZZ")
false
```

---

```julia
new_country(; alpha2, alpha3="", numeric=0, name="")
```

Register a new country with the given data.

Example:
```julia-repl
julia> new_country(alpha2="ZZ", alpha3="ZZZ", numeric=999, name="Zedland")

julia> Country("zzz")
ZZ: Zedland
```

---

```julia
alias_country(alias, country)
```

Register an alias for the given country so that `Country(alias)` returns `country`.

Example:
```julia-repl
julia> alias_country("England", "GBR")

julia> Country("england")
GB: United Kingdom of Great Britain and Northern Ireland
```

---

```julia
each_country()
```

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

## Attribution

This site or product includes IP2Location™ Country Information which is available from https://www.ip2location.com.

(Specifically it was downloaded from https://www.ip2location.com/free/country-information. Last updated 14 March 2022.)
