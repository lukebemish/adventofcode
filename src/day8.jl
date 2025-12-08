day8(exampledata) = begin
    Pos = Tuple{Float64, Float64, Float64}

    readinput() = begin
        lines = readlines("data/day8.txt")
        map(lines) do line
            (map(split(line, ",")) do i parse(Float64, i) end...,) :: Pos
        end
    end

    mineach(positions) = (
        minimum([i[1] for i in positions]),
        minimum([i[2] for i in positions]),
        minimum([i[3] for i in positions]),
    )

    maxeach(positions) = (
        maximum([i[1] for i in positions]),
        maximum([i[2] for i in positions]),
        maximum([i[3] for i in positions]),
    )

    groupbystep(positions, stepsize) = begin
        lowest = mineach(positions)
        pieces = (maxeach(positions) .- lowest) .÷ stepsize .+ 1 .|> Int
        grid = Array{Vector{Int}, 3}(undef, pieces)
        for idx ∈ eachindex(grid)
            grid[idx] = Int[]
        end
        for (i, pos) ∈ enumerate(positions)
            indices = ((pos .- lowest) .÷ stepsize .+ 1) .|> Int
            push!(grid[indices...], i)
        end
        grid
    end

    mergeadjacent(groups) = begin
        newsize = (size(groups) .+ 1) .÷ 2
        grid = Array{Vector{Int}, 3}(undef, newsize)
        for idx ∈ eachindex(grid)
            grid[idx] = Int[]
        end
        for idx ∈ CartesianIndices(groups)
            newidx = ((Tuple(idx) .- 1) .÷ 2) .+ 1
            append!(grid[newidx...], groups[idx]...)
        end
        grid
    end

    @time begin
        positions = readinput()
        target = exampledata ? 10 : 1000
        groupcount = 0
        totalconnections = 0
        connections = zeros(Int, length(positions))
        lastmaxdist = 0
        stepsize = exampledata ? 10.0 : 1000.0
        groupedpositions = groupbystep(positions, stepsize)
        remaining = length(positions)
        while remaining > 1
            distances = Dict{Pair{Int, Int}, Float64}()
            mindist = stepsize .^ 2
            for idx ∈ CartesianIndices(groupedpositions)
                here = Tuple(idx)
                left = max.(here .- 1, (1, 1, 1))
                right = min.(here .+ 1, size(groupedpositions))
                ranges = (:).(left, right)
                for i ∈ groupedpositions[idx]
                    for j ∈ vcat(groupedpositions[ranges...]...)
                        if i >= j || haskey(distances, Pair(j, i))
                            continue
                        end
                        dist = sum((positions[i] .- positions[j]) .^ 2)
                        if dist <= mindist && dist > lastmaxdist
                            distances[Pair(i, j)] = dist
                        end
                    end
                end
            end
            for (pair, _) ∈ sort(collect(distances), by = x -> x[2])
                group1, group2 = connections[pair.first], connections[pair.second]
                totalconnections += 1
                if group1 == 0 && group2 == 0
                    groupcount += 1
                    connections[pair.first] = groupcount
                    connections[pair.second] = groupcount
                    remaining -= 1
                elseif group1 != 0 && group2 == 0
                    connections[pair.second] = group1
                    remaining -= 1
                elseif group1 == 0 && group2 != 0
                    connections[pair.first] = group2
                    remaining -= 1
                elseif group1 != group2
                    connections[connections .== group2] .= group1
                    remaining -= 1
                end
                if totalconnections == target
                    groups = sort([i => sum(connections .== i) for i ∈ 1:groupcount], by = x -> x[2], rev = true)
                    println("Part 1: $(prod(groups[1:3] .|> x -> x[2]))")
                end
                if remaining == 1
                    println("Part 2: $(Int(positions[pair.first][1] * positions[pair.second][1]))")
                    break
                end
            end
            lastmaxdist = mindist
            stepsize *= 2
            groupedpositions = mergeadjacent(groupedpositions)
        end
    end
end