extension Array where Element: Identifiable {
    func index(id: Element.ID) -> Int? {
        firstIndex { $0.id == id }
    }
}
