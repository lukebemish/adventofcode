part1(plots) = begin
    perimiters = Int[]
    identities = Dict{Int, Set{Int}}()
    regionnumbers = zeros(Int, size(plots))
    freenumber = 1
    for idx ∈ CartesianIndices(plots)
        type = plots[idx]
        pointperimiter = 4
        regionnumber = 0
        left = idx + CartesianIndex(-1, 0)
        up = idx + CartesianIndex(0, -1)
        if checkbounds(Bool, plots, left)
            if plots[left] === type
                pointperimiter -= 2
                regionnumber = regionnumbers[left]
            end
        end
        if checkbounds(Bool, plots, up)
            if plots[up] === type
                pointperimiter -= 2
                if regionnumber != 0 && regionnumber != regionnumbers[up]
                    total = union(
                        get!(identities, regionnumber, Set([regionnumber])),
                        get!(identities, regionnumbers[up], Set([regionnumbers[up]]))
                    )
                    for i ∈ total
                        identities[i] = total
                    end
                end
                regionnumber = regionnumbers[up]
            end
        end
        if regionnumber == 0
            regionnumber = freenumber
            freenumber += 1
            push!(perimiters, 0)
        end
        regionnumbers[idx] = regionnumber
        perimiters[regionnumber] += pointperimiter
    end

    prices = 0
    for idx ∈ eachindex(regionnumbers)
        region = regionnumbers[idx]
        for x ∈ get(identities, region, [region])
            prices += perimiters[x]
        end
    end

    println("Part 1: $prices")
end

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