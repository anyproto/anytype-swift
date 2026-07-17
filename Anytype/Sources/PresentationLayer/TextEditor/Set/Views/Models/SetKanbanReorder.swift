enum SetKanbanReorder {
    static func isColumnFullyLoaded(loadedCount: Int, totalCount: Int?) -> Bool {
        guard let totalCount else { return false }
        return loadedCount >= totalCount
    }
}
