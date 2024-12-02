mod Day23 {
    pub enum Tile with ToString, Eq {
        case Full, Empty, Right, Left, North, South
    }

    pub def parseAsTile(c: Char): Option[Tile] =
        match c {
            case '#' => Some(Tile.Full)
            case '.' => Some(Tile.Empty)
            case '>' => Some(Tile.Right)
            case '<' => Some(Tile.Left)
            case '^' => Some(Tile.North)
            case 'v' => Some(Tile.South)
            case _ => None
        }
    
    pub def atLocation(x: Int32, y: Int32, grid: Vector[Vector[Tile]]): Tile =
        if (y < 0 or y >= Vector.length(grid))
            Tile.Full
        else
            let row = Vector.get(y, grid);
            if (x < 0 or x >= Vector.length(row))
                Tile.Full
            else
                Vector.get(x, row)
    
    pub def propogate(pos: (Int32, Int32), grid: Vector[Vector[Tile]]): Int32 =
        def acc(data: List[((Int32, Int32), (Int32, Int32), Int32)]): List[((Int32, Int32), (Int32, Int32), Int32)] = (
            let new = data |>
                List.flatMap(match ((x, y), last, count) ->
                    let current = atLocation(x, y, grid);
                    if ((x, y) == last) ((x, y), last, count) :: Nil else
                    if (y == Vector.length(grid) - 1 and match current {
                        case Tile.Full => false
                        case _ => true
                    }) ((x, y), (x, y), count) :: Nil else
                    let left = if (last == (x - 1, y)) None else Some(((x - 1, y), (x, y), count + 1));
                    let right = if (last == (x + 1, y)) None else Some(((x + 1, y), (x, y), count + 1));
                    let north = if (last == (x, y - 1)) None else Some(((x, y - 1), (x, y), count + 1));
                    let south = if (last == (x, y + 1)) None else Some(((x, y + 1), (x, y), count + 1));
                    match current {
                        case Tile.Full => Nil
                        case Tile.Left => Option.toList(left)
                        case Tile.Right => Option.toList(right)
                        case Tile.North => Option.toList(north)
                        case Tile.South => Option.toList(south)
                        case Tile.Empty =>
                            List.filterMap(identity, left :: right :: north :: south :: Nil)
                    }
                );
            if (new == data) data else acc(new)
        );
        let result = acc(((pos, (-1, -1), 0) :: Nil));
        result |> List.map(match ((_, _, count)) -> count) |> List.maximum |> Option.getWithDefault(0)
    
    pub def propogateDry(pos: (Int32, Int32), grid: Vector[Vector[Tile]]): Int32 =
        def acc(data: List[((Int32, Int32), (Int32, Int32), Set[(Int32, Int32)], Int32)]): List[((Int32, Int32), (Int32, Int32), Set[(Int32, Int32)], Int32)] = (
            let new = data |>
                List.flatMap(match ((x, y), last, all, count) ->
                    def hasVisited(x1: Int32, y1: Int32): Bool =
                        Set.memberOf((x1, y1), all) or (x1, y1) == last;
                    let current = atLocation(x, y, grid);
                    if (hasVisited(x, y)) ((x, y), last, all, count) :: Nil else
                    if (y == Vector.length(grid) - 1 and match current {
                        case Tile.Full => false
                        case _ => true
                    }) ((x, y), (x, y), Set#{(x, y)}, count) :: Nil else
                    let borders = List#{
                        atLocation(x - 1, y, grid),
                        atLocation(x + 1, y, grid),
                        atLocation(x, y - 1, grid),
                        atLocation(x, y + 1, grid)
                    };
                    let neighbors = borders |> List.count(b -> match b {
                        case Tile.Empty => true
                        case _ => false
                    });
                    let newAll = if (neighbors > 2) Set.insert((x, y), all) else all;
                    let left = if (hasVisited(x - 1, y)) None else Some(((x - 1, y), (x, y), newAll, count + 1));
                    let right = if (hasVisited(x + 1, y)) None else Some(((x + 1, y), (x, y), newAll, count + 1));
                    let north = if (hasVisited(x, y - 1)) None else Some(((x, y - 1), (x, y), newAll, count + 1));
                    let south = if (hasVisited(x, y + 1)) None else Some(((x, y + 1), (x, y), newAll, count + 1));
                    match current {
                        case Tile.Full => Nil
                        case _ =>
                            List.filterMap(identity, left :: right :: north :: south :: Nil)
                    }
                );
            if (new == data) data else acc(new)
        );
        let result = acc(((pos, (-1, -1), Set.empty(), 0) :: Nil));
        result |> List.map(match ((_, _, _, count)) -> count) |> List.maximum |> Option.getWithDefault(0)
}

def day23(): Unit \ IO =
    match Files.readLines("input/day23") {
        case Ok(lines) =>
            let start = Time.Epoch.milliseconds();
            let grid = lines |> List.map(s -> String.toList(s) |> List.filterMap(Day23.parseAsTile)) |> List.map(List.toVector) |> List.toVector;
            let maximumWalk = Day23.propogate((1, 0), grid);
            println("Part 1: ${maximumWalk}");
            let maximumWalkDry = Day23.propogateDry((1, 0), grid);
            println("Part 2: ${maximumWalkDry}");
            let end = Time.Epoch.milliseconds();
            println("Time: ${Int64.toFloat64(end - start)/1000.0}s")
        case _ => println("Error opening file")
    }