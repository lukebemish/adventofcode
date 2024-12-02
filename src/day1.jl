using Pkg
Pkg.activate(".")

##

lines = readlines("data/day1.txt")
values = zeros(Int32, (2, length(lines)))
for (i, line) ∈ enumerate(lines)
    values[:, i] = map(split(line, "   ")) do j parse(Int, j) end
end

for row ∈ eachrow(values)
    sort!(row)
end

total = sum(abs.(values[2,:] .- values[1,:]))
println("Part 1: $total")

##

# Already sorted
counts = Dict{Int32, Int32}()
current = values[2,1]
currentcount = 0
for val ∈ values[2,:]
    if current == val
        currentcount += 1
    else
        counts[current] = currentcount
        current = val
        currentcount = 1
    end
end
if !haskey(counts, current)
    counts[current] = currentcount
end

total = 0
for val ∈ values[1,:]
    if haskey(counts, val)
        total += counts[val] * val
    end
end

println("Part 2: $total")