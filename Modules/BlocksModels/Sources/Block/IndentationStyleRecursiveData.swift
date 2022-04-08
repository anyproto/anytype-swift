final class IndentationStyleRecursiveData {
    var childBlockIdToClosingIndexes = [BlockId: [Int]]()

    func addClosing(for blockId: BlockId, at index: Int) {
        if var existingIndexes = childBlockIdToClosingIndexes[blockId] {

            existingIndexes.append(index)
            childBlockIdToClosingIndexes[blockId] = existingIndexes
        } else {
            childBlockIdToClosingIndexes[blockId] = [index]
        }
    }
}
