using Pkg
Pkg.activate(".")

##

safecount = 0
for line in readlines("data/day2.txt")
    levels = map(split(line, " ")) do j parse(Int, j) end
    current = levels[1]
    increasing = true
    decreasing = true
    safe = true
    for level in levels[2:end]
        diff = level - current
        if diff < 0
            increasing = false
            if !decreasing || diff < -3
                safe = false
                break
            end
        elseif diff > 0
            decreasing = false
            if !increasing || diff > 3
                safe = false
                break
            end
        else
            safe = false
            break
        end
        current = level
    end
    if safe
        safecount += 1
    end
end

println("Part 1: $safecount")

##

safecount = 0
for line in readlines("data/day2.txt")
    fulllevels = map(split(line, " ")) do j parse(Int, j) end
    for i ∈ 1:length(fulllevels)
        levels = fulllevels[1:length(fulllevels) .!= i]
        current = levels[1]
        increasing = true
        decreasing = true
        safe = true
        for level in levels[2:end]
            diff = level - current
            if diff < 0
                increasing = false
                if !decreasing || diff < -3
                    safe = false
                    break
                end
            elseif diff > 0
                decreasing = false
                if !increasing || diff > 3
                    safe = false
                    break
                end
            else
                safe = false
                break
            end
            current = level
        end
        if safe
            safecount += 1
            break
        end
    end
end

println("Part 2: $safecount")