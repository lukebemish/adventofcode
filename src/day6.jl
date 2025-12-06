day6() = begin
    readinput() = begin
        lines = readlines("data/day6.txt")
        zippedparts = collect(zip((collect(line) for line ∈ lines[1:length(lines)-1])...))
        spaces = findall(x -> all(y -> y == ' ', x), zippedparts)
        parts = [zippedparts[a:b] for (a, b) ∈ zip([1, spaces .+ 1...], [spaces .- 1..., length(zippedparts)])]
        operators = [i == "*" ? (*) : (+) for i ∈ split(strip(lines[end]), r"\s+")]
        parts, operators
    end

    @time begin
        partstrings, operators = readinput()
        
        println("Part 1: $(
            sum(o((parse(Int, (*)(cs...)) for cs in zip(xs...))...) for (xs, o) ∈ zip(partstrings, operators))
        )")
    end

    @time begin
        partstrings, operators = readinput()
        
        println("Part 2: $(
            sum(o((parse(Int, (*)(cs...)) for cs in xs)...) for (xs, o) ∈ zip(partstrings, operators))
        )")
    end
end