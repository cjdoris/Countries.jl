using Test, Countries

@testset "Countries" begin

    # for code coverage (which doesn't measure things only run during precompile)
    Countries._parse_json(Countries.Country, "3166-1")
    Countries._parse_json(Countries.CountrySubdivision, "3166-2")
    Countries._parse_json(Countries.Currency, "4217")
    Countries._parse_json(Countries.Language, "639-3")
    Countries._parse_json(Countries.Script, "15924")
    Countries._make_lookup(x->(), Countries.all_countries)

    @test Countries.all_countries isa Vector{Countries.Country}
    @test Countries.all_country_subdivisions isa Vector{Countries.CountrySubdivision}
    @test Countries.all_currencies isa Vector{Countries.Currency}
    @test Countries.all_languages isa Vector{Countries.Language}
    @test Countries.all_scripts isa Vector{Countries.Script}

    @test Countries.get_country("gb").alpha3 == "GBR"
    @test Countries.get_country("FRA").alpha3 == "FRA"
    @test Countries.get_country(724).alpha3 == "ESP"
    @test Countries.get_country_subdivision("US-CA").code == "US-CA"
    @test Countries.get_currency("aud").alpha3 == "AUD"
    @test Countries.get_currency(978).alpha3 == "EUR"
    @test Countries.get_language("EN").alpha3 == "eng"
    @test Countries.get_language("deu").alpha3 == "deu"
    @test Countries.get_script("LATN").alpha4 == "Latn"
    @test Countries.get_script(995).alpha4 == "Zmth"

end
