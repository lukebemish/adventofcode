mod Day9 {
    pub def diff(reversed: List[Int32]): List[Int32] = List.map(match (a, b) -> a - b, List.zip(reversed, List.drop(1, reversed)))

    pub def allzeros(reversed: List[Int32]): Bool = List.length(List.filter(i -> i != 0, reversed)) == 0

    def builddiffs(reversed: List[Int32], diffs: List[List[Int32]]): List[List[Int32]] =
        if (allzeros(reversed)) diffs else
        let diff = diff(reversed);
        builddiffs(diff, diff :: diffs)

    pub def extrapolate(reversed: List[Int32]): Int32 =
        let diffs = builddiffs(reversed, reversed :: Nil);
        let heads = List.filterMap(l -> List.head(l), diffs);
        List.sum(heads)
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