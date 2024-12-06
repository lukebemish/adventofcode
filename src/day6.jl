initialpos = (0,0)
initialdir = (0,0)
obstructed = let chars = pairs(permutedims(reduce(hcat, map(readlines("data/day6.txt")) do line collect(line) end)))
    m = zeros(Bool, size(chars))
    for (idx, c) ∈ pairs(chars)
        if c == '^'
            global initialdir = (-1,0)
        elseif c == 'v'
            global initialdir = (1,0)
        elseif c == '<'
            global initialdir = (0,-1)
        elseif c == '>'
            global initialdir = (0,1)
        else
            m[idx] = c == '#'
            continue
        end
        global initialpos = idx[1],idx[2]
    end
    m
end

## Part 1

x,y = initialpos
dx,dy = initialdir

visited = zeros(Bool, size(obstructed))
visited[x,y] = true

function inbounds(x,y,plot)
    return 1 ≤ x ≤ size(plot,1) && 1 ≤ y ≤ size(plot,2)
end

while inbounds(x,y,obstructed)
    visited[x,y] = true
    if inbounds(x+dx, y+dy, obstructed) && obstructed[x+dx,y+dy]
        dx,dy = [0 1;-1 0] * [dx,dy]
    else
        x += dx
        y += dy
    end
end

println("Part 1: $(sum(visited))")

## Part 2

x,y = initialpos
dx,dy = initialdir

visitedpathouter = Set{Tuple{Int,Int,Int,Int}}()
visitedpoints = Set{Tuple{Int,Int}}()
looppositions = Set{Tuple{Int,Int}}()
tasks = Task[]
while inbounds(x,y,obstructed)
    push!(visitedpathouter, (x,y,dx,dy))
    push!(visitedpoints, (x,y))

    if inbounds(x+dx, y+dy, obstructed)
        ox,oy = x+dx,y+dy
        if obstructed[ox,oy]
            dx,dy = [0 1;-1 0] * [dx,dy]
            continue
        elseif (ox,oy) ∉ visitedpoints
            ix,iy,idx,idy = x,y,dx,dy
            visitedpath = Set{Tuple{Int,Int,Int,Int}}(visitedpathouter)

            t = @task begin
                isloop = false
                while inbounds(ix,iy,obstructed)
                    push!(visitedpath, (ix,iy,idx,idy))
                    if inbounds(ix+idx, iy+idy, obstructed) && (obstructed[ix+idx,iy+idy] || (ix+idx,iy+idy) == (ox,oy))
                        idx,idy = [0 1;-1 0] * [idx,idy]
                    else
                        ix += idx
                        iy += idy
                        if (ix,iy,idx,idy) ∈ visitedpath
                            isloop = true
                            break
                        end
                    end
                end
                isloop, (ox,oy)
            end
            schedule(t)
            push!(tasks, t)
        end
    end
    x += dx
    y += dy
end

looppositions = Set{Tuple{Int,Int}}(map(tasks) do t fetch(t) end |> l -> filter(l) do (isloop, _) isloop end |> l -> map(l) do (_, pos) pos end)

println("Part 2: $(length(looppositions))")