day13() = begin
    lines = readlines("data/day13.txt")
    
    solve(part2) = begin
        total = 0

        for i ∈ 1:div(length(lines)+1, 4)
            a = map(match(r"Button A: X\+([0-9]+), Y\+([0-9]+)", lines[i*4-3])) do i parse(Int, i) end
            b = map(match(r"Button B: X\+([0-9]+), Y\+([0-9]+)", lines[i*4-2])) do i parse(Int, i) end
            target = map(match(r"Prize: X=([0-9]+), Y=([0-9]+)", lines[i*4-1])) do i parse(Int, i) end
            if part2
                target .+= 10000000000000
            end

            mat = hcat(a, b)
            solution = Int.(round.(mat \ target))
            if target == mat * solution
                total += solution[1]*3 + solution[2]
            end
        end

        total
    end

    @time begin
        println("Part 1: $(solve(false))")
    end

    @time begin
        println("Part 2: $(solve(true))")
    end
end
