import BlocksModels

extension BaseDocument {
    var dataviews: [BlockDataview] {
        return flattenBlocks.compactMap { block -> BlockDataview? in
            if case .dataView(let data) = block.information.content {
                return data
            }
            return nil
        }
    }
}
