mod Day6 {
    pub def lowertimefordistance(distance: Int64, maxtime: Int64): Option[Int64] =
        let fdist = Int64.toFloat64(distance);
        let t = Int64.toFloat64(maxtime);
        if (fdist > 0.25f64 * t * t)
            None
        else
            let ftime = - Float64.pow(-(fdist - 0.25f64 * t * t), 0.5f64) + 0.5f64 * t;
            Some(Float64.clampToInt64(Float64.floor(ftime), 0i64, maxtime + 1i64, 0i64))
}

def day6(): Unit \ IO =
    match Files.readLines("input/day6") {
        case Ok(timeline :: distanceline :: _) => match (String.words(timeline), String.words(distanceline)) {
            case (_ :: times, _ :: distances) =>
                let pairs = List.zip(List.filterMap(Int64.fromString, times), List.filterMap(Int64.fromString, distances));
                let numberofways = List.map(match (time, distance) ->
                    match Day6.lowertimefordistance(distance, time) {
                        case Some(lowertime) =>
                            let mosttime = time/2i64;
                            let diff = mosttime - lowertime;
                            if (Int64.mod(time, 2i64) == 0i64) (diff) * 2i64 - 1i64 else diff * 2i64
                        case None => 0i64
                    },
                pairs);
                println("Part 1: ${List.foldLeft(a -> b -> a * b, 1i64, numberofways)}");
                match (Int64.fromString(List.join("", times)), Int64.fromString(List.join("", distances))) {
                    case (Some(time), Some(distance)) => let countp2 = match Day6.lowertimefordistance(distance, time) {
                        case Some(lowertime) =>
                            let mosttime = time/2i64;
                            let diff = mosttime - lowertime;
                            if (Int64.mod(time, 2i64) == 0i64) (diff) * 2i64 - 1i64 else diff * 2i64
                        case None => 0i64
                    }; println("Part 2: ${countp2}")
                    case _ => Console.println("Error parsing file")
                }
            case _ => Console.println("Error parsing file")
        }
        case _ => Console.println("Error opening file")
    }