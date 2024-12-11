@enum DigitCountMode CountByString CountByLog10 CountByLoop

evenpair(n::Int, with1, with2, ::Val{CountByString}) = begin
    s = string(n)
    l = length(s)
    if (l & 1) != 0
        with1(n)
    else
        left = parse(Int, s[1:div(l, 2)])
        right = parse(Int, s[div(l, 2) + 1:end])
        with2(left, right)
    end
end

evenpair(n::Int, with1, with2, ::Val{CountByLog10}) = begin
    if log10(n) % 2 >= 1
        factor = Int(10 ^ (div(log10(n), 2)+1))
        with2(div(n, factor), rem(n, factor))
    else
        with1(n)
    end
end

evenpair(n::Int, with1, with2, ::Val{CountByLoop}) = begin
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
        with2(div(n, halfm), rem(n, halfm))
    else
        with1(n)
    end
end

calculatecount(n::Int, time::Int, cache::Dict{Tuple{Int, Int}, Int}, evencountmethod) = begin
    if time == 0
        return 1
    elseif (n, time) ∈ keys(cache)
        return cache[(n, time)]
    else
        result = begin
            if n == 0
                calculatecount(1, time - 1, cache, evencountmethod)
            else
                evenpair(n,
                    v -> calculatecount(v * 2024, time - 1, cache, evencountmethod),
                    (l, r) -> calculatecount(l, time - 1, cache, evencountmethod) + calculatecount(r, time - 1, cache, evencountmethod),
                    evencountmethod
                )
            end
        end
        cache[(n, time)] = result
        return result
    end
end

totalcount(time, stones, evencountmethod) = begin
    count = 0
    cache = Dict{Tuple{Int, Int}, Int}()
    for stone ∈ stones
        count += calculatecount(stone, time, cache, evencountmethod)
    end
    return count
end

day11() = begin
    stones = map(split(readlines("data/day11.txt")[1], " ")) do s parse(Int, s) end

    @time begin
        println("Part 1: $(totalcount(25, stones, Val(CountByLoop)))")
    end

    @time begin
        println("Part 2: $(totalcount(75, stones, Val(CountByLoop)))")
    end

    @time begin
        println("Count by string: $(totalcount(75, stones, Val(CountByString)))")
    end

    @time begin
        println("Count by log10: $(totalcount(75, stones, Val(CountByLog10)))")
    end

    @time begin
        println("Count by loop: $(totalcount(75, stones, Val(CountByLoop)))")
    end
end

