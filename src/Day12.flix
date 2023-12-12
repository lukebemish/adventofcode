mod Day12 {
    pub def memoizeNest(g: (a -> c \ IO) -> a -> c \ IO): a -> c \ IO with Order[a] = region rc {
        let cache = MutMap.new(rc);
        def gMem(x: a): c \ IO = match MutMap.get(x, cache) {
            case Some(y) => checked_ecast(y)
            case None =>
                let y: c = g(gMem, x);
                MutMap.put!(x, y, cache);
                y
        };
        gMem
    }
    pub enum State with Order, Eq {
        case State(List[Int32], List[List[Bool]], Bool)
    }
}

def day12(): Unit \ IO =
    match Files.readLines("input/day12") {
        case Ok(lines) => 
            let linepairs = List.filterMap(line -> match String.split(regex = "\\s", line) {
                case a :: b :: _ => Some((a, List.filterMap(Int32.fromString, String.split(regex = ",", b))))
                case _ => None
            }, lines);
            def neededspace(sizes: List[Int32]): Int32 = List.sum(sizes) + List.length(sizes) - 1;
            def spacein(chargroups: List[List[_]]): Int32 = List.sum(List.map(List.length, chargroups)) + List.length(chargroups) - 1;
            // true = required, false = optional
            def place(callback: List[Int32] -> List[List[Bool]] -> Bool -> Int64 \ IO, sizes: List[Int32], chargroups: List[List[Bool]], atStartOuter: Bool): Int64 \ IO = match (sizes, chargroups) {
                case (_, Nil :: rest) => place(callback, sizes, rest, true)
                case (sz :: rest, _) => (
                    let neededspacerest = neededspace(rest);
                    def tryformathead(groups: List[List[Bool]], atStart: Bool): List[List[List[Bool]]] = if (atStart) match groups {
                        case xs :: restchars => if (List.length(xs) >= sz)
                            (if (spacein(groups) >= neededspacerest + sz) (xs :: restchars) :: tryformathead(groups, false) else Nil)
                        else if (List.foldRightWithCont(bl -> bl2 -> bl or bl2(), false, xs)) Nil
                        else if (spacein(restchars) >= neededspacerest + sz) tryformathead(restchars, true)
                        else Nil
                        case Nil => Nil
                    } else match groups {
                        case Nil :: restchars => tryformathead(restchars, true)
                        case (xh :: xs) :: restchars => if (List.length(xs) >= sz)
                            (if (xh or not (spacein(xs :: restchars) >= neededspacerest + sz)) Nil else (xs :: restchars) :: tryformathead(xs :: restchars, false))
                        else if (xh or List.foldRightWithCont(bl -> bl2 -> bl or bl2(), false, xs)) Nil
                        else if (spacein(restchars) >= neededspacerest + sz) tryformathead(restchars, true)
                        else Nil
                        case Nil => Nil
                    };
                    let idxs = tryformathead(chargroups, atStartOuter);
                    def forNested(chs: List[List[Bool]], atStart: Bool): Int64 \ IO = match chs {
                        case Nil :: restchars => forNested(restchars, true)
                        case xs :: Nil => callback(rest, List.drop(sz, xs) :: Nil, atStart)
                        case xs :: restchars => callback(rest, List.drop(sz, xs) :: restchars, atStart)
                        case Nil => callback(rest, chargroups, true)
                    };
                    List.fold(List.map(chs -> forNested(chs, false), idxs))
                )
                case _ => if (List.foldRightWithCont(chs -> b1 -> List.foldRightWithCont(b2 -> b3 -> b2 or b3(), false, chs) or b1(), false, chargroups)) 0i64 else 1i64
            };
            def placeSingle(sizes: List[Int32], chargroups: List[List[Bool]], atStartOuter: Bool): Int64 \ IO = place(placeSingle, sizes, chargroups, atStartOuter);
            let lineResults1 = List.map(match (chars, sizes) -> (
                let charparts = String.split(regex ="\\.+", chars);
                let chargroups = List.map(part -> List.map(ch -> ch == '#', String.toList(part)), charparts);
                let count = placeSingle(sizes, chargroups, true);
                count
            ), linepairs);
            def placeTuple(f: Day12.State -> Int64 \ IO, x: Day12.State): Int64 \ IO = match x {
                case Day12.State.State(q, r, s) => place(a -> b -> c -> f(Day12.State.State(a, b, c)), q, r, s)
            };
            let placeMemoize = Day12.memoizeNest(placeTuple);
            println("Part 1: ${List.fold(lineResults1)}");
            let lineResults2 = List.mapWithIndex(i -> match (chars, sizes) -> (
                let charparts = String.split(regex ="\\.+", List.join("?", List.repeat(5, chars)));
                let chargroups = List.map(part -> List.map(ch -> ch == '#', String.toList(part)), charparts);
                let count = placeMemoize(Day12.State.State(List.flatten(List.repeat(5, sizes)), chargroups, true));
                if (Int32.mod(i, 100) == 0) println("Part 2: ${i} / ${List.length(linepairs)}") else ();
                count
            ), linepairs);
            println("Part 2: ${List.fold(lineResults2)}")
        case _ => println("Error opening file")
    }