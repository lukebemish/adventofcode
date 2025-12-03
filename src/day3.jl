day3() = begin
    readinput() = begin
        map(readlines("data/day3.txt")) do line
            map(collect(line)) do i parse(Int, i) end
        end
    end

    @time begin
        println("Part 1: $(
            sum(map(readinput()) do line
                maxval, maxidx = findmax(line)
                if maxidx != length(line)
                    return maxval * 10 + maximum(line[maxidx+1:end])
                else
                    return maximum(line[1:end-1]) * 10 + maxval
                end
            end)
        )")
    end

    @time begin
        println("Part 2: $(
            sum(map(readinput()) do line
                working = line
                v = 0
                for i ∈ 1:12
                    maxval, maxidx = findmax(working[1:end-(12-i)])
                    v = v*10+maxval
                    working = working[maxidx+1:end]
                end
                return v
            end)
        )")
    end
end