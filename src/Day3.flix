mod Day3 {
    pub enum Label(Vector[(Int32, Int32)]) with Eq, Order, ToString

    pub def numbers(lines: List[String], vectorlines: Vector[String]): (List[Label], Vector[Vector[Option[Label]]]) = region rc{
        let arr = Array.init(rc, _ -> Array.repeat(rc, String.length(Vector.get(0, vectorlines)), None), Vector.length(vectorlines));
        let labels = List.flatten(List.mapWithIndex(y -> line ->
            let builder = String.foldLeft(builder -> c -> if (Char.isDigit(c))
                if (builder.xStart == -1)
                    { xStart = builder.cursor, parts = builder.parts, cursor = builder.cursor + 1 }
                else 
                    { xStart = builder.xStart, parts = builder.parts, cursor = builder.cursor + 1 }
            else 
                if (builder.xStart == -1)
                    { xStart = -1, parts = builder.parts, cursor = builder.cursor + 1 }
                else
                    let label = Label.Label(List.toVector(List.map(x -> (x, y), List.range(builder.xStart, builder.cursor))));
                    foreach (x <- List.range(builder.xStart, builder.cursor)) {
                        Array.put(Some(label), x, Array.get(y, arr))
                    };
                    { xStart = -1, parts = label :: builder.parts, cursor = builder.cursor + 1 }
            , { xStart = -1, parts = Nil, cursor = 0 }, line);
            if (builder.xStart != -1)
                let label = Label.Label(List.toVector(List.map(x -> (x, y), List.range(builder.xStart, builder.cursor))));
                foreach (x <- List.range(builder.xStart, builder.cursor)) {
                    Array.put(Some(label), x, Array.get(y, arr))
                };
                label :: builder.parts
            else
                builder.parts,
            lines
        ));
        (labels, Array.toVector(Array.map(rc, a -> Array.toVector(a), arr)))
    }

    pub def parts(lines: List[String], vectorlines: Vector[String], predicate: Char -> Bool): (List[Label], Vector[Vector[Option[Label]]]) = region rc{
        let arr = Array.init(rc, _ -> Array.repeat(rc, String.length(Vector.get(0, vectorlines)), None), Vector.length(vectorlines));
        let labels = List.flatten(List.mapWithIndex(y -> line ->
            fst(String.foldLeft(pair -> c -> let (list, cursor) = pair;
                if (c != '.' and predicate(c))
                    let label = Label.Label(Vector#{(cursor, y)});
                    Array.put(Some(label), cursor, Array.get(y, arr));
                    (label :: list, cursor + 1) else (list, cursor + 1),
            (Nil, 0), line)),
            lines
        ));
        let vec = Array.toVector(Array.map(rc, a -> Array.toVector(a), arr));
        (labels, vec)
    }

    pub def map(tuple: (List[Label], Vector[Vector[Option[Label]]])): (Vector[Label], Vector[Vector[Option[Int32]]]) =
        let (labels, grid) = tuple;
        (List.toVector(labels), foreach (row <- grid) yield foreach (entry <- row) yield Option.flatMap(l -> List.indexOf(l, labels), entry))

    pub def connections[a: Type](source: Vector[Vector[Option[a]]], target: Vector[Vector[Option[a]]]): Map[a, Set[a]] with Order[a] = region rc {
        let builder = MutMap.new(rc);
        foreach(y <- List.range(0, Vector.length(source)); x <- List.range(0, Vector.length(Vector.get(0, source)))) {
            let number = Vector.get(x, Vector.get(y, source));
            foreach (dx <- Vector#{-1, 0, 1}; dy <- Vector#{-1, 0, 1}) {
                let (nx, ny) = (x + dx, y + dy);
                let part = if (nx < 0 or ny < 0 or nx >= Vector.length(Vector.get(0, target)) or ny >= Vector.length(target))
                    None
                else
                    Vector.get(nx, Vector.get(ny, target));
                match (number, part) {
                    case (Some(n), Some(p)) => MutMap.put!(n, Set.insert(p, MutMap.getWithDefault(n, Set#{}, builder)), builder)
                    case _ => ()
                }
            }
        };
        MutMap.toMap(builder)
    }

    pub def findlabel(lines: Vector[String], label: Label): String = match label {
        case Label.Label(points) => region rc {
            let builder = StringBuilder.new(rc);
            foreach (p <- points) {
                let c = atpoint(lines, fst(p), snd(p));
                StringBuilder.append!(c, builder)
            };
            StringBuilder.toString(builder)
        }
    }

    def atpoint(lines: Vector[String], x: Int32, y: Int32): Char =
        if (x < 0 or y < 0)
            '.'
        else if (x >= String.length(Vector.get(0, lines)) or y >= Vector.length(lines))
            '.'
        else
            String.charAt(x, Vector.get(y, lines))
}

def day3(): Unit \ IO = 
    match Files.readLines("input/day3") {
        case Err(_) => Console.println("Error opening file")
        case Ok(lines) =>
            let vectorlines = List.toVector(lines);
            let (_, partmap) = Day3.map(Day3.parts(lines, vectorlines, c -> not Char.isDigit(c)));
            let (numbers, numbermap) = Day3.map(Day3.numbers(lines, vectorlines));
            let connections = Day3.connections(numbermap, partmap);
            let partnumbers = Map.keysOf(connections);
            let sum = Set.foldLeft(s -> p -> match Int32.fromString(Day3.findlabel(vectorlines, Vector.get(p, numbers))) {
                case None => s
                case Some(n) => s + n
            }, 0, partnumbers);
            Console.println("Part 1: " + Int32.toString(sum));

            let (_, gearcandidatemap) = Day3.map(Day3.parts(lines, vectorlines, c -> c == '*'));
            let gearconnections = Day3.connections(gearcandidatemap, numbermap);

            def numberpart(idx: Int32): Vector[Int32] = match Int32.fromString(Day3.findlabel(vectorlines, Vector.get(idx, numbers))) {
                case None => Vector#{}
                case Some(n) => Vector#{n}
            };

            def connectioncount(g: Int32): Vector[Int32] = Vector#{Set.size(Map.getWithDefault(g, Set#{}, gearconnections))};

            let rules = #{
                LabelCount(g, j) :- StarPart(g), let j = connectioncount(g).
                Gear(g) :- LabelCount(g, 2).
                PartNumber(l, n) :- Label(l), let n = numberpart(l).
                Ratio(g, n1 * n2) :- Gear(g), Labels(g, l1), Labels(g, l2), PartNumber(l1, n1), PartNumber(l2, n2), if l1 > l2.
            };
            let starparts = inject Map.keysOf(gearconnections) into StarPart;
            let labels = inject List.range(0, Vector.length(numbers)) into Label;
            let neighbors = inject List.flatten(
                foreach (k <- Map.keysOf(gearconnections)) yield
                    foreach (v <- Map.getWithDefault(k, Set#{}, gearconnections)) yield (k, v)
            ) into Labels;
            let result = query rules, starparts, labels, neighbors select r from Ratio(g, r);
            Console.println("Part 2: " + Int32.toString(Vector.fold(result)))
    }