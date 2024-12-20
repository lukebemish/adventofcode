mutable struct Tree
    point::Bool
    children::Dict{Char, Tree}
end

day19() = begin
    lines = readlines("data/day19.txt")
    towels = split(replace(lines[1], " " => ""), ",")
    patterns = lines[3:end]

    roottree = begin
        tree = Tree(false, Dict{Char, Tree}())
        for towel ∈ towels
            current = tree
            for c ∈ towel
                if haskey(current.children, c)
                    current = current.children[c]
                else
                    current.children[c] = Tree(false, Dict{Char, Tree}())
                    current = current.children[c]
                end
            end
            current.point = true
        end
        tree
    end

    arrangements = Dict{String, Int}()

    findmatch(pattern) = begin
        if haskey(arrangements, pattern)
            return arrangements[pattern]
        end
        patternlength = length(pattern)
        if patternlength == 0
            return 1
        end
        current = roottree
        count = 1
        counts = []
        while !isnothing(current)
            if current.point
                push!(counts, count)
            end
            if count > patternlength
                break
            end
            current = get(current.children, pattern[count], nothing)
            count += 1
        end
        arrangementcount = 0
        for c ∈ reverse(counts)
            arrangementcount += findmatch(@views pattern[c:end])
        end
        arrangements[pattern] = arrangementcount
        return arrangementcount
    end

    @time begin
        matches = zeros(Bool, length(patterns))
        arrangementcounts = zeros(Int, length(patterns))
        for i ∈ 1:length(patterns)
            arrangementcount = findmatch(patterns[i])
            matches[i] = arrangementcount > 0
            arrangementcounts[i] = arrangementcount
        end
        println("Part 1: $(sum(matches))")
        println("Part 2: $(sum(arrangementcounts))")
    end
end