def day11(): Unit \ IO =
    match Files.readLines("input/day11") {
        case Ok(lines) => 
            let marked = List.flatten(List.mapWithIndex(y -> line ->
                List.mapWithIndex(x -> c -> (x, y, c), String.toList(line)),
                lines
            ));
            let filtered = List.filterMap(match (x, y, c) -> if (c == '#') Some((x, y)) else None, marked);
            let maximumColumn = List.maximum(List.map(match (x, _) -> x, filtered));
            let maximumRow = List.maximum(List.map(match (_, y) -> y, filtered));
            match (maximumColumn, maximumRow) {
                case (Some(maxX), Some(maxY)) =>
                    let doubleColumns = List.toVector(List.map(x -> not List.exists(match (x1, _) -> x == x1, filtered), List.range(0, maxX)));
                    let doubleRows = List.toVector(List.map(y -> not List.exists(match (_, y1) -> y == y1, filtered), List.range(0, maxY)));
                    def pairDistance(x1, y1, x2, y2, expand: Int64) = (
                        let xL = Int32.min(x1, x2);
                        let xH = Int32.max(x1, x2);
                        let yL = Int32.min(y1, y2);
                        let yH = Int32.max(y1, y2);
                        let xs = List.range(xL, xH);
                        let ys = List.range(yL, yH);
                        let xSum = List.fold(List.map(x -> if (Vector.get(x, doubleColumns)) expand else 1i64, xs));
                        let ySum = List.fold(List.map(y -> if (Vector.get(y, doubleRows)) expand else 1i64, ys));
                        xSum + ySum
                    );
                    let distances = List.flatten(List.map(match (x1, y1) -> List.map(match (x2, y2) -> if (x1 != x2 or y1 != y2) pairDistance(x1, y1, x2, y2, 2i64) else 0i64, filtered), filtered));
                    println("Part 1: ${List.fold(distances)/2i64}");
                    let distances2 = List.flatten(List.map(match (x1, y1) -> List.map(match (x2, y2) -> if (x1 != x2 or y1 != y2) pairDistance(x1, y1, x2, y2, 1000000i64) else 0i64, filtered), filtered));
                    println("Part 2: ${List.fold(distances2)/2i64}")
                case _ => println("Error parsing file")
            }
        case _ => println("Error opening file")
    }