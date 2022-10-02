using TestItemRunner
@run_package_tests

@testitem "internals" begin
    # for code coverage (which doesn't measure things only run during precompile)
    Countries._parse_json(Countries.Country, "3166-1")
    Countries._parse_json(Countries.CountrySubdivision, "3166-2")
    Countries._parse_json(Countries.Currency, "4217")
    Countries._parse_json(Countries.Language, "639-3")
    Countries._parse_json(Countries.Script, "15924")
    Countries._make_lookup(Countries._all_countries)
    Countries._make_lookup(Countries._all_country_subdivisions)
    Countries._make_lookup(Countries._all_currencies)
    Countries._make_lookup(Countries._all_languages)
    Countries._make_lookup(Countries._all_scripts)
end

@testitem "lists" begin
    @test Countries.all_countries() isa AbstractVector{Countries.Country}
    @test Countries.all_country_subdivisions() isa AbstractVector{Countries.CountrySubdivision}
    @test Countries.all_currencies() isa AbstractVector{Countries.Currency}
    @test Countries.all_languages() isa AbstractVector{Countries.Language}
    @test Countries.all_scripts() isa AbstractVector{Countries.Script}            
end

@testitem "readonly" begin
    # `CanonicalIndexError <: Exception` does not hold in 1.8.2
    Err = isdefined(Base, :CanonicalIndexError) ? CanonicalIndexError : Exception
    @test_throws Err all_countries()[1] = all_countries()[2]
    @test_throws Err all_country_subdivisions()[1] = all_country_subdivisions()[2]
    @test_throws Err all_currencies()[1] = all_currencies()[2]
    @test_throws Err all_languages()[1] = all_languages()[2]
    @test_throws Err all_scripts()[1] = all_scripts()[2]
end

@testitem "lookups" begin
    @test Countries.get_country("gb").alpha3 == "GBR"
    @test Countries.get_country("FRA").alpha3 == "FRA"
    @test Countries.get_country(724).alpha3 == "ESP"
    @test Countries.get_country_subdivision("us-ca").code == "US-CA"
    @test Countries.get_currency("aud").alpha3 == "AUD"
    @test Countries.get_currency(978).alpha3 == "EUR"
    @test Countries.get_language("EN").alpha3 == "eng"
    @test Countries.get_language("deu").alpha3 == "deu"
    @test Countries.get_script("LATN").alpha4 == "Latn"
    @test Countries.get_script(995).alpha4 == "Zmth"
end
