@enum Direction north=1 east=2 south=3 west=4
offset(direction) = begin
    if direction === north
        return CartesianIndex(-1, 0)
    elseif direction === east
        return CartesianIndex(0, 1)
    elseif direction === south
        return CartesianIndex(1, 0)
    elseif direction === west
        return CartesianIndex(0, -1)
    end
end

clockwise(direction) = begin
    if direction === north
        return east
    elseif direction === east
        return south
    elseif direction === south
        return west
    elseif direction === west
        return north
    end
end

counterclockwise(direction) = begin
    if direction === north
        return west
    elseif direction === east
        return north
    elseif direction === south
        return east
    elseif direction === west
        return south
    end
end

struct Node
    pos::CartesianIndex{2}
    direction::Direction
    cost::Int
    path::Vector{CartesianIndex{2}}
end

struct Queue
    tree::Vector{Node}
    Queue() = new(Node[])
end

Base.push!(queue::Queue, node::Node) = begin
    i = length(queue.tree) + 1
    push!(queue.tree, node)
    parent(x) = div(x, 2)
    while i > 1 && queue.tree[i].cost < queue.tree[parent(i)].cost
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
        return value
    end
    tree.tree[1] = pop!(tree.tree)
    i = 1
    leftchild(x) = 2*x
    rightchild(x) = 2*x + 1
    getcost(x) = checkbounds(Bool, tree.tree, x) ? tree.tree[x].cost : typemax(Int)
    while getcost(i) > getcost(leftchild(i)) || getcost(i) > getcost(rightchild(i))
        if getcost(leftchild(i)) < getcost(rightchild(i))
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

day16() = begin
    walls, startpos, endpos = begin
        lines = readlines("data/day16.txt")
        startpos = (0, 0)
        endpos = (0, 0)
        walls = zeros(Bool, length(lines), length(lines[1]))
        for (y, line) in enumerate(lines)
            for (x, c) in enumerate(line)
                if c == '#'
                    walls[y, x] = true
                elseif c == 'S'
                    startpos = (y, x)
                elseif c == 'E'
                    endpos = (y, x)
                end
            end
        end
        walls, CartesianIndex(startpos), CartesianIndex(endpos)
    end

    shortestpath() = begin
        tasks = Queue()
        push!(tasks, Node(startpos, east, 0, [startpos]))
        visited = zeros(Bool, size(walls)..., 4)
        finalprice = typemax(Int)
        paths = []
        while !isempty(tasks)
            node = popfirst!(tasks)
            if node.cost > finalprice
                break
            end
            visited[node.pos[1], node.pos[2], Int(node.direction)] = true
            if node.pos == endpos
                finalprice = node.cost
                push!(paths, node.path)
                continue
            end
            nextpos = node.pos + offset(node.direction)
            if !walls[nextpos] && !visited[nextpos[1], nextpos[2], Int(node.direction)]
                push!(tasks, Node(nextpos, node.direction, node.cost + 1, vcat(node.path, [nextpos])))
            end
            leftpos = node.pos + offset(counterclockwise(node.direction))
            if !walls[leftpos] && !visited[leftpos[1], leftpos[2], Int(counterclockwise(node.direction))]
                push!(tasks, Node(leftpos, counterclockwise(node.direction), node.cost + 1001, vcat(node.path, [leftpos])))
            end
            rightpos = node.pos + offset(clockwise(node.direction))
            if !walls[rightpos] && !visited[rightpos[1], rightpos[2], Int(clockwise(node.direction))]
                push!(tasks, Node(rightpos, clockwise(node.direction), node.cost + 1001, vcat(node.path, [rightpos])))
            end
        end
        finalprice, paths
    end

    @time begin
        cost, paths = shortestpath()
        println("Part 1: $cost")
        onpath = zeros(Bool, size(walls))
        for path in paths
            for pos in path
                onpath[pos] = true
            end
        end
        println("Part 2: $(sum(onpath))")
    end
end
