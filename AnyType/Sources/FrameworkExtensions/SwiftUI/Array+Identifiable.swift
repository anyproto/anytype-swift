extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        first { $0.id == id }
    }
    
    func index(id: Element.ID) -> Int? {
        firstIndex { $0.id == id }
    }
}
