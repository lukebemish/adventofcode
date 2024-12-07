function day7()
    input = map(readlines("data/day7.txt")) do line
        parts = split(line, " ")
        parts[1] = parts[1][1:end-1]
        map(parts) do part parse(Int, part) end
    end

    function part1()
        total = 0
        for line ∈ input
            target = line[1]
            rest = line[2:end]
            for i ∈ 0:2^(length(rest)-1)-1
                calculated = rest[1]
                x = i
                for j ∈ 2:length(rest)
                    if (x & 1) == 0
                        calculated += rest[j]
                    else
                        calculated *= rest[j]
                    end
                    if calculated > target
                        break
                    end
                    x >>= 1
                end
                if calculated == target
                    total += target
                    break
                end
            end
        end

        println("Part 1: $total")
    end

    @time part1()

    function part2()
        total = 0
        for line ∈ input
            target = line[1]
            rest = line[2:end]
            for i ∈ 0:3^(length(rest)-1)-1
                calculated = rest[1]
                x = i
                for j ∈ 2:length(rest)
                    if (x % 3) == 0
                        calculated += rest[j]
                    elseif (x % 3) == 1
                        calculated *= rest[j]
                    else
                        i = 1
                        next = rest[j]
                        while i <= next
                            i *= 10
                        end
                        calculated *= i
                        calculated += next
                    end
                    if calculated > target
                        break
                    end
                    x = div(x, 3)
                end
                if calculated == target
                    total += target
                    break
                end
            end
        end

        println("Part 2: $total")
    end

    @time part2()
end