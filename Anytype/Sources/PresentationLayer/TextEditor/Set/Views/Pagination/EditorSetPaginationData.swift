struct EditorSetPaginationData {
    let selectedPage: Int
    let visiblePages: [Int]
    let pageCount: Int64
    
    var canGoBackward: Bool {
        guard let first = visiblePages.first else { return false }
        return first > 1
    }
    
    var canGoForward: Bool {
        guard let last = visiblePages.last else { return false }
        return last < pageCount
    }
    
    func updated(visiblePages: [Int]) -> EditorSetPaginationData {
        EditorSetPaginationData(
            selectedPage: selectedPage,
            visiblePages: visiblePages,
            pageCount: pageCount
        )
    }
    
    func updated(pageCount: Int64) -> EditorSetPaginationData {
        EditorSetPaginationData(
            selectedPage: selectedPage,
            visiblePages: visiblePages,
            pageCount: pageCount
        )
    }
    
    func updated(selectedPage: Int) -> EditorSetPaginationData {
        EditorSetPaginationData(
            selectedPage: selectedPage,
            visiblePages: visiblePages,
            pageCount: pageCount
        )
    }
    
    static var empty: EditorSetPaginationData {
        EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3, 4, 5], pageCount: 5)
    }
}
