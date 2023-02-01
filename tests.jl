

using BenchmarkTools
using Disko
include("src/mergesort.jl")

# function main() 
   
#     h1 = open("test1.bin","w+")
#     h2 = open("test2.bin","w+")

#     m1 = mmap(h1, Vector{Int64}, 5)
#     m2 = mmap(h2, Vector{Int64}, 5)

#     m1 .= [1,2,10,11,70] #sort!(rand(Int64, 5))
#     m2 .= [5, 8, 100, 200, 800] #sort!(rand(Int64, 5))

#     close(h1)
#     close(h2)

#     kway_file_merge(["test1.bin", "test2.bin"], "merged.bin", Int64)

#     out_m = mmap(open("merged.bin"), Vector{Int64}, 10)
#     println(out_m)

# end

# function benchmark(n::Int, n_numbers::Int)

#     files = Vector{String}(undef, n)

#     for i in 1:n 100_000
#         m = mmap(h, Vector{Int64}, n_numbers)
#         m .= sort!(rand(Int64, n_numbers))
#         close(h)
#     end

#     @btime kway_file_merge($files, "merged.bin", Int64, use_heap=false)

# end

# function disko_sort()
#     h = open("test1.bin", "w+")
#     write(h, 10)
#     write(h, 11)
#     write(h, 100)
#     close(h)

#     h = open("test2.bin", "w+")
#     write(h, 4)
#     write(h, 30)
#     write(h, 300)
#     close(h)

#     kway_disk_merge(["test1.bin", "test2.bin"], "out.bin", 8, Int64)
# end


function full_bench()
    # # Genereated three sorted arrays
    # arr1 = sort!(rand(Int64, 100_000))
    # arr2 = sort!(rand(Int64, 50_000))
    # arr3 = sort!(rand(Int64, 100_000))

    # # Write them to files
    # h1 = open("data/test1.bin", "w+")
    # h2 = open("data/test2.bin", "w+")
    # h3 = open("data/test3.bin", "w+")
    # write(h1, arr1)
    # write(h2, arr2)
    # write(h3, arr3)
    # close(h1)
    # close(h2)
    # close(h3)

    n = 5
    files = Vector{String}()
    arrs = Vector{Vector{Int64}}()
    for i in 1:n
      p = "data/test"*string(i)*".bin"
      #h = open(p, "w+")
      #r = sort!(rand(Int64, 100_000_000))
      #write(h, r)
      #close(h)
      push!(files, p)
      #push!(arrs, r)
    end

    # Run mmap merge sort 
    out_vector = Vector{Int64}(undef, n)
    #@time kway_merge(arrs, out_vector)
    #@btime kway_heap_merge($arrs, $out_vector)
    @time kway_mmap_merge(files, "data/mmap_res.bin", Int64)
    @time kway_disk_merge(files, "data/disko_res.bin", 10_000, Int64, use_heap=false)
    #@btime kway_mmap_merge($files, "data/mmap_res.bin", Int64, use_heap=true)
    #@btime kway_disk_merge($files, "data/disko_res.bin", 10_000, Int64, use_heap=true)


end

function still_working() 

  x = Int64[1,2,10, 10]
  y = Int64[5, 5, 8, 10]

  numbers = [ [1,2,10], [2, 8, 100, 200] ]
  freq    = [ UInt8[], UInt8[10, 5, 9, 1] ]


  numbs, freqs = kway_frequency_merge( numbers, freq, "data/", freq_cut_off=10)
  println(numbs, " ", [Int(x) for x in freqs])

  #println(numb_v)
  #println([Int(x) for x in freq_v])

end


still_working()



# Major (requiring I/O) page faults: 261839
# Minor (reclaiming a frame) page faults: 154434
