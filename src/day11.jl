calculatecount(n::Int, time::Int, cache::Dict{Tuple{Int, Int}, Int}) = begin
    if time == 0
        return 1
    elseif (n, time) ∈ keys(cache)
        return cache[(n, time)]
    else
        result = begin
            if n == 0
                calculatecount(1, time - 1, cache)
            else
                m = 10
                even = false
                halfm = 10
                while m <= n
                    nextodd = m * 10
                    if nextodd > n
                        even = true
                        break
                    end
                    halfm *= 10
                    m = nextodd * 10
                end
                if even
                    calculatecount(div(n, halfm), time - 1, cache) + calculatecount(rem(n, halfm), time - 1, cache)
                else
                    calculatecount(n * 2024, time - 1, cache)
                end
            end
        end
        cache[(n, time)] = result
        return result
    end
end

totalcount(time, stones) = begin
    count = 0
    cache = Dict{Tuple{Int, Int}, Int}()
    for stone ∈ stones
        count += calculatecount(stone, time, cache)
    end
    return count
end

function day11()
    stones = map(split(readlines("data/day11.txt")[1], " ")) do s parse(Int, s) end

    @time begin
        println("Part 1: $(totalcount(25, stones))")
    end

    @time begin
        println("Part 2: $(totalcount(75, stones))")
    end
end

