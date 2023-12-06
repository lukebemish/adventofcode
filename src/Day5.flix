mod Day5 {
    use Connection.Connection
    pub enum Connection(Int64, Int64, Int64) with ToString, Eq, Order

    pub def parseseeds(seeds: String): List[Int64] =
        let words = String.words(seeds);
        match words {
            case _ :: rest => List.filterMap(r -> Int64.fromString(r), rest)
            case _ => Nil
        }
    
    def parseconnectionline(line: String): Option[Connection] =
        match List.map(f -> Int64.fromString(f), String.words(line)) {
            case Some(dstStart) :: Some(srcStart) :: Some(length) :: Nil => Some(Connection(srcStart, dstStart, length))
            case _ => None
        }

    pub def parseconnections(lines: List[String]): Option[(List[Connection], String, String)] =
        match lines {
            case header :: entries => match String.split(regex = "[ -]", header) {
                case src :: _ :: dst :: _ => Some((List.filterMap(line -> parseconnectionline(line), entries), src, dst))
                case _ => None
            }
            case _ => None
        }
    
    pub def processconnections(values: List[Int64], connections: List[Connection]): List[Int64] =
        List.map(v ->
            let c = List.find(match Connection(src, _, len) -> v >= src and v < src + len, connections);
            match c {
                case Some(Connection(src, dst, _)) => dst + (v - src)
                case _ => v
            },
        values)
    
    enum Marker with Eq {
        case Start(Int64, Connection)
        case End(Connection, Int64)
    }

    def pos(m: Marker): Int64 = match m {
        case Marker.Start(p, _) => p
        case Marker.End(_, p) => p
    }

    instance Order[Marker] {
        pub def compare(a: Marker, b: Marker): Comparison = let o = Order.compare(pos(a), pos(b)); match o {
            case Comparison.EqualTo => match (a, b) {
                case (Marker.Start(_, _), Marker.End(_, _)) => Comparison.GreaterThan
                case (Marker.End(_, _), Marker.Start(_, _)) => Comparison.LessThan
                case _ => o
            }
            case _ => o
        }
    }
    
    // Apply l1 first, then l2
    pub def mergelayers(l1: List[Connection], l2: List[Connection]): List[Connection] = 
        let l1image = List.sort(List.flatMap(c -> match c { case Connection(_, s, l) => Marker.Start(s, c) :: Marker.End(c, s + l) :: Nil }, l1));
        let l2source = List.sort(List.flatMap(c -> match c { case Connection(s, _, l) => Marker.Start(s, c) :: Marker.End(c, s + l) :: Nil }, l2));
        // State is: built, original: Option[Connection], target: Option[Connection], from
        def build(image: List[Marker], source: List[Marker], state: (List[Connection], Option[Connection], Option[Connection], Int64)): List[Connection] = (let (built, original, target, frompoint) = state; let (is, ss, st) = match image {
            case Nil => (Nil, Nil, (built, original, target, frompoint))
            case i :: irest => match source {
                case Nil => (irest, Nil, match i {
                    case Marker.Start(p, c) => (built, Some(c), None, p)
                    case Marker.End(Connection(csrc, cdst, _), p) => let new = Connection(frompoint + (csrc - cdst), frompoint, p - frompoint); (new :: built, None, None, p)
                })
                case s :: srest =>
                    def handleimgend(csrc, cdst, p) = match target {
                        case Some(Connection(tsrc, tdst, _)) => let new = Connection(frompoint + (csrc - cdst), frompoint + (tdst - tsrc), p - frompoint); (new :: built, None, target, p)
                        case _ => let new = Connection(frompoint + (csrc - cdst), frompoint, p - frompoint); (new :: built, None, target, p)
                    };
                    def handlesrcend(tsrc, tdst, p) = match original {
                        case Some(Connection(osrc, odst, _)) => let new = Connection(frompoint + (osrc - odst), frompoint + (tdst - tsrc), p - frompoint); (new :: built, original, None, p)
                        case _ => (built, original, None, p)
                    };
                    if (i < s) match i {
                        case Marker.Start(p, c) => (irest, source, (built, Some(c), target, p))
                        case Marker.End(Connection(csrc, cdst, _), p) => (irest, source, handleimgend(csrc, cdst, p))
                    } else if (i > s) match s {
                        case Marker.Start(p, c) => (image, srest, match original {
                            case Some(Connection(csrc, cdst, _)) => let new = Connection(frompoint + (csrc - cdst), frompoint, p - frompoint); (new :: built, original, Some(c), p)
                            case _ => (built, original, Some(c), p)
                        })
                        case Marker.End(Connection(csrc, cdst, _), p) => (image, srest, handlesrcend(csrc, cdst, p))
                    } else match (i, s) {
                        case (Marker.Start(_, _), Marker.End(Connection(csrc, cdst, _), p)) => (image, srest, handlesrcend(csrc, cdst, p))
                        case (Marker.End(Connection(csrc, cdst, _), p), Marker.Start(_, _)) => (irest, source, handleimgend(csrc, cdst, p))
                        case (Marker.End(Connection(csrc, cdst, _), p), Marker.End(_, _)) => let (bs, _, _, _) = handleimgend(csrc, cdst, p); (irest, srest, (bs, None, None, p))
                        case (Marker.Start(p, c1), Marker.Start(_, c2)) => (irest, srest, (built, Some(c1), Some(c2), p))
                    }
            }
        }; match (is, ss) {
            case (Nil, Nil) => let (bs, _, _, _) = st; bs
            case _ => build(is, ss, st)
        });
        let built = List.filter(match Connection(_, _, l) -> l != 0i64, build(l1image, l2source, (Nil, None, None, 0i64)));
        built
}

def day5(): Unit \ IO =
    match Files.readLines("input/day5") {
        case Ok(seedsStr :: _ :: lines) =>
            def groupacc(groups: List[List[String]], current: List[String], rem: List[String]): List[List[String]] =
                match rem {
                    case Nil => List.reverse(current) :: groups
                    case x :: xs => 
                        match x {
                            case "" => groupacc(List.reverse(current) :: groups, Nil, xs)
                            case _ => groupacc(groups, x :: current, xs)
                        }
                };
            use Day5.{Connection => C};
            let groups = groupacc(Nil, Nil, lines);
            let seeds = Day5.parseseeds(seedsStr);
            let connectiongroups: List[(List[C], String, String)] = List.filterMap(g -> Day5.parseconnections(g), groups);
            let connectionlayers = List.reverse(List.map(match (cs, _, _) -> cs, connectiongroups));
            let seedsingleconnections = List.map(match s -> C.Connection(s, s, 1i64), seeds);
            let built = List.foldLeft(l1 -> l2 -> Day5.mergelayers(l1, l2), seedsingleconnections, connectionlayers);
            let processed = Day5.processconnections(seeds, built);
            println("Part 1: ${List.minimum(processed)}");
            let seedpairs = List.filterMap(match (i, p) -> if (Int32.bitwiseAnd(i, 1) == 0) Some(p) else None, List.mapWithIndex(i -> p -> (i, p), List.zip(seeds, List.drop(1, seeds))));
            let seedconnections = List.map(match (s1, s2) -> C.Connection(s1, s1, s2), seedpairs);
            let overlayed = List.foldLeft(l1 -> l2 -> Day5.mergelayers(l1, l2), seedconnections, connectionlayers);
            let dests = List.map(match C.Connection(_, d, _) -> d, overlayed);
            println("Part 2: ${List.minimum(dests)}")
        case _ => Console.println("Error opening file")
    }