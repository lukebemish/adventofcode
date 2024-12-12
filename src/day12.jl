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

day12() = begin
    plots = permutedims(reduce(hcat, map(readlines("data/day12.txt")) do line begin [Symbol(c) for c ∈ line] end end))

    @time begin
        println("Part 1: $(calculate(plots, false))")
    end

    @time begin
        println("Part 2: $(calculate(plots, true))")
    end
end
