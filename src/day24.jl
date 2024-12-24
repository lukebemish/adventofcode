import Base: ==

abstract type WireExpr end

abstract type BinaryExpr <: WireExpr end

struct OrExpr <: BinaryExpr
    symbol::Symbol
    a::WireExpr
    b::WireExpr
end

struct AndExpr <: BinaryExpr
    symbol::Symbol
    a::WireExpr
    b::WireExpr
end

struct XorExpr <: BinaryExpr
    symbol::Symbol
    a::WireExpr
    b::WireExpr
end

struct SymbolExpr <: WireExpr
    symbol::Symbol
end

struct ExprContext{T <: WireExpr}
    expr::T
    lookup::AbstractDict{Symbol, Union{Bool, WireExpr}}
end

Base.hash(context::ExprContext, h::UInt) = begin
    h *= 29
    h += hashvalue(context.expr, context.lookup)
    h
end

(==)(a::ExprContext, b::ExprContext) = a.lookup === b.lookup && isequivalent(a.expr, b.expr, a.lookup)

isequivalent(a, b, lookup) = false
isequivalent(a::SymbolExpr, b::SymbolExpr, lookup) = begin
    aval = lookup[a.symbol]
    bval = lookup[b.symbol]
    if aval isa Bool && bval isa Bool
        a.symbol == b.symbol
    else
        isequivalent(a, bval, lookup)
    end
end
isequivalent(a::SymbolExpr, b, lookup) = begin
    aprimitive = lookup[a.symbol] isa Bool
    if aprimitive
        false
    else
        isequivalent(lookup[a.symbol], b, lookup)
    end
end
isequivalent(b, a::SymbolExpr, lookup) = isequivalent(a, b, lookup)
isequivalent(a::T, b::T, lookup) where T <: BinaryExpr = (isequivalent(a.a, b.a, lookup) && isequivalent(a.b, b.b, lookup)) || (isequivalent(a.a, b.b, lookup) && isequivalent(a.b, b.a, lookup))

hashvalue(expr::SymbolExpr, lookup) = lookup[expr.symbol] isa Bool ? hash(expr.symbol) : hashvalue(lookup[expr.symbol], lookup)
hashvalue(expr::OrExpr, lookup) = (hashvalue(expr.a, lookup) + hashvalue(expr.b, lookup)) * 31
hashvalue(expr::AndExpr, lookup) = (hashvalue(expr.a, lookup) + hashvalue(expr.b, lookup)) * 37
hashvalue(expr::XorExpr, lookup) = (hashvalue(expr.a, lookup) + hashvalue(expr.b, lookup)) * 41

rename(expr::T, name) where {T <: BinaryExpr} = T(name, expr.a, expr.b)

doswap(name1, name2, lookup, exprlookup) = begin
    expr1 = rename(lookup[name1], name2)
    expr2 = rename(lookup[name2], name1)
    lookup[name2] = expr1
    lookup[name1] = expr2
    empty!(exprlookup)
    for k ∈ keys(lookup)
        exprlookup[ExprContext(SymbolExpr(k), lookup)] = k
    end
end

correct(name::Symbol, expr::ExprContext{S}, lookup::Dict{ExprContext, Symbol}, swapped) where {S <: BinaryExpr} = begin
    if haskey(lookup, expr)
        existingsymbol = lookup[expr]
        if existingsymbol != name
            doswap(name, existingsymbol, expr.lookup, lookup)
            push!(swapped, name, existingsymbol)
        end
        return
    end

    nameof(x) = lookup[ExprContext(x, expr.lookup)]

    for v ∈ values(expr.lookup)
        if v isa BinaryExpr
            if nameof(v) == name
                missingexpr, targetexpr = if nameof(v.a) == nameof(expr.expr.a)
                    (v.b, expr.expr.b)
                elseif nameof(v.a) == nameof(expr.expr.b)
                    (v.b, expr.expr.a)
                elseif nameof(v.b) == nameof(expr.expr.a)
                    (v.a, expr.expr.b)
                elseif nameof(v.b) == nameof(expr.expr.b)
                    (v.a, expr.expr.a)
                else
                    continue
                end
                missingname = nameof(missingexpr)
                targetname = nameof(targetexpr)
                doswap(missingname, targetname, expr.lookup, lookup)
                push!(swapped, missingname, targetname)
                correct(missingname, ExprContext(expr.lookup[missingname], expr.lookup), lookup, swapped)
            end
        end
    end
