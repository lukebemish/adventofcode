function day6()
    initialpos = (0,0)
    initialdir = (0,0)
    obstructed = let chars = permutedims(reduce(hcat, map(readlines("data/day6.txt")) do line collect(line) end))
        m = zeros(Bool, size(chars))
        for (idx, c) ∈ pairs(chars)
            if c == '^'
                initialdir = (-1,0)
            elseif c == 'v'
                initialdir = (1,0)
            elseif c == '<'
                initialdir = (0,-1)
            elseif c == '>'
                initialdir = (0,1)
            else
                m[idx] = c == '#'
                continue
            end
            initialpos = idx[1],idx[2]
        end
        m
    end

    ## Part 1

    function inbounds(x,y,plot)
        return 1 ≤ x ≤ size(plot,1) && 1 ≤ y ≤ size(plot,2)
    end

    function part1()
        x,y = initialpos
        dx,dy = initialdir

        visited = zeros(Bool, size(obstructed))
        visited[x,y] = true

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
    end
    @time part1()

    function part2()
        x,y = initialpos
        dx,dy = initialdir

        visitedpathouter = zeros(Int, (size(obstructed)...,4))
        visitedpoints = zeros(Bool, size(obstructed))
        tasks = Task[]

        function idxdir(dx,dy)
            if dx == 0 && dy == 1
                return 1
            elseif dx == 1 && dy == 0
                return 2
            elseif dx == 0 && dy == -1
                return 3
            else
                return 4
            end
        end

        i = 0
        while inbounds(x,y,obstructed)
            i += 1
            visitedpoints[x,y] = true
            visitedpathouter[x,y,idxdir(dx,dy)] = i

            if inbounds(x+dx, y+dy, obstructed)
                ox,oy = x+dx,y+dy
                if obstructed[ox,oy]
                    dx,dy = [0 1;-1 0] * [dx,dy]
                    continue
                elseif !visitedpoints[ox,oy]
                    ix,iy,idx,idy = x,y,dx,dy
                    visitedpath = zeros(Bool, (size(obstructed)...,4))

                    tasknum = i
                    t = @task begin
                        isloop = false
                        while inbounds(ix,iy,obstructed)
                            visitedpath[ix,iy,idxdir(idx,idy)] = true
                            if inbounds(ix+idx, iy+idy, obstructed) && (obstructed[ix+idx,iy+idy] || (ix+idx,iy+idy) == (ox,oy))
                                idx,idy = [0 1;-1 0] * [idx,idy]
                            else
                                ix += idx
                                iy += idy
                                if inbounds(ix, iy, obstructed) && (visitedpath[ix,iy,idxdir(idx,idy)] || visitedpathouter[ix,iy,idxdir(idx,idy)] <= tasknum)
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
    end
    @time part2()
end