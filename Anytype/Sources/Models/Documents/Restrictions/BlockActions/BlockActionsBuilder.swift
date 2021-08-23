
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
                if type == .italic, restrictions.canApplyItalic {
                    result.append(.action(.style(type)))
                }
                if (type == .code || type == .strikethrough), restrictions.canApplyOtherMarkup {
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
        let children: [BlockActionMenuItem] = BlockMediaAction.allCases.map { .action(.media($0)) }
        return .menu(.media, children)
    }
    
    private func makeObjectsMenuItem() -> BlockActionMenuItem? {
        guard let draft = ObjectTypeProvider.objectType(url: ObjectTypeProvider.pageObjectURL) else {
            return nil
        }
        
        let objects = [ draft ]
        return .menu(.objects, objects.map { .action(.objects($0)) })
    }
    
    private func makeRelationMenuItem() -> BlockActionMenuItem? {
        nil
    }
    
    private func makeOtherMenuItem() -> BlockActionMenuItem? {
        let children: [BlockActionMenuItem] = BlockOtherAction.allCases.map { .action(.other($0)) }
        return .menu(.other, children)
    }
    
    private func makeActionsMenuItem() -> BlockActionMenuItem? {
        let children: [BlockActionMenuItem] = [BlockAction.delete, BlockAction.duplicate].map { .action(.actions($0)) }
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
        return .menu(.color, BlockColor.allCases.map { .action(.color($0)) })
    }
    
    private func makeBackgroundColorMenuItem() -> BlockActionMenuItem? {
        if !restrictions.canApplyBackgroundColor {
            return nil
        }
        return .menu(.background, BlockBackgroundColor.allCases.map { .action(.background($0)) })
    }
}
