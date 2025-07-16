import Services

// Designed by Dmitry Bilienko - bududomasidet@gmail.com
extension EditorCollectionFlowLayout {
    
    nonisolated static func layoutDetails(for blockModels: [BlockInformation]) -> [AnyHashable: RowInformation] {
        var output = [AnyHashable: RowInformation]()
        
        let dictionary = Dictionary(uniqueKeysWithValues: blockModels.map { ($0.hashable, $0) })
        
        for rootBlockInfo in blockModels.enumerated() {
            output[rootBlockInfo.element.hashable] = RowInformation(
                hashable: rootBlockInfo.element.hashable,
                allChilds: traverseBlock(rootBlockInfo.element, blockModels: blockModels),
                indentations: findIdentation(
                    currentIdentations: [],
                    block: rootBlockInfo.element,
                    dictionary: dictionary
                ),
                ownStyle: rootBlockInfo.element.content.indentationStyle
            )
        }
        
        return output
    }
    
    // MARK: - Private
    nonisolated private static func traverseBlock(_ block: BlockInformation, blockModels: [BlockInformation]) -> [AnyHashable] {
        block.childrenIds.map { childId -> [AnyHashable] in
            
            var childIndentifiers = [AnyHashable]()
            if let childInformation = blockModels.first(where: { info in info.id == childId }) {
                childIndentifiers.append(childInformation.hashable)
                childIndentifiers.append(
                    contentsOf: traverseBlock(childInformation, blockModels: blockModels)
                )
            }
            
            return childIndentifiers
        }.flatMap { $0 }
    }
    
    nonisolated private static func findIdentation(
        currentIdentations: [BlockIndentationStyle],
        block: BlockInformation,
        dictionary: [AnyHashable : BlockInformation]
    ) -> [BlockIndentationStyle] {
        guard let parentId = block.configurationData.parentId,
              let parent = dictionary[parentId]  else {
            return currentIdentations
        }
        var indentations = currentIdentations
        indentations.append(parent.content.indentationStyle)
        
        return findIdentation(
            currentIdentations: indentations,
            block: parent,
            dictionary: dictionary
        )
    }
}
