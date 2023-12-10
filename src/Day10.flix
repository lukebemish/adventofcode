mod Day10 {
    use Direction.{Up, Down, Left, Right}

    enum Direction with Eq, Order {
        case Up, Down, Left, Right
    }

    def offset(x: Int32, y: Int32, direction: Direction): (Int32, Int32) =
        match direction {
            case Up => (x, y - 1)
            case Down => (x, y + 1)
            case Left => (x - 1, y)
            case Right => (x + 1, y)
        }
    
    def insidepathlength(original: Int32, px: Int32, py: Int32, c: Char, d: Direction, inside: (Int32, Int32)): LengthAndRel =
        let (x, y) = inside;
        let ((d1x, d1y), (d2x, d2y), relative) = match c {
            case 'F' => if (d == Left and y < 0)  ((-1, 0), (0,  1), (-1, 0)) else if (d == Up and x < 0)   ((0, -1), ( 1, 0), (0, -1)) else ((0, 0), (0, 0), ( y,  x))
            case 'J' => if (d == Right and y > 0) (( 1, 0), (0, -1), ( 1, 0)) else if (d == Down and x > 0) ((0,  1), (-1, 0), (0,  1)) else ((0, 0), (0, 0), ( y,  x))
            case '7' => if (d == Right and y < 0) (( 1, 0), (0,  1), ( 1, 0)) else if (d == Up and x > 0)   ((0, -1), (-1, 0), (0, -1)) else ((0, 0), (0, 0), (-y, -x))
            case 'L' => if (d == Left and y > 0)  ((-1, 0), (0, -1), (-1, 0)) else if (d == Down and x < 0) ((0,  1), ( 1, 0), (0,  1)) else ((0, 0), (0, 0), (-y, -x))
            case '|' => if (d == Up) ((0, -1), (0, 0), inside) else if (d == Down) ((0, 1), (0, 0), inside) else ((0, 0), (0, 0), inside)
            case '-' => if (d == Left) ((-1, 0), (0, 0), inside) else if (d == Right) ((1, 0), (0, 0), inside) else ((0, 0), (0, 0), inside)
            case _ => ((0, 0), (0, 0), inside)
        };
        let (px1, py1) = (px + d1x, py + d1y);
        (original + px*d1y - py*d1x + px1*d2y - py1*d2x, relative, (px1+d2x, py1+d2y))

    pub def explore(map: Vector[Vector[Char]], position: (Int32, Int32)): Map[(Int32, Int32), Int32] =
        def acc(log: Map[(Int32, Int32), Int32], states: List[(Int32, Int32, Int32)]): Map[(Int32, Int32), Int32] = (
            let newresults: (Map[(Int32, Int32), Int32], List[(Int32, Int32, Int32)]) = List.foldLeft(match (logB, results) -> match (x, y, distance) ->
                let (log1, results1) = travel(map, (x, y), logB, distance, false);
                (log1, List.append(results, List.map(match(a, b, l, _) -> (a, b, l), results1))),
                (log, Nil),
                states
            );
            match newresults {
                case (log1, Nil) => log1
                case (log1, results) => acc(log1, results)
            }
        );
        let (xO, yO) = position;
        acc(Map#{(xO, yO) => 0}, List#{(xO, yO, 0)})
    
    type alias LengthAndRel = (Int32, (Int32, Int32), (Int32, Int32))

    pub def area(map: Vector[Vector[Char]], position: (Int32, Int32)): (Int32, Int32) =
        let (xO, yO) = position;
        def acc(inside: LengthAndRel, outside: LengthAndRel, log: Map[(Int32, Int32), Int32], state: (Int32, Int32, Int32)): (Int32, Int32) \ {} = (
            let (x, y, distance) = state;
            let newresults = travel(map, (x, y), log, distance, true);
            let (insideArea, isRel, isPos) = inside;
            let (outsideArea, osRel, osPos) = outside;
            match newresults {
                case (_, Nil) => (insideArea, outsideArea)
                case (log1, (x1, y1, distance1, direction) :: _) =>
                    let c = Vector.get(x, Vector.get(y, map));
                    let (insideReal, outsideReal) = if (c == 'S') (
                        let (_, allDirs) = travel(map, (x, y), log, distance, false);
                        let dirs = List.map(match(_, _, _, d) -> d, allDirs);
                        let (is, os) = match dirs {
                            case Left :: _ => ((0, -1), (0, 1))
                            case Right :: _ => ((0, -1), (0, 1))
                            case _ => ((-1, 0), (1, 0))
                        };
                        (is, os)
                    ) else (isRel, osRel);
                    let (isX, isY) = isPos;
                    let (osX, osY) = osPos;
                    let cNew = Vector.get(x1, Vector.get(y1, map));
                    let inside1 = insidepathlength(insideArea, isX, isY, cNew, direction, insideReal);
                    let outside1 = insidepathlength(outsideArea, osX, osY, cNew, direction, outsideReal);
                    acc(inside1, outside1, log1, (x1, y1, distance1))
            }
        );
        // Using (0, 0) as start means that it doesn't matter if we lose the first/last connection
        acc((0, (0, 0), (0, 0)), (0, (0, 0), (0, 0)), Map#{(xO, yO) => 0}, (xO, yO, 0))

    def travel(map: Vector[Vector[Char]], position: (Int32, Int32), log: Map[(Int32, Int32), Int32], distance: Int32, oneWay: Bool): (Map[(Int32, Int32), Int32], List[(Int32, Int32, Int32, Direction)]) =
        let (x, y) = position;
        let c = Vector.get(x, Vector.get(y, map));
        let directions = match c {
            case 'S' => List#{Up, Down, Left, Right}
            case '|' => List#{Up, Down}
            case '-' => List#{Left, Right}
            case 'L' => List#{Up, Right}
            case 'J' => List#{Up, Left}
            case '7' => List#{Down, Left}
            case 'F' => List#{Down, Right}
            case _ => List#{}
        };
        let results = List.filterMap(d ->
            let (x1, y1) = offset(x, y, d);
            if (Map.getWithDefault((x1, y1), -1, log) >= 0) None else
            let c1 = Vector.get(x1, Vector.get(y1, map));
            if (match d {
                case Up => c1 == '|' or c1 == '7' or c1 == 'F' or c1 == 'S'
                case Down => c1 == '|' or c1 == 'L' or c1 == 'J' or c1 == 'S'
                case Left => c1 == '-' or c1 == 'L' or c1 == 'F' or c1 == 'S'
                case Right => c1 == '-' or c1 == '7' or c1 == 'J' or c1 == 'S'
            }) Some((x1, y1, d)) else None,
            directions
        );
        let resultsOnly1 = if (oneWay) match List.head(results) {
            case Some(r) => r :: Nil
            case _ => Nil
        } else results;
        let log1 = List.foldLeft(m -> match (a, b, _) -> Map.insert((a, b), distance + 1, m), log, resultsOnly1);
        (log1, List.map(match (x1, y1, d) -> (x1, y1, distance + 1, d), resultsOnly1))
}

def day10(): Unit \ IO =
    match Files.readLines("input/day10") {
        case Ok(lines) =>
            let chars: Vector[Vector[Char]] = List.toVector(List.map(line -> 
                List.toVector(String.toList(line)),
                lines
            ));
            let indexed = List.flatten(List.mapWithIndex(y -> line ->
                List.mapWithIndex(x -> c -> (x, y, c), String.toList(line)),
                lines
            ));
            let startPos = List.find(match (_, _, c) -> c == 'S', indexed);
            let result = forA((x, y, _) <- startPos) yield Day10.explore(chars, (x, y));
            let distance = Option.flatMap(m -> List.maximum(Map.valuesOf(m)), result);
            match distance {
                case Some(d) => println("Part 1: ${d}")
                case _ => ()
            };
            let arearesult = forA((x, y, _) <- startPos) yield Day10.area(chars, (x, y));
            match arearesult {
                case Some(a) => (
                    let (i, o) = a;
                    println("Part 2: ${Int32.abs(Int32.max(i, o))/2}")
                )
                case _ => ()
            }
        case _ => Console.println("Error opening file")
    }