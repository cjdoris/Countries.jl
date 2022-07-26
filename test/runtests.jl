using Test, Countries

@testset "Countries" begin

    # for code coverage (which doesn't measure things only run during precompile)
    Countries._parse_json(Countries.Country, "3166-1")
    Countries._parse_json(Countries.CountrySubdivision, "3166-2")
    Countries._parse_json(Countries.Currency, "4217")
    Countries._parse_json(Countries.Language, "639-3")
    Countries._parse_json(Countries.Script, "15924")

    @test Countries.all_countries isa Vector{Countries.Country}
    @test Countries.all_country_subdivisions isa Vector{Countries.CountrySubdivision}
    @test Countries.all_currencies isa Vector{Countries.Currency}
    @test Countries.all_languages isa Vector{Countries.Language}
    @test Countries.all_scripts isa Vector{Countries.Script}

end
