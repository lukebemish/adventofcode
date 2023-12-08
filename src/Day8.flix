mod Day8 {
    use Instruction.{Left, Right}

    pub def parseconnection(line: String): (String, (String, String)) =
        let parse = String.split(regex = "[^A-Z]+", line);
        match parse {
            case fr :: l :: r :: _ => (fr, (l, r))
            case _ => ("", ("", ""))
        }
    
    pub enum Instruction with ToString, Eq {
        case Left,
        case Right
    }

    pub def parseinstructions(line: String): Vector[Option[Instruction]] =
        Vector.map(c -> match c {
            case 'L' => Some(Left)
            case 'R' => Some(Right)
            case _ => None
        }, String.toVector(line))
    
    pub def lcm(ls: List[Int64]): Int64 = match ls {
        case Nil => 1i64
        case a :: Nil => a
        case a :: b :: Nil => (a * b) / gcd2(a, b)
        case a :: b :: rest => lcm(lcm(a :: b :: Nil) :: rest)
    }

    def gcd2(a: Int64, b: Int64): Int64 =
        if (a == 0i64 or b == 0i64) a + b else
        let max = Int64.max(a, b);
        let min = Int64.min(a, b);
        gcd2(Int64.mod(max, min), min)
}

def day8(): Unit \ IO =
    match Files.readLines("input/day8") {
        case Ok(lr :: _ :: connectionlines) =>
            use Day8.Instruction;
            use Instruction.{Left, Right};
            let connectionlist = List.map(Day8.parseconnection, connectionlines);
            let connectionmap = List.toMap(connectionlist);
            let instructions = Day8.parseinstructions(lr);
            def navigate(sofar: Int32, current: String, pos: Int32, target: String -> Bool): (Int32, String) \ {} = (
                if (target(current) and sofar > 0) (sofar, current) else
                let targetPos = if (pos > Vector.length(instructions) - 1) 0 else pos;
                let instruction = Vector.get(targetPos, instructions);
                let destinations = Map.get(current, connectionmap);
                let next = match (instruction, destinations) {
                    case (Some(Left), Some((l, _))) => Some(l)
                    case (Some(Right), Some((_, r))) => Some(r)
                    case _ => None
                };
                match next {
                    case Some(n) => navigate(sofar + 1, n, targetPos + 1, target)
                    case None => (sofar, current)
                }
            );
            println("Part 1: ${navigate(0, "AAA", 0, s -> s == "ZZZ")}");
            let endswitha: List[String] = List.filterMap(match (s, _) -> if (String.endsWith(suffix = "A", s)) Some(s) else None, connectionlist);
            let ends = List.map(s -> navigate(0, s, 0, s2 -> String.endsWith(suffix = "Z", s2)), endswitha);
            let toreachend = List.map(match (s, _) -> s, ends);
            let cyclestarts = List.map(match (_, s) -> s, ends);
            let toreachcycle = List.map(match(s, _) -> s, List.map(s -> navigate(0, s, 0, t -> s == t), cyclestarts));
            println("Are cycles and starts equal: ${toreachend == toreachcycle}");
            println("Part 2: ${Day8.lcm(List.map(i -> Int32.toInt64(i), toreachcycle))}")
            //println("Part 2: ${navigate2(0, endswitha, instructions)}")
        case _ => Console.println("Error opening file")
    }