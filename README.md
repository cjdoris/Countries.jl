# Countries.jl

Julia package for handling the countries on Earth. Useful for example to decode countries encoded differently in different data sets.

It is based on the data [here](https://datahub.io/core/country-codes), which is downloaded the first time you load this package.

## Install

```
] add https://github.com/cjdoris/Countries.jl.git
```

## Documentation

This module exports one type, `Country`. The following are all ways to construct the UK:
```julia
# ISO3166 codes (numeric, strings or symbols)
Country(826)
Country("GB")
Country(:GB)
Country("GBR")
Country(:GBR)

# Official name, UN name (any case, any language) or CLDR display name
Country("UK")
Country("United Kingdom of Great Britain and Northern Ireland")
Country("EL REINO UNIDO DE GRAN BRETAÑA E IRLANDA DEL NORTE")

# When all else fails, if there is an unambiguous match, returns this and emits a warning
Country("United Kingdom")
Country("Great Britain")
Country("Britain")
Country("Reino Unido")
Country("Grande-Bretagne")
```

We can retrieve information about a country `c` via property access:
```julia
c = Country(:GBR)
c.iso3166_numeric       # 826
c.iso3166_alpha2        # :GB
c.iso3166_alpha3        # :GBR
c.cldr_display_name     # "UK"
c.official_name_en      # "United Kingdom of Great Britain and Northern Ireland"
c.unterm_arabic_formal  # "المملكة المتحدة لبريطانيا العظمى وآيرلندا الشمالية"
c.tld_name              # ".uk"
c.continent_name        # "EU"
c.capital_name          # "London"
```

Alternatively there are functions of the same name. The argument can be anything convertible to a country. The return type can be specified:
```julia
c = Country(:GBR)
Countries.continent_name(c)            # "EU"
Countries.continent_name(String, c)    # "EU"
Countries.continent_name(Symbol, c)    # :EU
Countries.continent_name(Symbol, :GBR) # :EU
```
