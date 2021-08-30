
struct BlockActionsBuilder {
    
    private let restrictions: BlockRestrictions
    
    init(restrictions: BlockRestrictions) {
        self.restrictions = restrictions
    }
    
    func makeBlockActionsMenuItems() -> [BlockActionMenuItem] {
        return [
            styleMenuItem,
            mediaMenuItem,
            objectsMenuItem,
            relationMenuItem,
            otherMenuItem,
            actionsMenuItem,
            alignmentMenuItem,
            blockColorMenuItem,
            backgroundColorMenuItem
        ].compactMap { $0 }
    }
    
    private var styleMenuItem: BlockActionMenuItem? {
        let children = BlockStyleAction.allCases.reduce(into: [BlockActionMenuItem]()) { result, type in
            if let mappedType = type.blockViewsType {
                guard restrictions.turnIntoStyles.contains(mappedType) else { return }
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
        return .menu(item: .style, children: children)
    }
    
    private var mediaMenuItem: BlockActionMenuItem? {
        let children: [BlockActionMenuItem] = BlockMediaAction.allCases.map { .action(.media($0)) }
        return .menu(item: .media, children: children)
    }
    
    private var objectsMenuItem: BlockActionMenuItem? {
        guard let draft = ObjectTypeProvider.objectType(url: ObjectTypeProvider.pageObjectURL) else {
            return nil
        }
        
        let objects = [ draft ]
        return .menu(item: .objects, children: objects.map { .action(.objects($0)) })
    }
    
    private var relationMenuItem: BlockActionMenuItem? {
        nil
    }
    
    private var otherMenuItem: BlockActionMenuItem {
        let children: [BlockActionMenuItem] = BlockOtherAction.allCases.map { .action(.other($0)) }
        return .menu(item: .other, children: children)
    }
    
    private var actionsMenuItem: BlockActionMenuItem {
        let children: [BlockActionMenuItem] = [BlockAction.delete, BlockAction.duplicate].map { .action(.actions($0)) }
        return .menu(item: .actions, children: children)
    }
    
    private var alignmentMenuItem: BlockActionMenuItem? {
        let children = BlockAlignmentAction.allCases.reduce(into: [BlockActionMenuItem]()) { result, alignment in
            guard self.restrictions.availableAlignments.contains(alignment.blockAlignment) else { return }
            result.append(.action(.alignment(alignment)))
        }
        if children.isEmpty {
            return nil
        }
        return .menu(item: .alignment, children: children)
    }
    
    private var blockColorMenuItem: BlockActionMenuItem? {
        if !restrictions.canApplyBlockColor {
            return nil
        }
        return .menu(item: .color, children: BlockColor.allCases.map { .action(.color($0)) })
    }
    
    private var backgroundColorMenuItem: BlockActionMenuItem? {
        if !restrictions.canApplyBackgroundColor {
            return nil
        }
        return .menu(item: .background, children: BlockBackgroundColor.allCases.map { .action(.background($0)) })
    }
}
