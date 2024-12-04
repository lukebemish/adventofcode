using Pkg
Pkg.activate(".")

##

lines = readlines("data/day4.txt")

total = 0

function countmatches(line)
    count = 0
    for _ ∈ eachmatch(r"XMAS", line)
        count += 1
    end
    for _ ∈ eachmatch(r"SAMX", line)
        count += 1
    end
    return count
end

for line ∈ lines
    total += countmatches(line)
end

linelength = length(lines[1])

vertical = [join([line[i] for line in lines]) for i in 1:linelength]
for line ∈ vertical
    total += countmatches(line)
end

diagonal1 = [join([lines[i+j][j] for j in 1:linelength if i+j >= 1 && i+j <= length(lines)]) for i in (-linelength):length(lines)]
for line ∈ diagonal1
    total += countmatches(line)
end

diagonal2 = [join([lines[i+j][linelength - j + 1] for j in 1:linelength if i+j >= 1 && i+j <= length(lines)]) for i in (-linelength):length(lines)]
for line ∈ diagonal2
    total += countmatches(line)
end

println("Part 1: $total")

##

total = 0

for i ∈ 2:(length(lines)-1)
    for j ∈ 2:(linelength-1)
        lr = lines[i-1][j-1] * lines[i][j] * lines[i+1][j+1]
        rl = lines[i-1][j+1] * lines[i][j] * lines[i+1][j-1]
        if (lr == "MAS" || lr == "SAM") && (rl == "MAS" || rl == "SAM")
            total += 1
        end
    end
end

println("Part 2: $total")