## DISKMERGE - mergesort disk arrays

**Own usage**; this is far from fully implemented but currently supports [k-way merge sorts ](https://en.wikipedia.org/wiki/K-way_merge_algorithm "k-way merge sorts ")from `mmap`s and `diskVectors`(from [Disko](https://github.com/rickbeeloo/Disko)). Aside from a naive k-way merge this also allows merge sort using a [binaryheap](https://en.wikipedia.org/wiki/K-way_merge_algorithm#Heap "binaryheap"). Technically this should be faster, however it does not seem to outperform naive k-way sort - at least not for the benchmark below

`add https://github.com/rickbeeloo/DiskMergeSort`

---

#### How to use 
```Julia
    files = ["data1.bin", "data2.bin", "data3.bin"] 
    kway_mmap_merge(files, "out.bin", Int64)
    kway_disk_merge(files, "out.bin", 10_000, Int64)
    kway_mmap_merge(files, "out.bin", Int64, use_heap=true)
    kway_disk_merge(files, "out.bin", 10_000, Int64, use_heap=true) 

    numbers = [ [1,2,10], [2, 8, 100, 200] ]
    freqs    = [ UInt8[], UInt8[10, 5, 9, 1] ]
    kway_frequency_merge(files, "tmp/", Int64, freq_cut_off = 10 )
    kway_frequency_merge(numbers, freqs, "tmp/", freq_cut_off = 10 ) 
    # [1, 8, 10, 100, 200]  numbers
    # [1, 5, 1, 9, 1]       frequencies, 2 got filered out 11 > 10
```
here `10_000` is the buffer size passed to [Disko](https://github.com/rickbeeloo/Disko). `use_heap` is false by default, when true this will use the Julia minBinaryHeap. `kway_frequency_merge` is a **special implementation** as I discussed [here](https://cs.stackexchange.com/questions/157084/data-structure-to-estimate-the-frequency-of-low-frequency-elements "here"). It uses a merge sort to find low frequency numbers in a collection of vectors. In other words, it filters out numbers with a frequency `<cut-off` while merging the arrays. This is much more cache-friendly than hashing, like hashmap counters, to achieve the same result. Now also support passing with existing frequency vectors - nice to accumulate over threads.


----
#### Some timings 
This benchmark was for 5 files with `20000` integers each.
Probably disko will improve when I improve that :) 

| Function  | @btime result  |
| ------------ | ------------ |
| mmap  |  1.005 ms (108 allocations: 788.77 KiB)  |
| disko  |  2.281 ms (104 allocations: 1.58 MiB) |
| mmap (heap)  |   2.603 ms (108 allocations: 7.73 KiB)  |
| disko (heap)  |  2.709 ms (104 allocations: 838.42 KiB) |



