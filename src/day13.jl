day13() = begin
    lines = readlines("data/day13.txt")
    
    solve(part2) = begin
        total = 0

        for i ∈ 1:div(length(lines)+1, 4)
            interpret(t) = map(split(replace(t, r"[^0-9,]" => ""), ',')) do i parse(Int, i) end

            a = interpret(lines[i*4-3])
            b = interpret(lines[i*4-2])
            target = interpret(lines[i*4-1])
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
