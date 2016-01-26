module Spice


export furnsh,
       unload,
       utc2et,
       scs2e,
       vsep,
       spkpos,
       timout,
       reclat


const sharedLib = "/home/abieler/.julia/v0.4/Spice/cspice/lib/spice.so"

function furnsh(KernelFile::ASCIIString)
  ccall((:furnsh_c, sharedLib),Void,(Ptr{Cchar},),KernelFile)
end

function reclat(a::Vector)
  r = Ref{Cdouble}(0.0)
  lon = Ref{Cdouble}(0.0)
  lat = Ref{Cdouble}(0.0)
  ccall((:reclat_c, sharedLib), Void, (Ptr{Cdouble}, Ptr{Cdouble},
                     Ptr{Cdouble}, Ptr{Cdouble}), a, r, lon, lat)
  return r[], lon[], lat[]
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

end
