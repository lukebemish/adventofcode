day23() = begin
    networkpairs = [begin
        parts = split(line, "-")
        (Symbol(parts[1]), Symbol(parts[2]))
    end for line ∈ readlines("data/day23.txt")]

    @time begin
        candidates = IdDict()
        triples = Set()
        for pair ∈ networkpairs
            connected1 = get!(candidates, pair[1], IdSet())
            connected2 = get!(candidates, pair[2], IdSet())
            push!(connected1, pair[2])
            push!(connected2, pair[1])
        end
        for pair ∈ networkpairs
            if string(pair[1])[1] == 't' || string(pair[2])[1] == 't'
                for i ∈ intersect(candidates[pair[1]], candidates[pair[2]])
                    push!(triples, sort([pair[1], pair[2], i]))
                end
            end
        end
        println(length(triples))
    end

    @time begin
        candidates = IdDict()
        for pair ∈ networkpairs
            connected1 = get!(candidates, pair[1], IdSet())
            connected2 = get!(candidates, pair[2], IdSet())
            push!(connected1, pair[2])
            push!(connected2, pair[1])
        end

        parties = Set()
        for (computer, connected) ∈ candidates
            newparties = []
            for party ∈ parties
                if length(intersect(connected, party)) == length(party)
                    newparty = IdSet()
                    push!(newparty, party...)
                    push!(newparties, newparty)
                    push!(party, computer)
                end
            end
            for newparty ∈ newparties
                push!(parties, newparty)
            end
            newparty = IdSet()
            push!(newparty, computer)
            push!(parties, newparty)
        end

        partylist = collect(parties)
        biggestparty = findmax(length, partylist)[2]
        println(join(sort([string(i) for i ∈ partylist[biggestparty]]), ","))
    end
end
