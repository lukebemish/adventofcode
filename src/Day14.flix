mod Day14 {
    pub def smartZip(x: List[a], y: List[b], default: a): List[(a, b)] = match x {
        case Nil => y |> List.map(c -> (default, c))
        case _ => List.zip(x, y)
    }
}

def day14(): Unit \ IO =
    match Files.readLines("input/day14") {
        case Ok(lines) =>
            let start = Time.Epoch.milliseconds();
            // (built, dots)
            def tilt(ls: List[List[Char]]): List[List[Char]] = ls |> List.foldLeft(pairs -> chars ->
                Day14.smartZip(pairs, chars, (Nil, Nil)) |>
                List.map(match ((built, dots), char) -> if (char == 'O') (char :: built, dots) else if (char == '.') (built, '.' :: dots) else ('#' :: dots ++ built, Nil)),
                Nil
            ) |> List.map(match (built, dots) -> dots ++ built);
            let collapsed = lines |> List.map(String.toList) |> tilt;
            let rows = List.length(lines);
            let load = collapsed |> List.map(column -> column |> List.mapWithIndex(idx -> char -> if (char == 'O') idx + 1 else 0) |> List.sum) |> List.sum;
            println("Part 1: ${load}");
            def cycle(ls) = ls |> tilt |> tilt |> tilt |> tilt;
            let cycles = 1000000000;
            def runcycles(last, ls, n: Int32) = match n {
                case 0 => ls
                case _ => 
                    let cycled = cycle(ls);
                    let matched = last |> List.mapWithIndex(i -> body -> if (body == cycled) Some(i) else None) |> List.filterMap(identity) |> List.head;
                    match matched {
                        case None => runcycles(cycled :: last, cycled, n - 1)
                        case Some(i) =>
                            let remainder = Int32.mod(n, (i + 1));
                            runcycles(Nil, ls, remainder)
                    }
                    
            };
            let final = runcycles(Nil, lines |> List.map(String.toList), cycles);
            let finalLoad = final |> List.mapWithIndex(idx -> column -> column |> List.map(char -> if (char == 'O') rows - idx else 0) |> List.sum) |> List.sum;
            println("Part 2: ${finalLoad}");
            let end = Time.Epoch.milliseconds();
            println("Time: ${Int64.toFloat64(end - start)/1000.0}s")
        case _ => println("Error opening file")
    }