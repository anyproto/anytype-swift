import Services

extension DataviewGroupOrder {
    func updated(
        viewGroups: [DataviewViewGroup]? = nil
    ) -> DataviewGroupOrder {
        DataviewGroupOrder(
            viewID: self.viewID,
            viewGroups: viewGroups ?? self.viewGroups
        )
    }
    
    static func create(viewID: String) -> DataviewGroupOrder {
        DataviewGroupOrder(
            viewID: viewID,
            viewGroups: []
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
    
    static func create(groupId: String, index: Int, hidden: Bool, backgroundColor: String?) -> DataviewViewGroup {
        DataviewViewGroup(
            groupID: groupId,
            index: Int32(index),
            hidden: hidden,
            backgroundColor: backgroundColor ?? ""
        )
    }
}
