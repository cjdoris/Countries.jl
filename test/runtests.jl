using Test, Countries

@testset "Countries" begin

    @testset "Country" begin

        @testset "from alpha2" begin
            @test Country("AA").idx == 1
            @test Country("AB").idx == 2
            @test Country("BA").idx == 27
            @test Country("ZZ").idx == 26*26
        end

        @testset "from alpha3" begin
            @test Country("GBR") === Country("GB")
            @test Country("FRA") === Country("FR")
            @test_throws Exception Country("ZZZ")
        end

        @testset "from numeric" begin
            @test Country(826) === Country("GB")
            @test Country(250) === Country("FR")
            @test_throws Exception Country(999)
        end

        @testset "from country" begin
            @test Country(Country("GB")) === Country("GB")
        end

        @testset "from name" begin
            @test Country("United Kingdom of Great Britain and Northern Ireland") === Country("GB")
            @test Country("France") === Country("FR")
            @test_throws Exception Country("This Is Not A Country")
        end

        @testset "partial" begin
            @test Country("United Kingdom") === Country("GB")
            @test Country("Britain") === Country("GB")
            @test_throws Exception Country("Korea")
        end

        @testset "case insensitive" begin
            @test Country("de") === Country("DE")
            @test Country("De") === Country("DE")
            @test Country("dE") === Country("DE")
            @test Country("france") === Country("FR")
            @test Country("FRANCE") === Country("FR")
            @test Country("FrAnCe") === Country("FR")
        end

    end

    @testset "properties" begin

        @testset "country_numeric" begin
            @test country_numeric("Norway") == 578
            @test country_numeric("ZZ") == 0
        end

        @testset "country_alpha2" begin
            @test country_alpha2("Portugal") == "PT"
            @test country_alpha2("ZZ") == "ZZ"
        end

        @testset "country_alpha3" begin
            @test country_alpha3("Sweden") == "SWE"
            @test country_alpha3("ZZ") == ""
        end

        @testset "country_name" begin
            @test country_name("BE") == "Belgium"
            @test country_name("ZZ") == ""
        end

        @testset "country_assigned" begin
            @test country_assigned("Italy") == true
            @test country_assigned("ZZ") == false
        end

    end

    @testset "each_country" begin
        cs = collect(each_country())
        @test cs isa Vector{Country}
        @test length(cs) == 249
    end

    @testset "IO" begin

        c = Country("France")
        @test string(c) == "FR"
        @test repr(c) == "Country(\"FR\")"
        @test repr(c, context=:typeinfo=>Country) == "FR"
        @test repr("text/plain", c) == "FR: France"
        @test repr("text/plain", c, context=:compact=>true) == "Country(\"FR\")"

        io = IOBuffer()
        write(io, c)
        seekstart(io)
        @test read(io, Country) === c

    end

    @testset "comparison" begin

        @testset "==" begin
            @test Country("FR") == Country("France")
            @test Country("FR") != Country("ZZ")
        end

        @testset "isequal" begin
            @test isequal(Country("FR"), Country("France"))
            @test !isequal(Country("FR"), Country("ZZ"))
        end

        @testset "hash" begin
            @test hash(Country("FR")) == hash(Country("France"))
            @test hash(Country("FR")) != hash(Country("ZZ"))
            @test Set(Country.(["FR", "France", "ES", "Spain"])) == Set([Country("FR"), Country("ES")])
        end

        @testset "isless" begin
            @test !isless(Country("FR"), Country("FR"))
            @test isless(Country("AA"), Country("FR"))
            @test isless(Country("FR"), Country("ZZ"))
        end

    end

    @testset "new_country" begin

        @test country_assigned("ZL") == false
        new_country(alpha2="ZL", alpha3="ZLD", name="Zedland", numeric=900)
        @test country_assigned("ZL") == true
        @test country_alpha2("Zedland") == "ZL"
        @test country_alpha3("Zedland") == "ZLD"
        @test country_name("ZL") == "Zedland"
        @test country_numeric("ZLD") == 900

        @test_throws Exception new_country(alpha2="ZL", alpha3="ZLD", name="Zedland2", numeric=900)
        @test country_name("ZL") == "Zedland"

        @test_throws Exception new_country(alpha2="ZZ", alpha3="ZLD", name="Zedland2", numeric=999)
        @test country_assigned("ZZ") == false

        @test_throws Exception new_country(alpha2="ZZ", alpha3="ZZZ", name="Zedland", numeric=999)
        @test country_assigned("ZZ") == false

        @test_throws Exception new_country(alpha2="ZZ", alpha3="ZZZ", name="ZedZedZedland", numeric=900)
        @test country_assigned("ZZ") == false

    end

    @testset "alias_country" begin

        @test_throws Exception country_alpha2("my alias")
        alias_country("My Alias", "GBR")
        @test country_alpha2("my alias") === "GB"

        @test_throws Exception alias_country("My Alias", "FRA")
        @test country_alpha2("my alias") == "GB"

        alias_country("My Alias", "GBR")
        @test country_alpha2("my alias") === "GB"

        @test_throws Exception alias_country("", "GBR")
        @test_throws Exception alias_country("Z", "GBR")
        @test_throws Exception alias_country("ZZ", "GBR")
        @test_throws Exception alias_country("ZZZ", "GBR")
        @test_throws Exception alias_country("France", "GBR")

    end

end
