function get_spice()
    root_url = "http://naif.jpl.nasa.gov/pub/naif/toolkit/C/"

    @static if is_linux()
      platform_url = "PC_Linux_GCC_64bit/"
    end

    @static if is_apple()
      platform_url = "MacIntel_OSX_AppleC_64bit/"
    end

    @static if is_windows()
      platform_url = "PC_Windows_VisualC_32bit/"
    end

    pkg_name = "packages/cspice.tar.Z"
    @static if is_windows()
      pkg_name = "packages/cspice.zip"
    end

    @static if !is_windows()
        full_url = root_url * platform_url * pkg_name
        println()
        println(" - Downloading SPICE library:")
        println("   ", full_url)
        print("   This might take a moment...   ")

        cspice_archive = get(full_url)
        println("OK")
        save(cspice_archive, joinpath(install_path, basename(pkg_name)))
    end
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
  @static if !is_windows()
    run(`tar -zxf cspice.tar.Z`)
    rm("cspice.tar.Z")
  end
  @static if is_linux()
    compileLinux(install_path)
  end
  @static if is_apple()
    compileOSX(install_path)
  end
  @static if is_windows()
    compileWin(install_path)
  end
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


function compileWin(path)
  mkdir(joinpath(path, "cspice"))
  mkdir(joinpath(path, "cspice", "lib"))
  cp(joinpath(path, "spice.dll"), joinpath(path, "cspice", "lib", "spice.dll" ))
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
