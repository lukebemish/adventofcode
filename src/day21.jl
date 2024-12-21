day21() = begin
    keypad = [
        :k7 :k8 :k9;
        :k4 :k5 :k6;
        :k1 :k2 :k3;
        :skip :k0 :activate
    ]
    robotcontrol = [
        :skip :up :activate
        :left :down :right
    ]
    keypadmap = Dict([keypad[idx] => idx for idx in CartesianIndices(keypad)])
    robotcontrolmap = Dict([robotcontrol[idx] => idx for idx in CartesianIndices(robotcontrol)])

    valueways(startpos, value, inmap) = begin
        endpos = inmap[value]
        y0, x0 = Tuple(startpos)
        y1, x1 = Tuple(endpos)
        instructions = []
        skipreverse = false
        if x0 == 1 && y1 == inmap[:skip][1]
            while x0 < x1
                push!(instructions, :right)
                x0 += 1
            end
            skipreverse = true
        elseif x1 == 1 && y0 == inmap[:skip][1]
            skipreverse = true
        end
        while y0 > y1
            push!(instructions, :up)
            y0 -= 1
        end
        while y0 < y1
            push!(instructions, :down)
            y0 += 1
        end
        while x0 < x1
            push!(instructions, :right)
            x0 += 1
        end
        while x0 > x1
            push!(instructions, :left)
            x0 -= 1
        end
        if instructions == reverse(instructions) || skipreverse
            return [instructions]
        end
        return [instructions, reverse(instructions)]
    end

    appendways(ways, value, inmap) = begin
        out = []
        for (way, startpos) in ways
            for valueway in valueways(startpos, value, inmap)
                push!(out, ([way..., valueway..., :activate], inmap[value]))
            end
        end
        return out
    end

    waysofmaking(sequence, inmap) = begin
        out = [([], inmap[:activate])]
        for value in sequence
            out = appendways(out, value, inmap)
        end
        #return [i[1] for i in out]
        minlength = minimum([length(i[1]) for i in out])
        return [i[1] for i in out if length(i[1]) == minlength]
    end

    sequenceof(string) = [if c == 'A'
        :activate else Symbol("k$c") end for c ∈ string]

    pathlengthcache = Dict()

    shortestpathlength(iters, collection, initial) = begin
        if iters == -1
            return length(collection)
        end
        if !initial && haskey(pathlengthcache, (collection, iters))
            return pathlengthcache[(collection, iters)]
        end
        inmap = initial ? keypadmap : robotcontrolmap
        sections = []
        ilast = 1
        for i ∈ findall((==)(:activate), collection)
            push!(sections, collection[ilast:i])
            ilast = i + 1
        end
        totallength = 0
        for section in sections
            ways = waysofmaking(section, inmap)
            lengths = [shortestpathlength(iters - 1, way, false) for way ∈ ways]
            totallength += minimum(lengths)
        end
        if !initial
            pathlengthcache[(collection, iters)] = totallength
        end
        return totallength
    end
    
    @time begin
        complexities = 0
        for line in readlines("data/day21.txt")
            sequence = sequenceof(line)
            complexity = shortestpathlength(2, sequence, true) * parse(Int, line[1:end-1])
            complexities += complexity
        end
        println("Part 1: $complexities")
    end
    
    @time begin
        complexities = 0
        for line in readlines("data/day21.txt")
            sequence = sequenceof(line)
            complexity = shortestpathlength(25, sequence, true) * parse(Int, line[1:end-1])
            complexities += complexity
        end
        println("Part 2: $complexities")
    end
end
