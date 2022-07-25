"""
    module Countries

Tools for handling countries (according to ISO-3116).

The API consists of:
- `Country`
- `country_numeric`
- `country_alpha2`
- `country_alpha3`
- `country_name`
- `country_assigned`
- `new_country`
- `alias_country`
- `each_country`
"""
module Countries

export Country, country_numeric, country_alpha2, country_alpha3, country_name, country_assigned, new_country, alias_country, each_country, country_official_name, country_common_name
export Language, language_alpha2, language_alpha3, language_name, language_common_name, new_language, language_assigned

include("common.jl")
include("iso_3166-1.jl")
include("iso_639-3.jl")

import .ISO_3166_1: Country, country_numeric, country_alpha2, country_alpha3, country_name, country_assigned, new_country, alias_country, each_country, country_official_name, country_common_name
import .ISO_639_3: Language, language_alpha2, language_alpha3, language_name, language_common_name, new_language, language_assigned

include("base.jl")

end # module
