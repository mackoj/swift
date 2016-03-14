// RUN: %target-swift-frontend %s -emit-ir

// Issue found by https://github.com/tenderlove (Aaron Patterson)
// https://gist.github.com/tenderlove/66ff6ae1feed92ac37f2

func a(x: Any, _ y: Any) -> (((Any, Any) -> Any) -> Any) {
    return {
        (m: (Any, Any) -> Any) -> Any in
        return m(x, y)
    }
}
func b(z: (((Any, Any) -> Any) -> Any)) -> Any {
    return z({
        (p: Any, q:Any) -> Any in
        return p
    })
}
b(a(1, a(2, 3)))
