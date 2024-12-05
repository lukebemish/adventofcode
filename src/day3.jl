instructions = join(readlines("data/day3.txt"))

total = 0
state = :empty
firstnum = 0
buffer = ""
for c in instructions
    if state == :empty
        if c == 'm'
            state = :m
        end
    elseif state == :m
        if c == 'u'
            state = :u
        else
            state = :empty
        end
    elseif state == :u
        if c == 'l'
            state = :l
        else
            state = :empty
        end
    elseif state == :l
        if c == '('
            state = :lparen
        else
            state = :empty
        end
    elseif state == :lparen
        if isdigit(c)
            buffer = ""*c
            state = :firstnum
        else
            state = :empty
        end
    elseif state == :firstnum
        if isdigit(c)
            buffer *= c
        elseif c == ','
            state = :comma
            firstnum = parse(Int, buffer)
        else
            state = :empty
        end
    elseif state == :comma
        if isdigit(c)
            buffer = ""*c
            state = :secondnum
        else
            state = :empty
        end
    elseif state == :secondnum
        if isdigit(c)
            buffer *= c
        elseif c == ')'
            state = :empty
            total += firstnum * parse(Int, buffer)
        else
            state = :empty
        end
    end
end

println("Part 1: $total")

##

total = 0
state = :empty
firstnum = 0
buffer = ""
for c in instructions
    if state == :empty
        if c == 'm'
            state = :m
        elseif c == 'd'
            state = :dont_d
        end
    elseif state == :disabled
        if c == 'd'
            state = :do_d
        end
    elseif state == :dont_d
        if c == 'o'
            state = :dont_o
        else
            state = :empty
        end
    elseif state == :dont_o
        if c == 'n'
            state = :dont_n
        else
            state = :empty
        end
    elseif state == :dont_n
        if c == '''
            state = :dont_apos
        else
            state = :empty
        end
    elseif state == :dont_apos
        if c == 't'
            state = :dont_t
        else
            state = :empty
        end
    elseif state == :dont_t
        if c == '('
            state = :dont_lparen
        else
            state = :empty
        end
    elseif state == :dont_lparen
        if c == ')'
            state = :disabled
        else
            state = :empty
        end
    elseif state == :dont_t

    elseif state == :do_d
        if c == 'o'
            state = :do_o
        else
            state = :disabled
        end
    elseif state == :do_o
        if c == '('
            state = :do_lparen
        else
            state = :disabled
        end
    elseif state == :do_lparen
        if c == ')'
            state = :empty
        else
            state = :disabled
        end
    elseif state == :m
        if c == 'u'
            state = :u
        else
            state = :empty
        end
    elseif state == :u
        if c == 'l'
            state = :l
        else
            state = :empty
        end
    elseif state == :l
        if c == '('
            state = :lparen
        else
            state = :empty
        end
    elseif state == :lparen
        if isdigit(c)
            buffer = ""*c
            state = :firstnum
        else
            state = :empty
        end
    elseif state == :firstnum
        if isdigit(c)
            buffer *= c
        elseif c == ','
            state = :comma
            firstnum = parse(Int, buffer)
        else
            state = :empty
        end
    elseif state == :comma
        if isdigit(c)
            buffer = ""*c
            state = :secondnum
        else
            state = :empty
        end
    elseif state == :secondnum
        if isdigit(c)
            buffer *= c
        elseif c == ')'
            state = :empty
            total += firstnum * parse(Int, buffer)
        else
            state = :empty
        end
    end
end

println("Part 2: $total")