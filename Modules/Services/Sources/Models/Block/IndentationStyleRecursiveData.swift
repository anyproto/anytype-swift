final class IndentationStyleRecursiveData {
    var lastChildCalloutBlocks = [String: MiddlewareColor?]()
    var hightlightedChildBlockIdToClosingIndexes = [String: [Int]]()

    func addClosing(for blockId: String, at index: Int) {
        if var existingIndexes = hightlightedChildBlockIdToClosingIndexes[blockId] {

            existingIndexes.append(index)
            hightlightedChildBlockIdToClosingIndexes[blockId] = existingIndexes
        } else {
            hightlightedChildBlockIdToClosingIndexes[blockId] = [index]
        }
    }
}
