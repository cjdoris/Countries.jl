"""
This build script parses the JSON files into TSV files so that the JSON parsing package is
not required at run-time. This reduces TTFX.
"""

import JSON3
import iso_codes_jll: iso_codes_dir

for (name, keys) in [
    ("15924", ["alpha_4", "name", "numeric"]),
    ("3166-1", ["alpha_2", "alpha_3", "name", "numeric", "flag", "official_name", "common_name"]),
    ("3166-2", ["code", "name", "type", "parent"]),
    ("3166-3", ["alpha_2", "alpha_3", "alpha_4", "name", "numeric", "comment", "withdrawal_date"]),
    ("4217", ["alpha_3", "name", "numeric"]),
    ("639-2", ["alpha_3", "name", "alpha_2", "bibliographic", "common_name"]),
    ("639-3", ["alpha_3", "name", "scope", "type", "alpha_2", "common_name", "inverted_name", "bibliographic"]),
    ("639-5", ["alpha_3", "name"]),
]
    # read the JSON file
    json = open(JSON3.read, joinpath(iso_codes_dir, "json", "iso_$name.json"))
    # read the keys of interest
    data = [
        [get(row, k, "")::String for k in keys]
        for row in json[name]
    ]
    # check there are no delimiters in the data
    @assert all(!(c in ('\t', '\n')) for row in data for x in row for c in x)
    # write the delimited data
    open(joinpath(@__DIR__, "iso_$name.tsv"), "w") do io
        for row in data
            println(io, join(row, '\t'))
        end
    end
end
