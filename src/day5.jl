day5() = @time begin
    readinput() = begin
        lines = readlines("data/day5.txt")
        emptyline = findfirst(isequal(""), lines)
        rangelines = lines[1:emptyline-1]
        availablelines = lines[emptyline+1:end]
        (map(rangelines) do line
            parts = split(line, "-")
            (parse(Int, parts[1]), parse(Int, parts[2]))
        end, map(availablelines) do line
            parse(Int, line)
        end)
    end

    rangecheck(number, ranges) = begin
        for (low, high) in ranges
            if low <= number <= high
                return true
            end
        end
        return false
    end

    @time begin
        ranges, available = readinput()
        println("Part 1: $(count(i -> rangecheck(i, ranges), available))")
    end

    @time begin
        ranges, available = readinput()
        sortedranges = sort(ranges, by = x -> x[1])
        clow, chigh = -1, -1
        mergedranges = Tuple{Int, Int}[]
        for (low, high) in sortedranges
            if low > chigh + 1
                if chigh > 0
                    push!(mergedranges, (clow, chigh))
                end
                clow, chigh = low, high
            else
                chigh = max(chigh, high)
            end
        end
        push!(mergedranges, (clow, chigh))
        total = 0
        for (low, high) in mergedranges
            total += high - low + 1
        end
        println("Part 2: $total")
    end
end