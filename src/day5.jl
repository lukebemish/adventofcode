instructions = readlines("data/day5.txt")
combos = map(instructions[1:findfirst(==(""), instructions)-1]) do combo
    map(split(combo, "|")) do i parse(Int, i) end
end
pages = map(instructions[findfirst(==(""), instructions)+1:end]) do toprint
    map(split(toprint, ",")) do i parse(Int, i) end
end

##

# Par1 1

invalid = []

total = 0
for pagenums ∈ pages
    map = Dict{Int, Int}()
    for (i, pagenum) ∈ enumerate(pagenums)
        map[pagenum] = i
    end
    valid = true
    for rule ∈ combos
        if haskey(map, rule[1]) && haskey(map, rule[2]) && map[rule[1]] > map[rule[2]]
            valid = false
            break
        end
    end
    if valid
        middle = pagenums[div(length(pagenums)+1,2)]
        total += middle
    else
        push!(invalid, pagenums)
    end
end

println("Part 1: $total")

##

containsmap = Dict{Int, Dict{Int, Bool}}()
for combo in combos
    if !haskey(containsmap, combo[1])
        containsmap[combo[1]] = Dict{Int, Bool}()
    end
    containsmap[combo[1]][combo[2]] = true
    if !haskey(containsmap, combo[2])
        containsmap[combo[2]] = Dict{Int, Bool}()
    end
    containsmap[combo[2]][combo[1]] = false
end

total = 0
for pagenums ∈ invalid
    ordering = zeros(Int, length(pagenums))
    i = 1
    for (j, num) ∈ enumerate(pagenums)
        has = get(containsmap, num, Dict())
        target = i
        for (x, e) ∈ enumerate(ordering[1:i-1])
            if haskey(has, e)
                numleftofe = has[e]
                if numleftofe
                    target = x
                    break
                end
            end
        end
        ordering[target+1:i] = ordering[target:i-1]
        ordering[target] = num
        i+=1
    end
    if ordering != pagenums
        middle = ordering[div(length(ordering)+1,2)]
        total += middle
    end
end

println("Part 2: $total")