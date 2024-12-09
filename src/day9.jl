abstract type Piece end

struct Chunk <: Piece
    id::Int
    length::Int
end

struct Gap <: Piece
    length::Int
end

function day9()
    chars = [parse(Int, i) for i ∈ readlines("data/day9.txt")[1]]

    function part1()
        blocks = begin
            blocks = []
            id = 0
            for (i, n) ∈ enumerate(chars)
                if (i & 1) == 0
                    append!(blocks, [nothing for _ in 1:n])
                else
                    append!(blocks, [id for _ in 1:n])
                    id += 1
                end
            end
            blocks
        end

        newblocks = Int[]
        startidx = 1
        endidx = length(blocks)
        while startidx <= endidx
            atstart = blocks[startidx]
            if isnothing(atstart)
                atend = blocks[endidx]
                if isnothing(atend)
                    endidx -= 1
                else
                    push!(newblocks, atend)
                    endidx -= 1
                    startidx += 1
                end
            else
                push!(newblocks, atstart)
                startidx += 1
            end
        end

        total = 0
        for (i, j) ∈ enumerate(newblocks)
            total += (i-1) * j
        end
        println(total)
    end

    @time part1()

    function part2()
        pieces, chunks = begin
            pieces = Piece[]
            chunks = Chunk[]
            id = 0
            for (i, n) ∈ enumerate(chars)
                if (i & 1) == 0
                    push!(pieces, Gap(n))
                else
                    chunk = Chunk(id, n)
                    push!(pieces, chunk)
                    push!(chunks, chunk)
                    id += 1
                end
            end
            pieces, chunks
        end

        for chunk ∈ reverse(chunks)
            location = findfirst(==(chunk), pieces)
            for i ∈ 1:location
                if pieces[i] isa Gap
                    rem = pieces[i].length - chunk.length
                    if rem == 0
                        pieces[i] = chunk
                        pieces[location] = Gap(chunk.length)
                        break
                    elseif rem > 0
                        pieces[i] = chunk
                        pieces[location] = Gap(chunk.length)
                        insert!(pieces, i+1, Gap(rem))
                        break
                    end
                end
            end
        end

        total = 0
        index = 0
        for piece ∈ pieces
            if piece isa Chunk
                for _ ∈ 1:piece.length
                    total += index * piece.id
                    index += 1
                end
            else
                index += piece.length
            end
        end
        println(total)
    end

    @time part2()
end
