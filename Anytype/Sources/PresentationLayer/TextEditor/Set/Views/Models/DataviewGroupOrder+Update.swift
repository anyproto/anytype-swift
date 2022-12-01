import BlocksModels

extension DataviewGroupOrder {
    func updated(
        viewGroups: [DataviewViewGroup]? = nil
    ) -> DataviewGroupOrder {
        DataviewGroupOrder(
            viewID: self.viewID,
            viewGroups: viewGroups ?? self.viewGroups
        )
    }
}

extension DataviewViewGroup {
    func updated(
        hidden: Bool? = nil,
        backgroundColor: String? = nil
    ) -> DataviewViewGroup {
        DataviewViewGroup(
            groupID: self.groupID,
            index: self.index,
            hidden: hidden ?? self.hidden,
            backgroundColor: backgroundColor ?? self.backgroundColor
        )
    }
}
