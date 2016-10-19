__precompile__()

module Spice

using Requests
import Requests: get

include("installer.jl")
include("spice_funcs.jl")

vma = VERSION.major
vmi = VERSION.minor
juliaversion = "v$vma.$vmi"
install_path = joinpath(homedir(), ".julia", juliaversion, "Spice")

@static if is_linux()
  const sharedLib = joinpath(install_path, "cspice/lib/spice.so")
end

@static if is_apple()
  const sharedLib = joinpath(install_path, "cspice/lib/spice.dylib")
end

@static if is_windows()
  const sharedLib = joinpath(install_path, "cspice/lib/spice.dll")
end


export furnsh,
       pxform,
       unload,
       utc2et,
       scs2e,
       vsep,
       str2et,
       spkpos,
       timout,
       reclat,
       init_spice,
       sharedLib

end
