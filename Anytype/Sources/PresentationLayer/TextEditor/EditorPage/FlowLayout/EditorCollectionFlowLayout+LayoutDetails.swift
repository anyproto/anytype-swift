import Services


extension EditorCollectionFlowLayout {
    
    nonisolated static func blockLayoutDetails(blockInfos: [BlockInformation]) -> [String: BlockLayoutDetails] {
        var output = [String: BlockLayoutDetails]()
        
        let dictionary = Dictionary(
            uniqueKeysWithValues: blockInfos.map { ($0.id, $0) }
        )
        
        for rootBlockInfo in blockInfos {
            output[rootBlockInfo.id] = BlockLayoutDetails(
                id: rootBlockInfo.id,
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
    nonisolated private static func traverseBlock(_ block: BlockInformation, blockInfos: [BlockInformation]) -> [String] {
        block.childrenIds.map { childId -> [String] in
            
            var childIndentifiers = [String]()
            if let childInformation = blockInfos.first(where: { info in info.id == childId }) {
                childIndentifiers.append(childInformation.id)
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
