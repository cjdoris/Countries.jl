# Countries.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliahub.com/docs/Countries/)
[![codecov](https://codecov.io/gh/cjdoris/Countries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cjdoris/Countries.jl)

Julia package for handling the countries on Earth.

It is based on the data here: https://github.com/stefangabos/world_countries.

All countries/territories/etc. in ISO-3166 are defined by default. It is possible to add
more user-defined countries or add aliases for existing countries.

## Install

```
] add https://github.com/cjdoris/Countries.jl.git
```

## Documentation

This module exports one type, `Country`. The following are all ways to construct the UK:
```julia
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
Countries.add_country_alias("UK", Country(826))
Country("uk")
```

We can retrieve information about a country by property access:
```julia
c = Country("GBR")
c.code    # 826
c.alpha2  # "GB"
c.alpha3  # "GBR"
c.name    # "United Kingdom of Great Britain and Northern Ireland"
```
