struct Node
    pos::CartesianIndex{2}
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
        empty!(tree.tree)
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

day18() = begin
    gridsize = 71

    space, costs = begin
        lines = readlines("data/day18.txt")
        space = fill(typemax(Int), gridsize, gridsize)
        for (i, line) ∈ enumerate(lines)
            x, y = map(split(line, ",")) do x parse(Int, x) end
            space[x+1, y+1] = i
        end
        space, [CartesianIndex(map(split(line, ",")) do x parse(Int, x) end...) for line ∈ lines]
    end
    startpos = CartesianIndex(1,1)
    endpos = CartesianIndex(size(space))

    findpath(cutoff) = begin
        tasks = Queue()
        push!(tasks, Node(startpos, 0, [startpos]))
        queued = zeros(Bool, size(space))
        while !isempty(tasks)
            node = popfirst!(tasks)
            if node.pos == endpos
                return node.cost, node.path
            end
            for offset ∈ [(1,0), (0,1), (-1,0), (0,-1)]
                newpos = node.pos + CartesianIndex(offset)
                if checkbounds(Bool, space, newpos) && !queued[newpos] && space[newpos] > cutoff
                    queued[newpos] = true
                    push!(tasks, Node(newpos, node.cost + 1, vcat(node.path, newpos)))
                end
            end
        end
        return nothing, []
    end

    @time begin
        println("Path 1: $(findpath(1024)[1])")
    end

    @time begin
        i = 0
        while true
            cost, path = findpath(i)
            if isnothing(cost)
                break
            end
            i = findmin(space[path])[1]
        end
        x, y = costs[i][1], costs[i][2]
        println("Path 2: $x,$y")
    end
end