end

evaluate(expr::Bool, _) = expr
evaluate(expr::SymbolExpr, lookup) = evaluate(lookup[expr.symbol], lookup)
evaluate(expr::OrExpr, lookup) = evaluate(expr.a, lookup) || evaluate(expr.b, lookup)
evaluate(expr::AndExpr, lookup) = evaluate(expr.a, lookup) && evaluate(expr.b, lookup)
evaluate(expr::XorExpr, lookup) = evaluate(expr.a, lookup) ⊻ evaluate(expr.b, lookup)

parseinput() = begin
    lines = readlines("data/day24.txt")
    wirevalues = IdDict{Symbol, Union{Bool, WireExpr}}()
    wires = IdSet{Symbol}()
    for line ∈ lines
        wireval = r"^([a-z0-9]+): ([01])$"
        wireexpr = r"^([a-z0-9]+) (AND|OR|XOR) ([a-z0-9]+) -> ([a-z0-9]+)$"
        m = match(wireval, line)
        if !isnothing(m)
            wirevalues[Symbol(m[1])] = m[2] == "1"
            push!(wires, Symbol(m[1]))
        else
            m = match(wireexpr, line)
            if !isnothing(m)
                push!(wires, Symbol(m[4]), Symbol(m[1]), Symbol(m[3]))
                if m[2] == "AND"
                    wirevalues[Symbol(m[4])] = AndExpr(Symbol(m[4]), SymbolExpr(Symbol(m[1])), SymbolExpr(Symbol(m[3])))
                elseif m[2] == "OR"
                    wirevalues[Symbol(m[4])] = OrExpr(Symbol(m[4]), SymbolExpr(Symbol(m[1])), SymbolExpr(Symbol(m[3])))
                elseif m[2] == "XOR"
                    wirevalues[Symbol(m[4])] = XorExpr(Symbol(m[4]), SymbolExpr(Symbol(m[1])), SymbolExpr(Symbol(m[3])))
                end
            end
        end
    end
    wires, wirevalues
end

day24() = begin
    wires, wirevalues, zwires, xwires, ywires = @time begin
        wires, wirevalues = parseinput()
        zwires = sort(filter(k -> string(k)[1] == 'z', collect(wires)))
        xwires = sort(filter(k -> string(k)[1] == 'x', collect(wires)))
        ywires = sort(filter(k -> string(k)[1] == 'y', collect(wires)))
        wires, wirevalues, zwires, xwires, ywires
    end

    @time begin
        number = 0
        for z in reverse(zwires)
            val = evaluate(wirevalues[z], wirevalues)
            number <<= 1
            number |= val
        end
        println("Part 1: ",number)
    end

    @time begin
        carries = []
        for i ∈ 1:length(zwires)
            if i == 1
                push!(carries, AndExpr(Symbol(""), SymbolExpr(xwires[i]), SymbolExpr(ywires[i])))
            elseif i == length(zwires)
                # no carry
            else
                carry = carries[i-1]
                push!(carries, OrExpr(Symbol(""), AndExpr(Symbol(""), SymbolExpr(xwires[i]), SymbolExpr(ywires[i])),
                    AndExpr(Symbol(""), carry, XorExpr(Symbol(""), SymbolExpr(ywires[i]), SymbolExpr(xwires[i])))))
            end
        end

        lookup = Dict{ExprContext, Symbol}()
        swapped = IdSet{Symbol}()
        for k ∈ keys(wirevalues)
            lookup[ExprContext(SymbolExpr(k), wirevalues)] = k
        end
        for i ∈ 1:length(zwires)
            digitexpr = if i == 1
                XorExpr(Symbol(""), SymbolExpr(xwires[i]), SymbolExpr(ywires[i]))
            elseif i == length(zwires)
                carries[i-1]
            else
                carry = carries[i-1]
                XorExpr(Symbol(""), XorExpr(Symbol(""), SymbolExpr(xwires[i]), SymbolExpr(ywires[i])), carry)
            end
            correct(zwires[i], ExprContext(digitexpr, wirevalues), lookup, swapped)
        end

        println("Part 2: ", join(sort(collect(swapped)), ','))
    end
end