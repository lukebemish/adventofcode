mix(result, old) = result ⊻ old

prune(result) = result & 0xFFFFFF

nextsecret(secret) = begin
    secret = prune(mix(secret * 64, secret))
    secret = prune(mix(div(secret, 32), secret))
    secret = prune(mix(secret * 2048, secret))
    secret
end

day22() = begin
    originalsecrets = [parse(Int, line) for line ∈ readlines("data/day22.txt")]
    @time begin
        secrets = copy(originalsecrets)
        for _ ∈ 1:2000
            for idx ∈ eachindex(secrets)
                secrets[idx] = nextsecret(secrets[idx])
            end
        end
        println("Part 1: $(sum(secrets))")
    end

    @time begin
        prices = zeros(Int, (2001, length(originalsecrets)))
        for idx ∈ 1:length(originalsecrets)
            secret = originalsecrets[idx]
            for i ∈ 1:2001
                prices[i, idx] = mod(secret, 10)
                secret = nextsecret(secret)
            end
        end
        changes = prices[2:end, :] .- prices[1:end-1, :]

        totals = Dict()
        for i ∈ 1:length(originalsecrets)
            found = Dict()
            for j ∈ 1:(2000-3)
                sequence = changes[j:j+3, i]
                if !haskey(found, sequence)
                    found[sequence] = nothing
                    totals[sequence] = get(totals, sequence, 0) + prices[j+4, i]
                end
            end
        end

        println("Part 2: $(maximum(values(totals)))")
    end
end
