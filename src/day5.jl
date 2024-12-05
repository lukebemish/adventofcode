instructions = readlines("data/day5.txt")
combos = map(instructions[1:findfirst(==(""), instructions)-1]) do combo
    map(split(combo, "|")) do i parse(Int, i) end
end

comparemap = Dict{Int, Set{Int}}()
for combo in combos
    map = get!(comparemap, combo[1], Set{Int}())
    push!(map, combo[2])
end

function lt(a, b)
    return b ∈ get(comparemap, a, Set{Int}())
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
    for (a, b) ∈ zip(pagenums[1:end-1], pagenums[2:end])
        if lt(b, a)
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

total = 0
for pagenums ∈ invalid
    orderednums = sort(pagenums, lt=lt)
    middle = orderednums[div(length(orderednums)+1,2)]
    total += middle
end

println("Part 2: $total")