
struct BlockActionsBuilder {
    
    private let restrictions: BlockRestrictions
    
    init(restrictions: BlockRestrictions) {
        self.restrictions = restrictions
    }
    
    func makeBlockActionsMenuItems() -> [BlockActionMenuItem] {
        return [self.makeStyleMenuItem(),
                self.makeMediaMenuItem(),
                self.makeOtherMenuItem(),
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
        return .menuWithChildren(.style, [.sectionDivider("Style".localized)] + children)
    }
    
    private func makeMediaMenuItem() -> BlockActionMenuItem? {
        return .menuWithChildren(.media, [])
    }
    
    private func makeObjectsMenuItem() -> BlockActionMenuItem? {
        nil
    }
    
    private func makeRelationMenuItem() -> BlockActionMenuItem? {
        nil
    }
    
    private func makeOtherMenuItem() -> BlockActionMenuItem? {
        return .menuWithChildren(.other, [])
    }
    
    private func makeActionsMenuItem() -> BlockActionMenuItem? {
        return .menuWithChildren(.actions, [])
    }
    
    private func makeAlignmentMenuItem() -> BlockActionMenuItem? {
        return .menuWithChildren(.alignment, [])
    }
    
    private func makeBlockColorMenuItem() -> BlockActionMenuItem? {
        return .menuWithChildren(.color, [])
    }
    
    private func makeBackgroundColorMenuItem() -> BlockActionMenuItem? {
        return .menuWithChildren(.background, [])
    }
}
