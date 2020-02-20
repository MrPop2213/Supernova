struct SNE_SPACE
end

function load_supernova(file_name::String, source::Type{SNE_SPACE})
    raw = readlines(file_name)
    @show raw[1]
end