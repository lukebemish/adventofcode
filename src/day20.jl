import Base: <

struct Node
    pos::CartesianIndex{2}
    cost::Int
    path::Vector{CartesianIndex{2}}
end

struct Queue{T}
    tree::Vector{T}
    compare
    Queue{T}() where T = new(T[], (<))
    Queue{T}(compare) where T = new(T[], compare)
end

(<)(a::Node, b::Node) = a.cost < b.cost

Base.push!(queue::Queue, node::Node) = begin
    i = length(queue.tree) + 1
    push!(queue.tree, node)
    parent(x) = div(x, 2)
    while i > 1 && queue.compare(queue.tree[i], queue.tree[parent(i)])
        a, b = queue.tree[i], queue.tree[parent(i)]
        queue.tree[i], queue.tree[parent(i)] = b, a
        i = parent(i)
    end
end

Base.isempty(tree::Queue) = begin
    isempty(tree.tree)
end

Base.popfirst!(tree::Queue) = begin
    if isempty(tree)
        error(ArgumentError("queue must not be empty"))
    end
    value = tree.tree[1]
    if length(tree.tree) == 1
        empty!(tree.tree)
        return value
    end
    tree.tree[1] = pop!(tree.tree)
    i = 1
    leftchild(x) = 2*x
    rightchild(x) = 2*x + 1
    docompare(x, y) = checkbounds(Bool, tree.tree, x) ? checkbounds(Bool, tree.tree, y) ? tree.compare(tree.tree[x], tree.tree[y]) : true : false
    while docompare(leftchild(i), i) || docompare(rightchild(i), i)
        if docompare(leftchild(i), rightchild(i))
            a, b = tree.tree[i], tree.tree[leftchild(i)]
            tree.tree[i], tree.tree[leftchild(i)] = b, a
            i = leftchild(i)
        else
            a, b = tree.tree[i], tree.tree[rightchild(i)]
            tree.tree[i], tree.tree[rightchild(i)] = b, a
            i = rightchild(i)
        end
    end
    value
end

day20() = begin
    map, startpos, endpos = begin
        lines = readlines("data/day20.txt")
        map = zeros(Bool, length(lines[1]), length(lines))
        startpos = CartesianIndex(0, 0)
        endpos = CartesianIndex(0, 0)
        for (y, line) in enumerate(lines)
            for (x, c) in enumerate(line)
                if c == '#'
                    map[x, y] = true
                elseif c == 'S'
                    startpos = CartesianIndex(x, y)
                elseif c == 'E'
                    endpos = CartesianIndex(x, y)
                end
            end
        end
        map, startpos, endpos
    end

    costsmap() = begin
        costs = fill(typemax(Int), size(map)...)
        costs[endpos] = 0
        tasks = Queue{Node}()
        push!(tasks, Node(endpos, 0, [endpos]))
        queued = zeros(Bool, size(map)...)
        queued[endpos] = true
        while !isempty(tasks)
            node = popfirst!(tasks)
            if node.pos == startpos
                continue
            end
            for offset ∈ [(1,0), (0,1), (-1,0), (0,-1)]
                newpos = node.pos + CartesianIndex(offset)
                if checkbounds(Bool, map, newpos) && !queued[newpos] && !map[newpos]
                    queued[newpos] = true
                    push!(tasks, Node(newpos, node.cost + 1, vcat(node.path, newpos)))
                    costs[newpos] = node.cost + 1
                end
            end
        end
        costs
    end

    findundercost(maxcost, costs, cheatlength) = begin
        tasks = Queue{Node}()
        push!(tasks, Node(startpos, 0, [startpos]))
        totalfound = Threads.Atomic{Int}(0)
        queued = zeros(Bool, size(map)...)
        queued[startpos] = true
        offsets = reshape([CartesianIndex(-cheatlength + i + j, i - j) for i ∈ 0:cheatlength, j ∈ 0:cheatlength], (cheatlength+1)^2)
        offsets = vcat(offsets, reshape([CartesianIndex(1-cheatlength + i + j, i - j) for i ∈ 0:(cheatlength-1), j ∈ 0:(cheatlength-1)], cheatlength^2))
        while !isempty(tasks)
            node = popfirst!(tasks)
            if node.cost > maxcost
                continue
            end
            if node.pos == endpos
                continue
            end
            for offset ∈ [(1,0), (0,1), (-1,0), (0,-1)]
                newpos = node.pos + CartesianIndex(offset)
                if checkbounds(Bool, map, newpos) && !queued[newpos] && !map[newpos]
                    queued[newpos] = true
                    push!(tasks, Node(newpos, node.cost + 1, vcat(node.path, newpos)))
                end
            end
            Threads.@threads for cheatoffset ∈ offsets
                cheatend = node.pos + CartesianIndex(cheatoffset)
                if cheatend == node.pos
                    continue
                end
                if checkbounds(Bool, map, cheatend) && !map[cheatend]
                    dist = abs(cheatoffset[1]) + abs(cheatoffset[2])
                    totalcost = node.cost + dist + costs[cheatend]
                    if totalcost <= maxcost
                        Threads.atomic_add!(totalfound, 1)
                    end
                end
            end
        end
        totalfound[]
    end

    @time begin
        costs = costsmap()
        normalcost = costs[startpos]
        println("Part 1: $(findundercost(normalcost-100, costs, 2))")
    end

    @time begin
        costs = costsmap()
        normalcost = costs[startpos]
        println("Part 2: $(findundercost(normalcost-100, costs, 20))")
    end
end