extension Comparable {
    func clamped(_ a: Self, _ b: Self) -> Self {
        min(max(self, a), b)
    }
}
