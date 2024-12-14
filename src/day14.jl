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
        for (x, y) in finalvals
            plotted[y+1, x+1] += 1
        end
        score = 0
        kernel = [
            1 1 1;
            1 0 1;
            1 1 1
        ]
        for (x, y) in finalvals
            surroundings = plotted[mod.(y-1:y+1, height) .+ 1, mod.(x-1:x+1, width) .+ 1]
            score += sum(surroundings .* kernel)
        end
        score
    end

    plot(width, height, finalvals) = begin
        plotted = zeros(Int, height, width)
        for (x, y) in finalvals
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
        values = [neighborscore(width, height, solve(width, height, time)) for time ∈ 1:tilltime]
        maxtime = argmax(values)
        println("Part 2: $maxtime")
        plot(width, height, solve(width, height, maxtime))
    end
end