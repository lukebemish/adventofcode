mod Day13 {
    pub enum Zipper[a] with ToString, Eq {
        case Zipper(List[a], List[a])
    }

    pub def flip(chunk: List[String]): List[String] =
        List.foldLeft(ls -> l -> List.zipWith(c -> list -> c :: list, String.toList(l), ls), List.repeat(Option.getWithDefault(0, List.head(chunk) |> Option.map(String.length)), Nil), chunk) |>
        List.map(cs -> List.join("", cs))

    pub def reflectionpoint(chunk: List[String]): List[Int32] =
        def listEq(l1: List[String], l2: List[String]): Bool = match (l1, l2) {
            case (h1 :: t1, h2 :: t2) => h1 == h2 and listEq(t1, t2)
            case _ => true
        };
        def acc(zip: Zipper[String], idx: Int32): List[Int32] = match zip {
                case Zipper.Zipper(_, Nil) => Nil
                case Zipper.Zipper(Nil, rh :: right) => acc(Zipper.Zipper(rh :: Nil, right), idx + 1)
                case Zipper.Zipper(left, rh :: right) => if (listEq(left, rh :: right)) idx :: acc(Zipper.Zipper(rh :: left, right), idx + 1) else acc(Zipper.Zipper(rh :: left, right), idx + 1)
            };
        acc(Zipper.Zipper(Nil, chunk), 0)
    
    pub def reflectionsmudge(chunk: List[String]): List[Int32] =
        def stringDiff(s1: String, s2: String): Int32 = List.sum(List.zipWith(c1 -> c2 -> if (c1 != c2) 1 else 0, String.toList(s1), String.toList(s2)));
        def listDiff(l1: List[String], l2: List[String]): Int32 = match (l1, l2) {
            case (h1 :: t1, h2 :: t2) => stringDiff(h1, h2) + listDiff(t1, t2)
            case _ => 0
        };
        def acc(zip: Zipper[String], idx: Int32): List[Int32] = match zip {
                case Zipper.Zipper(_, Nil) => Nil
                case Zipper.Zipper(Nil, rh :: right) => acc(Zipper.Zipper(rh :: Nil, right), idx + 1)
                case Zipper.Zipper(left, rh :: right) => if (listDiff(left, rh :: right) == 1) idx :: acc(Zipper.Zipper(rh :: left, right), idx + 1) else acc(Zipper.Zipper(rh :: left, right), idx + 1)
            };
        acc(Zipper.Zipper(Nil, chunk), 0)
}

def day13(): Unit \ IO =
    match Files.readLines("input/day13") {
        case Ok(lines) =>
            let chunks = List.foldLeft(chunks -> l -> if (String.isEmpty(l)) Nil :: chunks else match chunks {
                case h :: r => (l :: h) :: r
                case _ => (l :: Nil) :: Nil
            }, Nil, lines) |> List.map(List.reverse);
            let horizontalReflections = List.map(chunk -> Day13.reflectionpoint(chunk), chunks);
            let verticalReflections = List.map(chunk -> Day13.reflectionpoint(Day13.flip(chunk)), chunks);
            let sum = List.sum(List.flatMap(identity, horizontalReflections)) * 100 + List.sum(List.flatMap(identity, verticalReflections));
            println("Part 1: ${sum}");
            let horizontalReflectionsSmudged = List.map(chunk -> Day13.reflectionsmudge(chunk), chunks);
            let verticalReflectionsSmudged = List.map(chunk -> Day13.reflectionsmudge(Day13.flip(chunk)), chunks);
            let sumSmudged = List.sum(List.flatMap(identity, horizontalReflectionsSmudged)) * 100 + List.sum(List.flatMap(identity, verticalReflectionsSmudged));
            println("Part 2: ${sumSmudged}")
        case _ => println("Error opening file")
    }