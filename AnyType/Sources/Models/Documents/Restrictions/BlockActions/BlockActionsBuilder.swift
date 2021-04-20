
struct BlockActionsBuilder {
    
    private let restrictions: BlockRestrictions
    
    init(restrictions: BlockRestrictions) {
        self.restrictions = restrictions
    }
    
    func makeBlockActionsMenuItems() -> [BlockActionMenuItem] {
        return [self.makeStyleMenuItem(),
                self.makeMediaMenuItem(),
                self.makeObjectsMenuItem(),
                self.makeRelationMenuItem(),
                self.makeOtherMenuItem(),
                self.makeActionsMenuItem(),
                self.makeAlignmentMenuItem(),
                self.makeBlockColorMenuItem(),
                self.makeBackgroundColorMenuItem()].compactMap { $0 }
    }
    
    private func makeStyleMenuItem() -> BlockActionMenuItem? {
        let children = BlockStyleAction.allCases.reduce(into: [BlockActionMenuItem]()) { result, type in
            guard let mappedType = type.blockViewsType,
                  self.restrictions.turnIntoStyles.contains(mappedType) else { return }
            result.append(.action(.style(type)))
        }
        if children.isEmpty {
            return nil
        }
        return .menu(.style, children)
    }
    
    private func makeMediaMenuItem() -> BlockActionMenuItem? {
        return .menu(.media, [])
    }
    
    private func makeObjectsMenuItem() -> BlockActionMenuItem? {
        nil
    }
    
    private func makeRelationMenuItem() -> BlockActionMenuItem? {
        nil
    }
    
    private func makeOtherMenuItem() -> BlockActionMenuItem? {
        return .menu(.other, [])
    }
    
    private func makeActionsMenuItem() -> BlockActionMenuItem? {
        let children: [BlockActionMenuItem] = BlockAction.allCases.map { .action(.actions($0)) }
        return .menu(.actions, children)
    }
    
    private func makeAlignmentMenuItem() -> BlockActionMenuItem? {
        return .menu(.alignment, [])
    }
    
    private func makeBlockColorMenuItem() -> BlockActionMenuItem? {
        return .menu(.color, [])
    }
    
    private func makeBackgroundColorMenuItem() -> BlockActionMenuItem? {
        return .menu(.background, [])
    }
}
