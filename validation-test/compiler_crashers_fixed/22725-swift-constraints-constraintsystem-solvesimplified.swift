// RUN: not %target-swift-frontend %s -parse

// Issue found by https://github.com/robrix (Rob Rix)
// http://www.openradar.me/19343997

func b<T>(String -> (T, String)?
func |<T>(c: String -> (T, String)?
a:String > (())) -> String -> (T?, String)?
b("" | "" | "" | "")
