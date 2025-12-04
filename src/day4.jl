day4() = @time begin
    readinput() = begin
        lines = readlines("data/day4.txt")
        matrix = zeros(Bool, length(lines), length(lines[1]))
        for (i, line) ∈ enumerate(lines)
            for (j, c) ∈ enumerate(line)
                matrix[i, j] = c == '@'
            end
        end
        matrix
    end

    offsets = []
    for i ∈ -1:1
        for j ∈ -1:1
            if i == 0 && j == 0
                continue
            end
            push!(offsets, (i, j))
        end
    end

    removerolls(rolls) = begin
        neighborscount = copy(rolls) * 4
        for (di, dj) ∈ offsets
            neighborscount[1+max(0, di):end+min(0, di), 1+max(0, dj):end+min(0, dj)] .-=
                rolls[1+max(0, -di):end+min(0, -di), 1+max(0, -dj):end+min(0, -dj)]
        end
        total = sum(neighborscount .> 0)
        rolls[neighborscount .> 0] .= false
        return total
    end

    @time begin
        rolls = readinput()
        println("Part 1: $(removerolls(rolls))")
    end

    @time begin
        rolls = readinput()
        running = 0
        while true
            removed = removerolls(rolls)
            running += removed
            if removed == 0
                break
            end
        end
        println("Part 2: $running")
    end
end
