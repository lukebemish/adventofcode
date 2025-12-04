day3() = @time begin
    readinput() = (map(c for c ∈ line) do i
            parse(Int, i)
        end
    for line ∈ readlines("data/day3.txt"))

    @time begin
        println("Part 1: $(
            sum(begin
                maxval, maxidx = findmax(line)
                if maxidx != length(line)
                    maxval * 10 + maximum(view(line, maxidx+1:length(line)))
                else
                    maximum(view(line, 1:length(line) - 1)) * 10 + maxval
                end
            end for line ∈ readinput())
        )")
    end

    @time begin
        println("Part 2: $(
            sum(begin
                working = line
                v = 0
                for i ∈ 1:12
                    maxval, maxidx = findmax(view(working, 1:length(working)-(12-i)))
                    v = v*10+maxval
                    working = view(working, maxidx+1:length(working))
                end
                v
            end for line ∈ readinput())
        )")
    end
end
