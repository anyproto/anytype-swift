import Services


extension EditorCollectionFlowLayout {
    
    nonisolated static func blockLayoutDetails(blockInfos: [BlockInformation]) -> [String: BlockLayoutDetails] {
        var output = [String: BlockLayoutDetails]()
        
        let dictionary: [String: BlockInformation] = Dictionary(
            uniqueKeysWithValues: blockInfos.map { ($0.id, $0) }
        )
        
        for rootBlockInfo in blockInfos {
            output[rootBlockInfo.id] = BlockLayoutDetails(
                id: rootBlockInfo.id,
                allChildIds: traverseBlock(rootBlockInfo, dictionary: dictionary),
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
    nonisolated private static func traverseBlock(_ block: BlockInformation, dictionary: [String: BlockInformation]) -> [String] {
        block.childrenIds.map { childId -> [String] in

            var childIndentifiers = [String]()
            if let childInformation = dictionary[childId] {
                childIndentifiers.append(childInformation.id)
                childIndentifiers.append(
                    contentsOf: traverseBlock(childInformation, dictionary: dictionary)
                )
            }

            return childIndentifiers
        }.flatMap { $0 }
    }
    
    nonisolated private static func findIdentation(
        currentIdentations: [BlockIndentationStyle],
        blockInfo: BlockInformation,
        dictionary: [String: BlockInformation]
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
