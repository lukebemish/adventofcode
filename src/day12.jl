calculate(plots, part2) = begin
    regions = Dict{Int, Set{CartesianIndex{2}}}()
    regionnumbers = zeros(Int, size(plots))
    freenumber = 1
    for idx ∈ CartesianIndices(plots)
        a = idx + CartesianIndex(-1, 0)
        b = idx + CartesianIndex(0, -1)
        novel = true
        if checkbounds(Bool, plots, a)
            if plots[a] === plots[idx]
                regionnumbers[idx] = regionnumbers[a]
                novel = false
            end
        end
        if checkbounds(Bool, plots, b)
            if plots[b] === plots[idx]
                if !novel
                    aregions = pop!(regions, regionnumbers[a])
                    bregions = get!(regions, regionnumbers[b], Set{CartesianIndex{2}}())
                    for i ∈ aregions
                        regionnumbers[i] = regionnumbers[b]
                    end
                    union!(bregions, aregions)
                end
                regionnumbers[idx] = regionnumbers[b]
                novel = false
            end
        end
        if novel
            regionnumbers[idx] = freenumber
            freenumber += 1
            regions[regionnumbers[idx]] = Set([idx])
        else
            push!(regions[regionnumbers[idx]], idx)
        end
    end

    total = 0

    for region ∈ keys(regions)
        aedges = zeros(Bool, size(plots) .+ (1,0))
        bedges = zeros(Bool, size(plots) .+ (0,1))

        adir = zeros(Bool, size(plots) .+ (1,0))
        bdir = zeros(Bool, size(plots) .+ (0,1))

        invert(m, d, idx, dir) = begin
            m[idx] = !m[idx]
            d[idx] = dir
        end

        for idx ∈ regions[region]
            invert(aedges, adir, idx, true)
            invert(aedges, adir, idx + CartesianIndex(1, 0), false)
            invert(bedges, bdir, idx, true)
            invert(bedges, bdir, idx + CartesianIndex(0, 1), false)
        end

        if part2
            area = length(regions[region])
            sides = 0
            for (row, rowd) ∈ zip(eachrow(aedges), eachrow(adir))
                last = false
                lastdir = false
                for (x, dir) ∈ zip(row, rowd)
                    if x
                        if !last || lastdir != dir
                            sides += 1
                        end
                        lastdir = dir
                        last = true
                    else
                        last = false
                    end
                end
            end
            for (col, cold) ∈ zip(eachcol(bedges), eachcol(bdir))
                last = false
                lastdir = false
                for (x, dir) ∈ zip(col, cold)
                    if x
                        if !last || lastdir != dir
                            sides += 1
                        end
                        lastdir = dir
                        last = true
                    else
                        last = false
                    end
                end
            end

            total += area * sides
        else
            total += (sum(aedges) + sum(bedges)) * length(regions[region])
        end
    end

    total
end

calculatefloodfill(plots, part2) = begin
    total = 0
    visited = zeros(Bool, size(plots))

    rotate(idx) = CartesianIndex(idx[2], -idx[1])

    for idx ∈ CartesianIndices(plots)
        if !visited[idx]
            type = plots[idx]
            area = 0
            count = 0
            flood(pos) = begin
                if !visited[pos]
                    if !visited[pos] && plots[pos] === type
                        visited[pos] = true
                        area += 1
                        if part2
                            first = CartesianIndex(0, 1)
                            diag = CartesianIndex(1, 1)
                            second = CartesianIndex(1, 0)
                            for _ ∈ 1:4
                                first = rotate(first)
                                diag = rotate(diag)
                                second = rotate(second)

                                isfirst = checkbounds(Bool, plots, pos .+ first) && plots[pos .+ first] === type
                                isdiag = checkbounds(Bool, plots, pos .+ diag) && plots[pos .+ diag] === type
                                issecond = checkbounds(Bool, plots, pos .+ second) && plots[pos .+ second] === type

                                if isfirst && issecond && !isdiag
                                    count += 1
                                elseif !isfirst && !issecond
                                    count += 1
                                end
                            end
                        else
                            offset = CartesianIndex(0, 1)
                            for _ ∈ 1:4
                                offset = rotate(offset)
                                nidx = pos .+ offset
                                if !checkbounds(Bool, plots, nidx) || plots[nidx] !== type
                                    count += 1
                                end
                            end
                        end
                        offset = CartesianIndex(0, 1)
                        for _ ∈ 1:4
                            offset = rotate(offset)
                            nidx = pos .+ offset
                            if checkbounds(Bool, plots, nidx)
                                flood(nidx)
                            end
                        end
                    end
                end
            end
            flood(idx)
            total += area * count
        end
    end

    return total
end

day12() = begin
    plots = permutedims(reduce(hcat, map(readlines("data/day12.txt")) do line begin [Symbol(c) for c ∈ line] end end))

    @time begin
        println("Part 1: $(calculate(plots, false))")
    end

    @time begin
        println("Part 2: $(calculate(plots, true))")
    end

    @time begin
        println("Part 1 (floodfill): $(calculatefloodfill(plots, false))")
    end

    @time begin
        println("Part 2 (floodfill): $(calculatefloodfill(plots, true))")
    end
end
