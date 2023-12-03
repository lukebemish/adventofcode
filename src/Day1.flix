def day1(): Unit \ IO =
    match Files.readLines("input/day1") {
        case Err(_) => Console.println("Error opening file")
        case Ok(lines) =>
            let values = List.map(line -> match Day1.calibrationvalue(line) {
                case Some(value) => value
                case None => 0
            }, lines);
            let sum = List.foldLeft(a -> b -> a + b, 0, values);
            Console.println(sum)
    }

mod Day1 {
    enum Digit {
        case Zero
        case One
        case Two
        case Three
        case Four
        case Five
        case Six
        case Seven
        case Eight
        case Nine
    }

    def stringvalue(d: Digit): String =
        match d {
            case Digit.Zero => "zero"
            case Digit.One => "one"
            case Digit.Two => "two"
            case Digit.Three => "three"
            case Digit.Four => "four"
            case Digit.Five => "five"
            case Digit.Six => "six"
            case Digit.Seven => "seven"
            case Digit.Eight => "eight"
            case Digit.Nine => "nine"
        }

    def digitvalue(d: Digit): Int32 =
        match d {
            case Digit.Zero => 0
            case Digit.One => 1
            case Digit.Two => 2
            case Digit.Three => 3
            case Digit.Four => 4
            case Digit.Five => 5
            case Digit.Six => 6
            case Digit.Seven => 7
            case Digit.Eight => 8
            case Digit.Nine => 9
        }

    def alldigits(): List[Digit] =
        List#{
            Digit.Zero,
            Digit.One,
            Digit.Two,
            Digit.Three,
            Digit.Four,
            Digit.Five,
            Digit.Six,
            Digit.Seven,
            Digit.Eight,
            Digit.Nine
        }

    enum SearchState {
        case Searching(List[(Int32, String)])
        case Found(Int32)
    }

    def finddigit(s: String, text: Digit -> String): Option[Int32] = 
        let digits: Map[String, Digit] = List.toMap(List.map(d -> (text(d), d), alldigits()));
        let digitstrings: List[String] = List.map(d -> text(d), alldigits());
        match String.foldLeft(state -> c -> updateiter(state, c, digits, digitstrings), SearchState.Searching(Nil), s) {
            case SearchState.Searching(_) => Option.None
            case SearchState.Found(value) => Option.Some(value)
        }

    def updateiter(state: SearchState, c: Char, digits: Map[String, Digit], digitstrings: List[String]): SearchState =
        match state {
            case SearchState.Found(_) => state
            case SearchState.Searching(candidates) => Option.getWithDefault(
                let newCandidates = List.filterMap(pair -> updatesearch(pair, c), candidates);
                let found = List.filterMap(pair -> let (pos, full) = pair; if (String.length(full) - 1 == pos) Option.Some(full) else Option.None, newCandidates);
                match Option.flatMap(value -> match Map.get(value, digits) {
                    case Some(digit) => Some(digitvalue(digit))
                    case None => None
                }, List.head(found)) {
                    case Some(value) => SearchState.Found(value)
                    case None => SearchState.Searching(List.append(newCandidates, List.filterMap(st -> if (String.charAt(0, st) == c) Option.Some((0, st)) else Option.None, digitstrings)))
                },
                if (Char.isDigit(c)) Option.map(i -> SearchState.Found(i), Char.digit({radix = 10}, c)) else Option.None
            )
        }

    def updatesearch(pair: (Int32, String), c: Char): Option[(Int32, String)] =
        let (pos, full) = pair;
        let newPos = pos + 1;
        if (newPos < String.length(full) and String.charAt(newPos, full) == c) {
            Option.Some((newPos, full))
        } else {
            Option.None
        }

    pub def calibrationvalue(line: String): Option[Int32] = 
        Option.flatMap(fd -> Option.map(sd -> fd * 10 + sd, lastdigit(line)), firstdigit(line))

    def firstdigit(s: String): Option[Int32] =
        finddigit(s, d -> stringvalue(d))

    def lastdigit(s: String): Option[Int32] =
        finddigit(String.reverse(s), d -> String.reverse(stringvalue(d)))
}