using Test, Countries

@testset "Countries" begin

    @test Countries.all_countries isa Vector{Countries.Country}
    @test Countries.all_country_subdivisions isa Vector{Countries.CountrySubdivision}
    @test Countries.all_currencies isa Vector{Countries.Currency}
    @test Countries.all_languages isa Vector{Countries.Language}
    @test Countries.all_scripts isa Vector{Countries.Script}

end
