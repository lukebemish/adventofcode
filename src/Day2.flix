mod Day2 {
    pub def parseline(line: String): { id = Int32, rounds = List[{ red = Int32, green = Int32, blue = Int32 }] } =
        let parts = String.split(regex = "[:;]", line);
        let gameId = Option.getWithDefault(0, Option.flatMap(
            id -> Result.find(_ -> true, Int32.parse(10, id)),
            Option.flatMap(
                part -> Capturing.groupCapture(regex"Game (?<id>\\d+)", part),
                List.head(parts)
            )
        ));
        let rounds = List.map(
            part -> {
                red = Option.getWithDefault(Ok(0), Option.map(s -> Int32.parse(10, s), Capturing.groupCapture(regex"\\D(?<red>\\d+) red", part))),
                green = Option.getWithDefault(Ok(0), Option.map(s -> Int32.parse(10, s), Capturing.groupCapture(regex"\\D(?<green>\\d+) green", part))),
                blue = Option.getWithDefault(Ok(0), Option.map(s -> Int32.parse(10, s), Capturing.groupCapture(regex"\\D(?<blue>\\d+) blue", part)))
            },
            List.drop(1, parts)
        );
        { id = gameId, rounds = List.filterMap(
            round -> match round {
                case { red = Ok(red), green = Ok(green), blue = Ok(blue) } => Some({ red = red, green = green, blue = blue })
                case _ => None
            },
            rounds
        ) }

    pub def isPossible(game: List[{ red = Int32, green = Int32, blue = Int32 }]): Bool =
        def visit(x, acc) = match x {
            case Nil => acc
            case { red = red, green = green, blue = blue } :: rest =>
                visit(rest, (red <= 12) and (green <= 13) and (blue <= 14) and acc)
        };
        visit(game, true)
}

def day2(): Unit \ IO =
    match Files.readLines("input/day2") {
        case Err(_) => Console.println("Error opening file")
        case Ok(lines) =>
            let games = List.map(line -> Day2.parseline(line), lines);
            let possibleGames = List.filterMap(g -> if (Day2.isPossible(g.rounds)) Some(g.id) else None, games);
            let sum = List.foldLeft(a -> b -> a + b, 0, possibleGames);
            Console.println("Part 1: ${sum}");
            let necessary = List.map(g -> {
                red = Option.getWithDefault(0, List.maximum(List.map(r -> r.red, g.rounds))),
                green = Option.getWithDefault(0, List.maximum(List.map(r -> r.green, g.rounds))),
                blue = Option.getWithDefault(0, List.maximum(List.map(r -> r.blue, g.rounds)))
            }, games);
            let powers = List.map(m -> m.red * m.green * m.blue, necessary);
            let sum2 = List.foldLeft(a -> b -> a + b, 0, powers);
            Console.println("Part 2: ${sum2}")
    }