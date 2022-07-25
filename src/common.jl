module Common

const DATA_ROOT = joinpath(dirname(@__DIR__), "deps")

const STRICT = Ref(false)

struct Alpha3 end
struct Alpha2 end

struct Database{T,C,Fs}
    instances::Dict{C,T}
    assigned::Dict{C,Bool}
    lookup::Dict{String,T}
    cache::Dict{String,T}
    ambig::Dict{String,T}
    fields::Fs
end

function Database{T}(; fields=()) where {T}
    C = code_inttype(T)
    fnames = Tuple(n for (n, t) in pairs(fields))
    fitems = Tuple(Dict{C,t}() for (n, t) in pairs(fields))
    ftuple = NamedTuple{fnames}(fitems)
    Fs = typeof(ftuple)
    return Database{T,C,Fs}(Dict(), Dict(), Dict(), Dict(), Dict(), ftuple)
end

function code_type end
function code_length end
function construct end
function lookup_length end
function database end

code_field(::Type{T}) where {T} = code_field(code_type(T))
code_field(::Alpha2) = :alpha2
code_field(::Alpha3) = :alpha3

name_field(::Type{T}) where {T} = :name

code_length(::Type{T}) where {T} = code_length(code_type(T))
code_length(::Alpha2) = 2
code_length(::Alpha3) = 3

code_inttype(::Type{T}) where {T} = code_inttype(code_type(T))
code_inttype(::Alpha2) = Int16
code_inttype(::Alpha3) = Int16

validate_code(::Type{T}, x) where {T} = validate_code(code_type(T), x)
validate_code(::Alpha2, x) = length(x) == 2 && all(('a' ≤ c ≤ 'z') || ('A' ≤ c ≤ 'Z') for c in x) ? uppercase(x) : error("alpha2 must be 2 characters of letters")
validate_code(::Alpha3, x) = length(x) == 3 && all(('a' ≤ c ≤ 'z') || ('A' ≤ c ≤ 'Z') for c in x) ? uppercase(x) : error("alpha3 must be 3 characters of letters")

make_code_int(::Type{T}, x) where {T} = make_code_int(code_type(T), x)
function make_code_int(::Alpha2, x)
    c1, c2 = validate_code(Alpha2(), x)
    return Int16(26) * Int16(c1 - 'A') + Int16(c2 - 'A')
end
function make_code_int(::Alpha3, x)
    c1, c2, c3 = validate_code(Alpha3(), x)
    return Int16(26)*(Int16(26) * Int16(c1 - 'A') + Int16(c2 - 'A')) + Int16(c3 - 'A')
end

lookup(::Type{T}, x; kw...) where {T} = lookup(database(T), x; kw...)

lookup(db::Database{T}, x::AbstractString; strict=STRICT[]) where {T} = get!(db.cache, x) do
    u = uppercase(x)
    get(db.lookup, u) do
        if length(u) == code_length(T)
            c = construct(T, make_code_int(T, u))
            db.lookup[u] = c
            db.fields[code_field(T)][c.code] = validate_code(T, u)
            return c
        elseif length(u) > lookup_length(T)
            ks = String[]
            cs = Set{T}()
            for (k, c) in db.lookup
                if occursin(u, k)
                    push!(ks, k)
                    push!(cs, c)
                end
            end
            if length(cs) == 1 && !strict
                c = only(cs)
                db.ambig[x] = c
                return c
            elseif isempty(ks)
                error("$(repr(x)) is not a recognized name")
            else
                sort!(ks, by=T)
                kk = join([repr(k) for k in ks], ", ", " or ")
                error("$(repr(x)) is not a recognized name, perhaps you meant: $kk")
            end
        else
            error("$(repr(x)) is not a recognized name")
        end
    end
end

assigned(x) = assigned(database(typeof(x)), x)

assigned(db::Database{T}, x::T) where {T} = get(db.assigned, x.code, false)

get_field(k::Symbol, x, d) = get_field(database(typeof(x)), k, x, d)

get_field(db::Database, k::Symbol, x, d) = get(db.fields[k], x.code, d)

get_code(x) = get_field(code_field(typeof(x)), x, "")

get_name(x) = get_field(name_field(typeof(x)), x, "")

function new_entry(x; kw...)
    db = database(typeof(x))
    # check it's not already done
    assigned(db, x) && error("$(repr(x)) is already assigned")
    # check we aren't overwriting anything
    for (k, v) in pairs(kw)
        if v isa AbstractString && !isempty(v)
            if k in (:alpha2, :alpha3, :alpha4) || length(v) ≥ lookup_length(typeof(x))
                if k != code_field(typeof(x)) && haskey(db.lookup, uppercase(v))
                    error("$k=$(repr(v)) already used by $(repr(db.lookup[uppercase(v)]))")
                end
            end
        end
    end
    # assign the fields
    for (k, v) in pairs(kw)
        db.fields[k][x.code] = v
        if v isa AbstractString && !isempty(v)
            if k in (:alpha2, :alpha3, :alpha4) || length(v) ≥ lookup_length(typeof(x))
                db.lookup[uppercase(v)] = x
            end
        end
    end
    db.assigned[x.code] = true
    return
end

end
