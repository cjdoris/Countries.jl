# Countries.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliahub.com/docs/Countries/)
[![codecov](https://codecov.io/gh/cjdoris/Countries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cjdoris/Countries.jl)

Julia package for handling the countries on Earth.

It is based on the data here: https://github.com/stefangabos/world_countries.

All countries/territories/etc. in ISO-3166 are defined by default. It is possible to add
more user-defined countries or add aliases for existing countries.

## Install

```
pkg> add https://github.com/cjdoris/Countries.jl.git
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
