import Services

// Designed by Dmitry Bilienko - bududomasidet@gmail.com
extension EditorCollectionFlowLayout {
    
    nonisolated static func layoutDetails(blockInfos: [BlockInformation]) -> [AnyHashable: RowInformation] {
        var output = [AnyHashable: RowInformation]()
        
        let dictionary = Dictionary(uniqueKeysWithValues: blockInfos.map { ($0.hashable, $0) })
        
        for rootBlockInfo in blockInfos {
            output[rootBlockInfo.hashable] = RowInformation(
                hashable: rootBlockInfo.hashable,
                allChilds: traverseBlock(rootBlockInfo, blockInfos: blockInfos),
                indentations: findIdentation(
                    currentIdentations: [],
                    blockInfo: rootBlockInfo,
                    dictionary: dictionary
                ),
                ownStyle: rootBlockInfo.content.indentationStyle
            )
        }
        
        return output
    }
    
    // MARK: - Private
    nonisolated private static func traverseBlock(_ block: BlockInformation, blockInfos: [BlockInformation]) -> [AnyHashable] {
        block.childrenIds.map { childId -> [AnyHashable] in
            
            var childIndentifiers = [AnyHashable]()
            if let childInformation = blockInfos.first(where: { info in info.id == childId }) {
                childIndentifiers.append(childInformation.hashable)
                childIndentifiers.append(
                    contentsOf: traverseBlock(childInformation, blockInfos: blockInfos)
                )
            }
            
            return childIndentifiers
        }.flatMap { $0 }
    }
    
    nonisolated private static func findIdentation(
        currentIdentations: [BlockIndentationStyle],
        blockInfo: BlockInformation,
        dictionary: [AnyHashable : BlockInformation]
    ) -> [BlockIndentationStyle] {
        guard let parentId = blockInfo.configurationData.parentId,
              let parent = dictionary[parentId]  else {
            return currentIdentations
        }
        var indentations = currentIdentations
        indentations.append(parent.content.indentationStyle)
        
        return findIdentation(
            currentIdentations: indentations,
            blockInfo: parent,
            dictionary: dictionary
        )
    }
}
