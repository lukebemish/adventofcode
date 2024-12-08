function day8()
    (input, size) = let lines = readlines("data/day8.txt")
        antennae = Dict{Char,Vector{Tuple{Int,Int}}}()
        for (x,line) ∈ enumerate(lines)
            for (y,c) ∈ enumerate(line)
                if c != '.'
                    push!(get!(antennae, c, Tuple{Int,Int}[]), (x,y))
                end
            end
        end
        antennae, (length(lines), length(lines[1]))
    end

    function countnodes(ispart1)
        antinodes = zeros(Bool, size)
        for (_, positions) ∈ input
            for a ∈ positions, b ∈ positions
                if a != b
                    delta = b .- a
                    if ispart1
                        n1 = b .+ delta
                        n2 = a .- delta
                        if checkbounds(Bool, antinodes, n1...)
                            antinodes[n1...] = true
                        end
                        if checkbounds(Bool, antinodes, n2...)
                            antinodes[n2...] = true
                        end
                    else
                        p = a
                        while checkbounds(Bool, antinodes, p...)
                            antinodes[p...] = true
                            p = p .- delta
                        end
                        p = b
                        while checkbounds(Bool, antinodes, p...)
                            antinodes[p...] = true
                            p = p .+ delta
                        end
                    end
                end
            end
        end

        sum(antinodes)
    end

    function part1()
        total = countnodes(true)
        println("Part 1: $total")
    end

    @time part1()

    function part2()
        total = countnodes(false)
        println("Part 2: $total")
    end

    @time part2()
end
