for T in (Language,)

    @eval @eval function Base.print(io::IO, x::$T)
        print(io, Common.canonical(x))
    end

    @eval @eval function Base.show(io::IO, x::$T)
        if get(io, :typeinfo, Any) == typeof(x)
            print(io, Common.canonical(x))
        else
            show(io, typeof(x))
            print(io, "(")
            show(io, Common.get_code(x))
            print(io, ")")
        end
    end

    @eval function Base.show(io::IO, ::MIME"text/plain", x::$T)
        if get(io, :compact, false)
            show(io, x)
        else
            print(io, Common.get_code(x), ": ", Common.assigned(x) ? Common.get_name(x) : $("(Unassigned $(nameof(T)))"))
        end
    end

    @eval function Base.write(io::IO, x::$T)
        return write(io, x.code)
    end

    @eval function Base.read(io::IO, ::Type{$T})
        code = read(io, $(Common.code_type(T)))
        return Common.construct($T, code)
    end

    @eval function Base.:(==)(x1::$T, x2::$T)
        x1.code == x2.code
    end

    @eval function Base.hash(x::$T, h::UInt)
        hash(x.code, hash($T, h))
    end

    @eval function Base.isequal(x1::$T, x2::$T)
        isequal(x1.code, x2.code)
    end

    @eval function Base.isless(x1::$T, x2::$T)
        isless(x1.code, x2.code)
    end

end
