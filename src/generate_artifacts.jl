"""
Update the parameters (usually just the version) and run `julia src/generate_artifacts.jl`.
"""

import ArtifactUtils: add_artifact!
import Pkg.Artifacts: Platform

toml = "Artifacts.toml"
version = "2.5.0"
name = "countries-$(version)"
url = "https://github.com/stefangabos/world_countries/archive/refs/tags/$(version).tar.gz"

@show toml version name url

add_artifact!(toml, name, url)
