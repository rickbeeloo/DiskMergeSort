
using DataStructures # For binary heap
using Mmap
using Disko

function kway_merge(vecs::Union{AbstractVector{Vector{T}}, AbstractVector{Disko.DiskoVector}}, output::AbstractVector{T}) where T <: Integer
    # Create an array of indices, one for each input vector
    indices =  ones(Int64, length(vecs)) 
    type_max = @inbounds typemax(eltype(vecs[1]))
    output_idx = 1

    @inbounds while true
        # Find the next smallest element across all input vectors
        min_val = type_max
        min_vec_idx = 0

        for i in eachindex(vecs)
            if indices[i] <= length(vecs[i]) && vecs[i][indices[i]] <= min_val
                min_val = vecs[i][indices[i]]
                min_vec_idx = i
            end
        end
        
        # We are done 
        min_val == type_max && break
        
        # Add the smallest element to the output vector
        output[output_idx] = min_val
        output_idx += 1

        # Increment the index for the input vector that contained the smallest element
        indices[min_vec_idx] += 1
    end
end

function kway_heap_merge(vecs::Union{AbstractVector{Vector{T}}, AbstractVector{Disko.DiskoVector}}, output::AbstractVector{T}) where T <: Integer
    # Create a min heap to store the smallest element from each input vector
    heap = DataStructures.BinaryMinHeap{Tuple{Int, Int, Int}}()
    # Add first elements to binary heap
    @inbounds for i in eachindex(vecs)
        push!(heap, (vecs[i][1], i, 1))
    end

    output_idx = 1
    @inbounds while length(heap) > 0
        # Get the smallest element from the heap
        min_val, min_vec_idx, min_vec_elem_idx = pop!(heap)
        output[output_idx] = min_val
        output_idx += 1

        # If there are more elements in the input vector, add the next one to the heap
        next_loc = min_vec_elem_idx + 1
        if  next_loc <= length(vecs[min_vec_idx])
            push!(heap, (vecs[min_vec_idx][next_loc], min_vec_idx, next_loc))
        end
    end

end

# Overload of method below to also directly allow passing mmaps
function kway_mmap_merge(maps::AbstractVector{Vector{Int64}}, output_file::String; use_heap::Bool = false) where T <:DataType
    # We calculate the mmap size based on the provided type variable
    total_size = sum(map(length, maps))
    # Allocate the output size
    out_handle = open(output_file, "w+")
    out_map = @inbounds mmap(out_handle, Vector{eltype(maps[1])}, total_size)
    # Now use the kway_merge to join the data 
    use_heap ? kway_heap_merge(maps, out_map) : kway_merge(maps, out_map)
    close(out_handle)
    return out_map
end

function kway_mmap_merge(files::Vector{String}, output_file::String, type::T ; use_heap::Bool = false) where T <:DataType
    # Check if these are all files 
    all(map(isfile, files)) || error("Not file names")
    # Mmap the inputs 
    handles = [open(f,"r") for f in files]
    # We calculate the mmap size based on the provided type variable
    sizes = [Int64(filesize(f)/sizeof(type)) for f in files]
    total_size = sum(sizes)
    maps = [mmap(handles[i], Vector{type}, sizes[i]) for i in eachindex(files)]
    # Allocate the output size
    out_handle = open(output_file, "w+")
    out_map = mmap(out_handle, Vector{type}, total_size)
    # Now use the kway_merge to join the data 
    use_heap ? kway_heap_merge(maps, out_map) : kway_merge(maps, out_map)
    map(close, handles)
    close(out_handle)
    return total_size
end

function kway_disk_merge(files::Vector{String}, output_file::String, buffer_size::Int, type::DataType; use_heap::Bool = false)
    # Create a list of Disko vectors 
    disko_vectors = [diskVector(f, buffer_size) for f in files]
    # Create the output array 
    out_handle = open(output_file, "w+")
    out_map = mmap(out_handle, Vector{type}, sum(map(length, disko_vectors)))
    use_heap ? kway_heap_merge(disko_vectors, out_map) : kway_merge(disko_vectors, out_map)
    close(out_handle)
end

