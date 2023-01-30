## DISKMERGE - mergesort disk arrays

**Own usage**; this is far from fully implemented but currently supports [k-way merge sorts ](https://en.wikipedia.org/wiki/K-way_merge_algorithm "k-way merge sorts ")from `mmap`s and `diskVectors`(from [Disko](https://github.com/rickbeeloo/Disko)). Aside from a naive k-way merge this also allows merge sort using a [binaryheap](https://en.wikipedia.org/wiki/K-way_merge_algorithm#Heap "binaryheap"). Technically this should be faster, however it does not seem to outperform naive k-way sort - at least not for 

`add https://github.com/rickbeeloo/DiskMergeSort`

---

#### How to use 
```Julia
    files = ["data1.bin", "data2.bin", "data3.bin"]
    kway_mmap_merge(files, "out.bin", Int64)
    kway_disk_merge(files, "out.bin", 10_000, Int64)
    kway_mmap_merge(files, "out.bin", Int64, use_heap=true)
    kway_disk_merge(files, "out.bin", 10_000, Int64, use_heap=true)
```
here `10_000` is the buffer size passed to [Disko](https://github.com/rickbeeloo/Disko). `use_heap` is false by default, when true this will use the Julia minBinaryHeap. 

| Function  | @btime result  |
| ------------ | ------------ |
| mmap  |  1.005 ms (108 allocations: 788.77 KiB)  |
| disko  |  2.281 ms (104 allocations: 1.58 MiB) |
| mmap (heap)  |   2.603 ms (108 allocations: 7.73 KiB)  |
| disko (heap)  |  2.709 ms (104 allocations: 838.42 KiB) |

Probably disko will improve when I improve that :) 
