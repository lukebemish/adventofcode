function day7()
    readinput() = begin
        lines = readlines("data/day7.txt")
        chars = reduce(vcat, permutedims.(collect.(lines)))
        countarray = zeros(Int, size(chars))
        countarray[chars .== 'S'] .= 1
        splitcount = 0
        for (last, this, lastcount, thiscount) ∈ zip(
            eachrow(chars)[1:end-1],
            eachrow(chars)[2:end],
            eachrow(countarray)[1:end-1],
            eachrow(countarray)[2:end]
        )
            incoming = last .== '|' .|| last .== 'S'
            split = incoming .&& (this .== '^')
            splitcount += sum(split)
            splitright = [false; split[1:end-1]]
            splitleft = [split[2:end]; false]
            direct = (!).(split) .&& incoming
            this[splitright] .= '|'
            this[splitleft] .= '|'
            this[direct] .= '|'
            thiscount[splitleft] += lastcount[[split[1:end-1]; false]]
            thiscount[splitright] += lastcount[[false; split[2:end]]]
            thiscount[direct] += lastcount[direct]
        end
        splitcount, countarray
    end

    splitcount, countarray = @time begin
        readinput()
    end

    @time begin
        println("Part 1: $(splitcount)")
    end

    @time begin
        println("Part 2: $(sum(countarray[end, :]))")
    end
end