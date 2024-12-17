function combooperand(operand, state)
    if operand <= 3
        return operand
    elseif operand == 4
        return state.a
    elseif operand == 5
        return state.b
    elseif operand == 6
        return state.c
    end
end

struct State
    program::Vector{Int}
    a::Int
    b::Int
    c::Int
    pointer::Int
end

execute(state, out) = begin
    (; program, a, b, c, pointer) = state
    opcode = program[pointer]
    nextpointer = pointer + 2
    combo() = combooperand(program[pointer + 1], state)
    if opcode == 0 #adv
        a = a >>> combo()
    elseif opcode == 1 #bxl
        b = b ⊻ program[pointer + 1]
    elseif opcode == 2 #bst
        b = combo() & 0b111
    elseif opcode == 3 #jnz
        if a != 0
            nextpointer = program[pointer + 1] + 1
        end
    elseif opcode == 4 #bxc
        b = b ⊻ c
    elseif opcode == 5 #out
        push!(out, combo() & 0b111)
    elseif opcode == 6 #bdv
        b = a >>> combo()
    elseif opcode == 7 #cdv
        c = a >>> combo()
    end
    State(program, a, b, c, nextpointer)
end

abstract type SingleExpression end

struct ExpressionState
    program::Vector{Int}
    a::SingleExpression
    b::SingleExpression
    c::SingleExpression
end

struct Literal <: SingleExpression
    value::Int
end

struct Modulo8 <: SingleExpression
    input::SingleExpression
end

struct Shift <: SingleExpression
    a::SingleExpression
    b::SingleExpression
end

struct Xor <: SingleExpression
    a::SingleExpression
    b::SingleExpression
end

struct Symbolic <: SingleExpression
    symbol::Symbol
end

evaluate(expr::Literal; kwargs...) = expr.value
evaluate(expr::Modulo8; kwargs...) = evaluate(expr.input; kwargs...) & 0b111
evaluate(expr::Shift; kwargs...) = evaluate(expr.a; kwargs...) >>> evaluate(expr.b; kwargs...)
evaluate(expr::Xor; kwargs...) = evaluate(expr.a; kwargs...) ⊻ evaluate(expr.b; kwargs...)
evaluate(expr::Symbolic; kwargs...) = kwargs[expr.symbol]

Base.show(io::IO, expr::Literal) = print(io, expr.value)
Base.show(io::IO, expr::Modulo8) = print(io, "(", expr.input, " mod 8)")
Base.show(io::IO, expr::Shift) = print(io, "(", expr.a, " >>> ", expr.b, ")")
Base.show(io::IO, expr::Xor) = print(io, "(", expr.a, " ⊻ ", expr.b, ")")
Base.show(io::IO, expr::Symbolic) = print(io, expr.symbol)

requires(expr::Literal, symbol) = false
requires(expr::Modulo8, symbol) = requires(expr.input, symbol)
requires(expr::Shift, symbol) = requires(expr.a, symbol) || requires(expr.b, symbol)
requires(expr::Xor, symbol) = requires(expr.a, symbol) || requires(expr.b, symbol)
requires(expr::Symbolic, symbol) = expr.symbol == symbol

executeexpression(state, pointer, out) = begin
    (; program, a, b, c) = state
    opcode = program[pointer]
    combo() = begin
        operand = program[pointer + 1]
        if operand <= 3
            return Literal(operand)
        elseif operand == 4
            return a
        elseif operand == 5
            return b
        elseif operand == 6
            return c
        end
    end
    if opcode == 0 #adv
        a = Shift(a, combo())
    elseif opcode == 1 #bxl
        b = Xor(b, Literal(program[pointer + 1]))
    elseif opcode == 2 #bst
        b = Modulo8(combo())
    elseif opcode == 3 #jnz
        throw(ArgumentError("jnz not allowed in expression mode"))
    elseif opcode == 4 #bxc
        b = Xor(b, c)
    elseif opcode == 5 #out
        push!(out, Modulo8(combo()))
    elseif opcode == 6 #bdv
        b = Shift(a, combo())
    elseif opcode == 7 #cdv
        c = Shift(a, combo())
    end
    ExpressionState(program, a, b, c)
end

day17() = begin
    lines = readlines("data/day17.txt")
    a = parse(Int, match(r"([0-9]+)", lines[1])[1])
    b = parse(Int, match(r"([0-9]+)", lines[2])[1])
    c = parse(Int, match(r"([0-9]+)", lines[3])[1])
    program = map(eachmatch(r"([0-9]+)", lines[5])) do x parse(Int, x[1]) end

    @time begin
        out = Int[]
        state = State(program, a, b, c, 1)
        while state.pointer <= length(state.program)
            state = execute(state, out)
        end
        println("Part 1: $(join(out, ","))")
    end

    @time begin
        # Input programs seem to all end in jnz 3, and have no other accessible jnz -- thus, they're actually a single loop
        if program[end-1:end] != [3, 0]
            throw(ArgumentError("Program does not end in jnz 3"))
        end
        out = []
        shortprogram = program[1:end-2]
        state = ExpressionState(shortprogram, Symbolic(:a), Symbolic(:b), Symbolic(:c))
        pointer = 1
        for pointer ∈ 1:2:length(shortprogram)
            state = executeexpression(state, pointer, out)
        end
        # In the inputs we're given, both state.a and out[1] will be dependent only on a, and each iteration will output exactly one value.
        # Furthermore, it seems like state.a is always the old state.a, shifted right by n digits
        # We additionally assume that the program makes it somewhat easy to "reconstruct" the input -- in other words, the program only looks at the last 2n digits of the input
        # However, I'm not going to bother checking that last thing -- we'll check if by re-running the resulting input
        println("a = $(state.a)")
        println("out = $(out[1])")
        validrecursion(expr) = expr isa Shift && expr.a isa Symbolic && expr.a.symbol == :a && expr.b isa Literal
        if length(out) != 1 || !validrecursion(state.a) || requires(out[1], :b) || requires(out[1], :c)
            throw(ArgumentError("Program does not match expected pattern"))
        end
        n = state.a.b.value
        findvalue(aout, remaining) = begin
            if isempty(remaining)
                return aout
            end
            is = [i for i ∈ 0:(1 << n) - 1 if begin
                value = (aout << n) | i
                evaluate(out[1]; a = value) == remaining[1]
            end]
            for i ∈ 0:(1 << n) - 1
                value = (aout << n) | i
                if evaluate(out[1]; a = value) == remaining[1]
                    full = findvalue(value, remaining[2:end])
                    if !isnothing(full)
                        return full
                    end
                end
            end
            return nothing
        end
        value = findvalue(0, reverse(program))
        v = value
        checkinstructions = Int[]
        while v != 0
            push!(checkinstructions, evaluate(out[1]; a = v))
            v = evaluate(state.a; a = v)
        end
        if checkinstructions != program
            throw(ArgumentError("Program $program does not match reconstructed program $checkinstructions"))
        end
        println("Part 2: $value")
    end
end