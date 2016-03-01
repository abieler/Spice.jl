module Spice

using Requests
import Requests: get


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


vma = VERSION.major
vmi = VERSION.minor
juliaversion = "v$vma.$vmi"
install_path = joinpath(homedir(), ".julia", juliaversion, "Spice")
const sharedLib = joinpath(install_path, "cspice/lib/spice.so")

function furnsh(KernelFile::ASCIIString)
  ccall((:furnsh_c, sharedLib),Void,(Ptr{Cchar},),KernelFile)
end

function pxform(from, to, et)
  rotMat = zeros(Float64, 3,3)
  ccall((:pxform_c, sharedLib), Void, (Ptr{Cchar}, Ptr{Cchar}, Cdouble, Ptr{Cdouble}),
        from, to, et, rotMat)
  return rotMat
end

function reclat(a::Vector)
  r = Ref{Cdouble}(0.0)
  lon = Ref{Cdouble}(0.0)
  lat = Ref{Cdouble}(0.0)
  ccall((:reclat_c, sharedLib), Void, (Ptr{Cdouble}, Ptr{Cdouble},
                     Ptr{Cdouble}, Ptr{Cdouble}), a, r, lon, lat)
  return r[], lon[], lat[]
end

function str2et(s::AbstractString)
  et = Ref{Cdouble}(0.0)
  ccall((:utc2et_c, sharedLib), Float64, (Ptr{Cchar}, Ptr{Cdouble}), s, et)
  return et[]
end

function utc2et(s::ASCIIString)
  et = Ref{Cdouble}(0.0)
  ccall((:utc2et_c, sharedLib), Void, (Ptr{Cchar},Ptr{Cdouble}), s, et)
  return et[]
end


function scs2e(sc::Int64, sclkch::ASCIIString)
  et = Ref{Cdouble}(0.0)
  ccall((:scs2e_c, sharedLib), Void, (Int64, Ptr{Cchar}, Ptr{Cdouble}),
        sc, sclkch, et)
  return et[]
end

function spkpos(target::ASCIIString, et::Float64, ref::ASCIIString,
                abcorr::ASCIIString, obs::ASCIIString)
  pos = zeros(Float64, 3)
  lt = Ref{Cdouble}(0.0)
  ccall((:spkpos_c, sharedLib), Void, (Ptr{Cchar}, Float64,
        Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Cdouble}),
        target, et, ref, abcorr, obs, pos, lt)
  return pos, lt[]
end

function timout(et::Float64, pictur::ASCIIString, lenOutput::Int64)
  s = "............................."
  ccall((:timout_c, sharedLib), Void, (Float64, Ptr{Cchar}, Int64, Ptr{Cchar}),
        et, pictur, lenOutput, s)
  return s
end

function unload(KernelFile::ASCIIString)
  ccall((:furnsh_c, sharedLib),Void,(Ptr{Cchar},),KernelFile)
end

function utc2et(s::ASCIIString)
  et = 0.0
  ccall((:utc2et_c, sharedLib), Float64, (Ptr{Cchar}, Float64), s, et)
end


function vsep(a::Vector, b::Vector)
  ccall((:vsep_c, sharedLib), Float64, (Ptr{Float64}, Ptr{Float64}), a, b)
end


function get_spice()
root_url = "http://naif.jpl.nasa.gov/pub/naif/toolkit/C/"

@linux_only platform_url = "PC_Linux_GCC_64bit/"
@osx_only platform_url = "MacIntel_OSX_AppleC_64bit/"
@windows_only println("Windows not supported")

pkg_name = "packages/cspice.tar.Z"

full_url = root_url * platform_url * pkg_name
println()
println(" - Downloading SPICE library:")
println("   ", full_url)
print("   This might take a moment...   ")
cspice_archive = get(full_url)
println("OK")
save(cspice_archive, joinpath(install_path, "cspice.tar.Z"))
nothing
end

function init_spice()
  get_spice()
  cd(install_path)
  try
    rm("cspice")
    rm("cspice.tar.Z")
  catch
  end
  run(`tar -zxf cspice.tar.Z`)
  rm("cspice.tar.Z")
  @linux_only compileLinux(install_path)
  @osx_only compileOSX(install_path)
end

function compileOSX(path)
  previousDir = pwd()
  cd(joinpath(path, "cspice/lib"))
  run(`ar -x cspice.a`)
  run(`ar -x csupport.a`)
  objectFiles = get_object_files(".")
  run(`gcc -dynamiclib -lm $objectFiles -o spice.dylib`)
  run(`rm $objectFiles`)
  cd(previousDir)
  nothing
end

function compileLinux(path)
  previousDir = pwd()
  cd(joinpath(path, "cspice/lib"))
  run(`ar -x cspice.a`)
  run(`ar -x csupport.a`)
  objectFiles = get_object_files(".")
  run(`gcc -shared -fPIC -lm $objectFiles -o spice.so`)
  run(`rm $objectFiles`)
  cd(previousDir)
  nothing
end

function get_object_files(path)

  objectFiles = AbstractString[]
  for fileName in readdir(path)
    if split(fileName, '.')[end] == "o"
      push!(objectFiles, fileName)
    end
  end
  return objectFiles

end


end
