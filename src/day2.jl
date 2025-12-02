day2() = begin
    readinput(; n = 2) = begin
        text = read("data/day2.txt", String)
        [i for i ∈ map(split(text, ",")) do r
            rstart, rend = map(split(r, "-")) do p strip(p) end
            while (length(rstart) % n) != 0
                if length(rend) == length(rstart)
                    return nothing
                end
                rstart = "1" * repeat("0", length(rstart))
            end
            if length(rend) < n
                return nothing
            end
            while (length(rend) % n) != 0
                rend = repeat("9", length(rend) - 1)
            end
            slen = length(rstart) ÷ n
            elen = length(rend) ÷ n
            bigpart1, bigpart2 = parse(Int, rstart[1:slen]), parse(Int, rend[1:elen])
            smallpart1, smallpart2 = [
                parse(Int, rstart[(i-1)*slen+1:i*slen]) for i in 2:n
            ], [
                parse(Int, rend[(i-1)*elen+1:i*elen]) for i in 2:n
            ]
            for x in smallpart1
                if x < bigpart1
                    break
                elseif x > bigpart1
                    bigpart1 += 1
                    break
                end
            end
            for x in smallpart2
                if x > bigpart2
                    break
                elseif x < bigpart2
                    bigpart2 -= 1
                    break
                end
            end
            if bigpart2 < bigpart1
                return nothing
            end
            bigpart1, bigpart2
        end if !isnothing(i)]
    end

    suminvalidids(rs; n = 2) = begin
        ostart = rs[1]
        oend = rs[2]
        sum([begin
            v = i
            mult = 10 ^ (Int(floor(log(10, i)))+1)
            for _ in 2:n
                v = mult * v + i
            end
            v
        end for i ∈ ostart:oend])
    end

    @time begin
        println("Part 1: $(
            sum(map(readinput()) do rs suminvalidids(rs) end)
        )")
    end

    @time begin
        println("Part 2: $(
            sum([sum(map(readinput(; n = i)) do rs suminvalidids(rs; n = i) end; init = 0) for i in [2,3,5,7,11]]) -
                sum([sum(map(readinput(; n = i)) do rs suminvalidids(rs; n = i) end; init = 0) for i in [6,10]])
        )")
    end
end
