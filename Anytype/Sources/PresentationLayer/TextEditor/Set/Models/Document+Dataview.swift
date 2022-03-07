import BlocksModels

extension BaseDocument {
    var dataviews: [BlockDataview] {
        return children.compactMap { info -> BlockDataview? in
            if case .dataView(let data) = info.content {
                return data
            }
            return nil
        }
    }
}
