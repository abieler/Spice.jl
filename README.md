# Spice.jl

Wrapper around the NAIF cspice API, which is an observation geometry information system used in
the planetary sciences and astro community. NO warranty, Spice.jl is not an official product of JPL.
http://naif.jpl.nasa.gov/naif/

Spice.jl only supports 64 bit OSX or Linux.




##Installation
First, clone the package from github. Then you need a one time installation of the cspice API. To do so start a Julia REPL
session and type:
```
Pkg.clone("https://github.com/abieler/Spice.jl.git")
using Spice
init_spice()
```

This will download the spice api and compile the a shared library which is then called by the Spice.jl scipt.
Currently only a very limited set of cspice functions is available but I plan on constantly expand this list. If
you have a specific function in mind which should be available feel free to open an issue.

## Available functions
```
furnsh
latrec
latrec!
pxform
unload
utc2et
scs2e
vsep
str2et
spkpos
timout
reclat
```

