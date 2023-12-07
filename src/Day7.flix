mod Day7 {
    pub enum HandWithCards(Int32, List[Int32]) with Eq, ToString

    instance Order[HandWithCards] {
        pub def compare(h1: HandWithCards, h2: HandWithCards): Comparison = match (h1, h2) {
            case (HandWithCards.HandWithCards(hand1, cards1), HandWithCards.HandWithCards(hand2, cards2)) => if (hand1 == hand2) Order.compare(cards1, cards2) else Order.compare(hand1, hand2)
        }
    }

    pub def parsehand(hand: String, jokers: Bool): HandWithCards =
        let cards = String.toList(hand);
        let values = List.filterMap(c -> match c {
            case 'A' => Some(14)
            case 'K' => Some(13)
            case 'Q' => Some(12)
            case 'J' => if (jokers) Some(0) else Some(11)
            case 'T' => Some(10)
            case _ => Char.digit(radix = 10, c)
        }, cards);
        let sorted = List.sortBy(a -> -List.count(b -> b == a, values), values);
        let grouped = List.groupBy(a -> b -> a == b, sorted);
        let jokercount = List.count(a -> a == 0, values);
        let regrouped = match List.dropWhile(l -> match List.head(l) {
            case Some(0) => true
            case _ => false
        }, grouped) {
            case (x :: xs) :: rest => List.append(List.repeat(jokercount + 1, x), xs) :: rest
            case Nil => List.repeat(jokercount, 0) :: Nil
            case a => a
        };
        def handofgroup(grouping) = match List.head(grouping) {
            case Some(head) =>
                if (List.length(head) == 5) 7
                else if (List.length(head) == 4) 6
                else if (List.length(head) == 3)
                    match List.head(List.drop(1, grouping)) {
                        case Some(head2) =>
                            if (List.length(head2) == 2) 5
                            else 4
                        case _ => 4
                    }
                else if (List.length(head) == 2)
                    match List.head(List.drop(1, grouping)) {
                        case Some(head2) =>
                            if (List.length(head2) == 2) 3
                            else 2
                        case _ => 2
                    }
                else
                    1
            case _ => 1
        };
        let h1 = handofgroup(regrouped);
        let h2 = handofgroup(grouped);
        let finalhand = if (h1 >= h2) h1 else h2;
        HandWithCards.HandWithCards(finalhand, values)
}

def day7(): Unit \ IO =
    match Files.readLines("input/day7") {
        case Ok(lines) =>
            let pairs1 = List.filterMap(line -> 
                let ws = String.words(line);
                match (Option.map(w -> Day7.parsehand(w, false), List.head(ws)), Option.flatMap(w -> Int32.fromString(w), List.head(List.drop(1, ws)))) {
                    case (Some(hand), Some(bid)) => Some((hand, bid))
                    case _ => None
                },
            lines);
            let sorted1 = List.sortBy(match (a, _) -> a, pairs1);
            let winnings1 = List.mapWithIndex(i -> match (_, w) -> (i + 1) * w, sorted1);
            println("Part 1: ${List.sum(winnings1)}");
            let pairs2 = List.filterMap(line -> 
                let ws = String.words(line);
                match (Option.map(w -> Day7.parsehand(w, true), List.head(ws)), Option.flatMap(w -> Int32.fromString(w), List.head(List.drop(1, ws)))) {
                    case (Some(hand), Some(bid)) => Some((hand, bid))
                    case _ => None
                },
            lines);
            let sorted2 = List.sortBy(match (a, _) -> a, pairs2);
            let winnings2 = List.mapWithIndex(i -> match (_, w) -> (i + 1) * w, sorted2);
            println("Part 2: ${List.sum(winnings2)}")
        case _ => Console.println("Error opening file")
    }