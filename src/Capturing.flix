mod Capturing {
    pub def namedGroupCapture(regex: Regex, input: String, names: List[String]): List[Option[String]] = region rc {
        import java.util.regex.Matcher.group(String): String \ rc;
        import java.util.regex.Matcher.matches(): Bool \ rc;
        let matcher = newMatcher(rc, regex, input);
        if (matches(matcher))
            List.map(name -> try {
                Some(group(matcher, name))
            } catch {
                case _: ##java.lang.IllegalArgumentException => None
            }, names)
        else List.map(_ -> None, names)
    }

    pub def groupCapture(regex: Regex, input: String): Option[String] = region rc {
        import java.util.regex.Matcher.group(Int32): String \ rc;
        import java.util.regex.Matcher.find(): Bool \ rc;
        let matcher = newMatcher(rc, regex, input);
        if (find(matcher))
            try {
                Some(group(matcher, 1))
            } catch {
                case _: ##java.lang.IllegalArgumentException => None
            }
        else None
    }

    def newMatcher(_: Region[r], regex: Regex, input: String): ##java.util.regex.Matcher \ r =
        import java.util.regex.Pattern.matcher(##java.lang.CharSequence): ##java.util.regex.Matcher \ r;
        matcher(regex, checked_cast(input))
}