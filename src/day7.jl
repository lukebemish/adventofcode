input = map(readlines("data/day7.txt")) do line
    parts = split(line, " ")
    parts[1] = parts[1][1:end-1]
    map(parts) do part parse(Int, part) end
end

## Part 1

total = 0
for line ∈ input
    target = line[1]
    rest = line[2:end]
    for i ∈ 0:2^(length(rest)-1)-1
        calculated = rest[1]
        x = i
        for j ∈ 2:length(rest)
            if (x & 1) == 1
                calculated += rest[j]
            else
                calculated *= rest[j]
            end
            x >>= 1
        end
        if calculated == target
            total += target
            break
        end
    end
end

## Part 2

total = 0
for line ∈ input
    target = line[1]
    rest = line[2:end]
    for i ∈ 0:3^(length(rest)-1)-1
        calculated = rest[1]
        x = i
        for j ∈ 2:length(rest)
            if (x % 3) == 1
                calculated += rest[j]
            elseif (x % 3) == 2
                calculated *= rest[j]
            else
                calculated *= 10^length(string(rest[j]))
                calculated += rest[j]
            end
            x = div(x, 3)
        end
        if calculated == target
            total += target
            break
        end
    end
end

##