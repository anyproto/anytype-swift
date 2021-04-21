
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
            if let mappedType = type.blockViewsType {
                guard self.restrictions.turnIntoStyles.contains(mappedType) else { return }
                result.append(.action(.style(type)))
            } else {
                if type == .bold, restrictions.canApplyBold {
                    result.append(.action(.style(type)))
                }
                if (type == .italic || type == .breakthrough) && restrictions.canApplyOtherMarkup {
                    result.append(.action(.style(type)))
                }
            }
        }
        if children.isEmpty {
            return nil
        }
        return .menu(.style, children)
    }
    
    private func makeMediaMenuItem() -> BlockActionMenuItem? {
        let children = BlockMediaAction.allCases.reduce(into: [BlockActionMenuItem]()) { result, media in
            let type = media.blockViewsType
            guard self.restrictions.turnIntoStyles.contains(type) else { return }
            result.append(.action(.media(media)))
        }
        if children.isEmpty {
            return nil
        }
        return .menu(.media, children)
    }
    
    private func makeObjectsMenuItem() -> BlockActionMenuItem? {
        nil
    }
    
    private func makeRelationMenuItem() -> BlockActionMenuItem? {
        nil
    }
    
    private func makeOtherMenuItem() -> BlockActionMenuItem? {
        let children = BlockOtherAction.allCases.reduce(into: [BlockActionMenuItem]()) { result, other in
            let type = other.blockViewsType
            guard self.restrictions.turnIntoStyles.contains(type) else { return }
            result.append(.action(.other(other)))
        }
        if children.isEmpty {
            return nil
        }
        return .menu(.other, children)
    }
    
    private func makeActionsMenuItem() -> BlockActionMenuItem? {
        let children: [BlockActionMenuItem] = BlockAction.allCases.map { .action(.actions($0)) }
        return .menu(.actions, children)
    }
    
    private func makeAlignmentMenuItem() -> BlockActionMenuItem? {
        let children = BlockAlignmentAction.allCases.reduce(into: [BlockActionMenuItem]()) { result, alignment in
            guard self.restrictions.availableAlignments.contains(alignment.blockAlignment) else { return }
            result.append(.action(.alignment(alignment)))
        }
        if children.isEmpty {
            return nil
        }
        return .menu(.alignment, children)
    }
    
    private func makeBlockColorMenuItem() -> BlockActionMenuItem? {
        if !restrictions.canApplyBlockColor {
            return nil
        }
        return .menu(.color, BlockColorAction.allCases.map { .action(.color($0)) })
    }
    
    private func makeBackgroundColorMenuItem() -> BlockActionMenuItem? {
        if !restrictions.canApplyBackgroundColor {
            return nil
        }
        return .menu(.background, BlockBackgroundColorAction.allCases.map { .action(.background($0)) })
    }
}
