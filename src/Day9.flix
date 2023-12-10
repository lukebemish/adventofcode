mod Day9 {
    pub def diff(reversed: List[Int32]): List[Int32] = List.map(match (a, b) -> a - b, List.zip(reversed, List.drop(1, reversed)))

    pub def allzeros(reversed: List[Int32]): Bool = List.foldRightWithCont(i -> b -> (i == 0) and b(), true, reversed)

    pub def extrapolate(reversed: List[Int32]): Int32 =
        if (allzeros(reversed)) 0 else
        match reversed {
            case Nil => 0
            case h :: _ => h + extrapolate(diff(reversed))
        }
}

def day9(): Unit \ IO =
    match Files.readLines("input/day9") {
        case Ok(lines) =>
            let sequences = List.map(line -> List.filterMap(i -> Int32.fromString(i), String.words(line)), lines);
            let reversedsequences = List.map(s -> List.reverse(s), sequences);
            let extrapolated = List.map(l -> Day9.extrapolate(l), reversedsequences);
            println("Part 1: ${List.sum(extrapolated)}");
            let extrapolatedbefore = List.map(l -> Day9.extrapolate(l), sequences);
            println("Part 2: ${List.sum(extrapolatedbefore)}")
        case _ => Console.println("Error opening file")
    }