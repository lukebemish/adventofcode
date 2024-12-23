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

        @views bananas(sequence) = begin
            foridx(i) = begin
                for j ∈ 1:(2000-3)
                    fits = true
                    for k ∈ 0:(length(sequence)-1)
                        if changes[j+k, i] != sequence[k+1]
                            fits = false
                            break
                        end
                    end
                    if fits
                        return prices[j+(length(sequence)), i]
                    end
                end
                return 0
            end
            total = 0
            for i ∈ 1:length(originalsecrets)
                total += foridx(i)
            end
            total
        end

        sequences = Set{Vector{Int}}()
        for j ∈ 1:(2000-3)
            for i ∈ 1:length(originalsecrets)
                push!(sequences, changes[j:j+3, i])
            end
        end
        sequences = collect(sequences)

        foundbananas = zeros(Int, length(sequences))
        Threads.@threads for i ∈ eachindex(sequences)
            foundbananas[i] = bananas(sequences[i])
        end

        println("Part 2: $(maximum(foundbananas))")
    end
end
