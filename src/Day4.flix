mod Day4 {
    pub enum Card(List[Int32], List[Int32]) with ToString

    pub def parsecard(card: String): Option[Card] =
        let parts = String.split(regex = "[:|]", card);
        match (parts) {
            case _cardname :: w :: n :: _ =>
                let winning = List.filterMap(s -> Int32.fromString(s), String.words(w));
                let numbers = List.filterMap(s -> Int32.fromString(s), String.words(n));
                Some(Card.Card(winning, numbers))
            case _ => None
        }
    
    pub def points(card: Card): Int32 = match card {
        case Card.Card(winning, numbers) =>
            List.foldLeft(p -> n -> if (List.memberOf(n, winning)) if (p == 0) 1 else p * 2 else p, 0, numbers)
    }

    pub def matching(card: Card): Int32 = match card {
        case Card.Card(winning, numbers) =>
            List.foldLeft(p -> n -> if (List.memberOf(n, winning)) p + 1 else p, 0, numbers)
    }
}

def day4(): Unit \ IO = 
    match Files.readLines("input/day4") {
        case Err(_) => Console.println("Error opening file")
        case Ok(lines) =>
            let cards = List.filterMap(s -> Day4.parsecard(s), lines);
            Console.println("Part 1: ${List.fold(foreach(c <- cards) yield Day4.points(c))}");
            def cardcount(count: Int32, cardpoints: List[Int32], counts: List[Int32]): Int32 = (
                match List.head(cardpoints) {
                    case None => count
                    case Some(p) =>
                        let extracount = match List.head(counts) {
                            case None => 0
                            case Some(c) => c
                        };
                        let rest = List.drop(1, cardpoints);
                        let restcounts = List.drop(1, counts);
                        def buildcount(rem: Int32, remCount: List[Int32]): List[Int32] = match remCount {
                            case Nil => if (rem != 0) List.repeat(rem, extracount + 1) else Nil
                            case c :: cs => if (rem > 0) (c + extracount + 1) :: buildcount(rem - 1, cs) else c :: cs
                        };
                        let joined = buildcount(p, restcounts);
                        cardcount(count + extracount + 1, rest, joined)
                }
            );
            //Console.println("Part 2: ${cardcount(0, 5 :: 1 :: 2 :: 0 :: 0 :: 3 :: 0 :: 0 :: Nil, Nil)}")
            Console.println("Part 2: ${cardcount(0, foreach(c <- cards) yield Day4.matching(c), Nil)}")
    }