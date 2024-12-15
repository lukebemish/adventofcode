using Statistics

day14() = begin
    lines = readlines("data/day14.txt")

    solve(width, height, time) = begin
        robotvals = [map(match(r"^p=(-?[0-9]+),(-?[0-9]+) v=(-?[0-9]+),(-?[0-9]+)$", line)) do i parse(Int, i) end for line in lines]
        [[mod(px + (time * vx), width), mod(py + (time * vy), height)] for (px, py, vx, vy) in robotvals]
    end

    safetyscore(width, height, finalvals) = begin
        midpoint = div(width-1,2), div(height-1,2)
        product = 1
        for a ∈ (<, >), b ∈ (<, >)
            product *= count(finalvals) do (x, y) a(x, midpoint[1]) && b(y, midpoint[2]) end
        end
        product
    end

    neighborscore(width, height, finalvals) = begin
        plotted = zeros(Int, height, width)
        mx = 0
        my = 0
        for (x, y) ∈ finalvals
            mx += x
            my += y
        end
        mx = div(mx, length(finalvals))
        my = div(my, length(finalvals))
        total = 0
        for (x, y) ∈ finalvals
            total += (x - mx)^2
            total += (y - my)^2
        end
        total
    end

    plot(width, height, finalvals) = begin
        plotted = zeros(Int, height, width)
        for (x, y) ∈ finalvals
            plotted[y+1, x+1] += 1
        end
        for y ∈ 1:height
            println(join(plotted[y, :], ""))
        end
    end

    @time begin
        println("Part 1: $(safetyscore(101, 103, solve(101, 103, 100)))")
    end

    @time begin
        width = 101
        height = 103
        tilltime = lcm(101, 103)
        values = zeros(Float64, tilltime)
        Threads.@threads for time ∈ 1:tilltime
            values[time] = neighborscore(width, height, solve(width, height, time))
        end
        treetime = argmin(values)
        println("Part 2: $treetime")
        plot(width, height, solve(width, height, treetime))
    end
end