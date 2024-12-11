struct BranchPoint
    results::Dict{Tuple{Int32,Int32},Nothing}
    count::Int32
end

function day10()
    topomap = begin
        lines = readlines("data/day10.txt")
        topomap = zeros(Int32, length(lines), length(lines[1]))
        for (i, line) ∈ enumerate(lines)
            for (j, c) ∈ enumerate(line)
                topomap[i, j] = parse(Int32, c)
            end
        end
        topomap
    end

    function propogate(topomap, result, i, j)
        val = topomap[i, j]
        if val == 9
            result[i,j] = BranchPoint(Dict{Tuple{Int32,Int32},Nothing}([(i,j) => nothing]),1)
            return
        end
        dict = Dict{Tuple{Int32,Int32},Nothing}()
        count = 0
        for (x,y) ∈ [[1,0],[0,1],[-1,0],[0,-1]]
            if checkbounds(Bool, topomap, i+x, j+y)
                if topomap[i+x, j+y] == val+1
                    propogate(topomap, result, i+x, j+y)
                    r = result[i+x, j+y]
                    for (k,v) ∈ r.results
                        dict[k] = v
                    end
                    count += r.count
                end
            end
        end
        result[i,j] = BranchPoint(dict,count)
    end

    function part1()
        trailheads = Matrix{Union{Nothing, BranchPoint}}(nothing, size(topomap))
        sum = 0
        for idx ∈ CartesianIndices(topomap)
            if topomap[idx] == 0
                propogate(topomap, trailheads, idx[1], idx[2])
                sum += length(trailheads[idx].results)
            end
        end

        println("Part 1: $sum")
    end

    @time part1()

    function part2()
        trailheads = Matrix{Union{Nothing, BranchPoint}}(nothing, size(topomap))
        sum = 0
        for idx ∈ CartesianIndices(topomap)
            if topomap[idx] == 0
                propogate(topomap, trailheads, idx[1], idx[2])
                sum += trailheads[idx].count
            end
        end

        println("Part 2: $sum")
    end

    @time part2()
end