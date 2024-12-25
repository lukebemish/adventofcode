day25() = begin
    lines = readlines("data/day25.txt")
    locks = []
    keys = []
    current = zeros(Bool, 7, 5)
    y = 0
    for line ∈ lines
        y += 1
        if y > 7
            y = 0
            continue
        end
        row = [c == '#' for c ∈ line]
        current[y, :] = row
        if y == 7
            islock = any(current[1, :])
            if islock
                push!(locks, current)
            else
                push!(keys, current)
            end
            current = zeros(Bool, 7, 5)
        end
    end

    total = 0
    for lock ∈ locks
        for key ∈ keys
            if any(lock .& key)
                continue
            end
            total += 1
        end
    end
    total
end