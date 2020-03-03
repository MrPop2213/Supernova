using DataFrames
using JSON
using CSV

abstract type Source end

struct SNE_SPACE <: Source
end

function load_supernova(file_name::String, source::T) where {T<:Source}
    extension = split(file_name, ".")[end]
    if extension == "csv"
        return csv_loader(file_name, source)
    elseif extension == "json"
        return json_loader(file_name, source)
    else
        error("Unknown extension: $extension")
    end
end

function csv_loader(file_name::String, source::SNE_SPACE)
    obj = DataFrame(CSV.read(file_name))
    obj.e_magnitude = collect(replace(obj.e_magnitude, missing => -1))
    obj.upperlimit = obj.e_magnitude .== -1
    obj.instrument = collect(replace(obj.instrument, missing => ""))
    obj.telescope = collect(replace(obj.telescope, missing => ""))
    delete!(obj, :event)
    return obj
end

function json_loader(file_name::String, source::SNE_SPACE)
    obj = JSON.parsefile(file_name)
    name = collect(keys(obj))[1]
    obj = collect(obj[name]["photometry"])
    time = Float64[]
    magnitude = Float64[]
    e_magnitude = Float64[]
    upperlimit = Bool[]
    band = String[]
    instrument = String[]
    telescope = String[]
    source = String[]
    println(obj[3466])
    for i in obj
        push!(time, parse(Float64, i[1]))
        push!(magnitude, parse(Float64, i[2]))
        try
            push!(e_magnitude, parse(Float64, i[3]))
            push!(upperlimit, false)
        catch e
            push!(e_magnitude, -1.0)
            push!(upperlimit, true)
        end
        push!(band, i[5])
        push!(instrument, i[6])
        push!(telescope, i[7])
        push!(source, i[8])
    end
    return DataFrame(time=time, magnitude=magnitude, e_magnitude=e_magnitude, upperlimit=upperlimit, band=band, instrument=instrument, telescope=telescope, source=source)
end
