module ISO_639_3

import ..Common

struct Language
    code::Int16
    Common.construct(::Type{Language}, code::Int16) = new(code)
end

Common.code_type(::Type{Language}) = Common.Alpha3()
Common.lookup_length(::Type{Language}) = 4
Common.database(::Type{Language}) = DB

const DB = Common.Database{Language}(fields=(alpha2=String, alpha3=String, name=String, common_name=String))

Language(x::Language) = x
Language(x::AbstractString) = Common.lookup(Language, x)

language_alpha3(x) = Common.get_field(:alpha3, Language(x), "")

language_alpha2(x) = Common.get_field(:alpha2, Language(x), "")

language_name(x) = Common.get_field(:name, Language(x), "")

language_common_name(x) = Common.get_field(:common_name, Language(x), "")

language_assigned(x) = Common.assigned(Language(x))

function new_language(; alpha3, alpha2="", name="", common_name="")
    # validate the inputs
    alpha3 = Common.validate_code(Common.Alpha3(), alpha3)
    alpha2 = isempty(alpha2) ? "" : Common.validate_code(Common.Alpha2(), alpha2)
    name = convert(String, name)
    common_name = convert(String, common_name)
    if isempty(common_name)
        common_name = name
    end
    lang = Language(alpha3)
    # add the new fields
    Common.new_entry(lang; alpha2, alpha3, name, common_name)
end

const DATA_PATH = joinpath(Common.DATA_ROOT, "iso_639-3.tsv")

let
    for line in readlines(DATA_PATH)
        row = split(line, '\t')
        alpha3 = row[1]
        name = row[2]
        alpha2 = row[5]
        common_name = row[6]
        new_language(; alpha3, alpha2, name, common_name)
    end
end

end
