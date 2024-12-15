@enum Direction north east south west
offset(direction) = begin
    if direction === north
        return (-1, 0)
    elseif direction === east
        return (0, 1)
    elseif direction === south
        return (1, 0)
    elseif direction === west
        return (0, -1)
    end
end

@enum State wall box space bigboxleft bigboxright

day15() = begin
    readinput() = begin
        lines = readlines("data/day15.txt")
        split = findfirst(==(""), lines)
        maplines = lines[1:split-1]
        position = (0, 0)
        map = fill(space, length(maplines), length(maplines[1]))
        for (y, line) in enumerate(maplines)
            for (x, c) in enumerate(line)
                if c === '#'
                    map[y, x] = wall
                elseif c === 'O'
                    map[y, x] = box
                elseif c === '@'
                    position = (y, x)
                end
            end
        end
        instructions = reduce(vcat, [[begin
            if c == '<'
                west
            elseif c == '>'
                east
            elseif c == '^'
                north
            else
                south
            end
        end for c ∈ line] for line ∈ lines[split+1:end]])
        map, instructions, CartesianIndex(position)
    end

    bigboxes = Set([bigboxleft, bigboxright])
    leftright = Set([west, east])

    canmove(map, instruction, position) = begin
        newpos = position + CartesianIndex(offset(instruction))
        state = map[newpos]
        if state === wall
            return false
        elseif state === box || (state ∈ bigboxes && instruction ∈ leftright)
            return canmove(map, instruction, newpos)
        elseif state == bigboxleft
            rpos = newpos + CartesianIndex(0, 1)
            return canmove(map, instruction, rpos) && canmove(map, instruction, newpos)
        elseif state == bigboxright
            lpos = newpos + CartesianIndex(0, -1)
            return canmove(map, instruction, lpos) && canmove(map, instruction, newpos)
        else
            return true
        end
    end

    move(map, instruction, position) = move(map, instruction, position, false)
    move(map, instruction, position, unsafe) = begin
        newpos = position + CartesianIndex(offset(instruction))
        if !unsafe && !canmove(map, instruction, position)
            return position
        end
        state = map[newpos]
        if state === box || (state ∈ bigboxes && instruction ∈ leftright)
            move(map, instruction, newpos, true)
            map[newpos + CartesianIndex(offset(instruction))] = state
            map[newpos] = space
        elseif state == bigboxleft
            rpos = newpos .+ CartesianIndex(0, 1)
            move(map, instruction, rpos, true)
            move(map, instruction, newpos, true)
            map[newpos + CartesianIndex(offset(instruction))] = bigboxleft
            map[rpos + CartesianIndex(offset(instruction))] = bigboxright
            map[newpos] = space
            map[rpos] = space
        elseif state == bigboxright
            lpos = newpos + CartesianIndex(0, -1)
            move(map, instruction, lpos, true)
            move(map, instruction, newpos, true)
            map[newpos + CartesianIndex(offset(instruction))] = bigboxright
            map[lpos + CartesianIndex(offset(instruction))] = bigboxleft
            map[newpos] = space
            map[lpos] = space
        end
        return newpos
    end

    gpstotal(map) = begin
        total = 0
        for idx ∈ CartesianIndices(map)
            y, x = Tuple(idx)
            if map[idx] === box || map[idx] == bigboxleft
                total += 100 * (y-1) + (x-1)
            end
        end
        return total
    end

    @time begin
        map, instructions, position = readinput()
        for instruction in instructions
            position = move(map, instruction, position)
        end
        println("Part 1: $(gpstotal(map))")
    end

    @time begin
        mapold, instructions, position = readinput()
        map = fill(space, size(mapold, 1), size(mapold, 2) * 2)
        position = CartesianIndex(position[1], position[2]*2-1)
        for idx ∈ CartesianIndices(mapold)
            y, x = Tuple(idx)
            if mapold[idx] === wall
                map[y, x*2-1] = wall
                map[y, x*2] = wall
            elseif mapold[idx] === box
                map[y, x*2-1] = bigboxleft
                map[y, x*2] = bigboxright
            elseif mapold[idx] === space
                map[y, x*2-1] = space
                map[y, x*2] = space
            end
        end
        for instruction in instructions
            position = move(map, instruction, position)
        end
        println("Part 2: $(gpstotal(map))")
    end
end