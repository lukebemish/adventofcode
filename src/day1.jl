day1() = begin
    readinput() = begin
        lines = readlines("data/day1.txt")
        map(lines) do line
            replace(line, "L" => "-", "R" => "") |> x -> parse(Int, x)
        end
    end

    @time begin
        changes = readinput()
        (count, _) = foldl(changes; init=(0, 50)) do (c, v), change
            vNew = v + change
            if (vNew % 100) == 0
                c += 1
            end
            (c, vNew)
        end
        println("Part 1: ", count)
    end

    @time begin
        changes = readinput()
        (count, _) = foldl(changes; init=(0, 50)) do (c, v), change
            vNew = v + change
            if vNew >= 100
                c += vNew ÷ 100
                vNew = vNew % 100
            elseif vNew <= 0
                c += -vNew ÷ 100 + (if v != 0 1 else 0 end)
                vNew = vNew % 100
                if vNew < 0
                    vNew += 100
                end
            end
            (c, vNew)
        end
        println("Part 2: ", count)
    end
end