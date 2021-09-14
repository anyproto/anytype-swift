
struct BlockActionsBuilder {
    
    private let restrictions: BlockRestrictions
    
    init(restrictions: BlockRestrictions) {
        self.restrictions = restrictions
    }
    
    func slashMenuItems() -> [BlockActionMenuItem] {
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
        let children = BlockStyleAction.allCases.reduce(into: [BlockActionType]()) { result, type in
            if let mappedType = type.blockViewsType {
                guard restrictions.turnIntoStyles.contains(mappedType) else { return }
                result.append(.style(type))
            } else {
                if type == .bold, restrictions.canApplyBold {
                    result.append(.style(type))
                }
                if type == .italic, restrictions.canApplyItalic {
                    result.append(.style(type))
                }
                if (type == .code || type == .strikethrough), restrictions.canApplyOtherMarkup {
                    result.append(.style(type))
                }
            }
        }
        if children.isEmpty {
            return nil
        }
        return BlockActionMenuItem(item: .style, children: children)
    }
    
    private var mediaMenuItem: BlockActionMenuItem? {
        let children: [BlockActionType] = BlockMediaAction.allCases.map { .media($0) }
        return BlockActionMenuItem(item: .media, children: children)
    }
    
    private var objectsMenuItem: BlockActionMenuItem? {
        guard let draft = ObjectTypeProvider.objectType(url: ObjectTypeProvider.pageObjectURL) else {
            return nil
        }
        
        let objects = [ draft ]
        return BlockActionMenuItem(item: .objects, children: objects.map { .objects($0) })
    }
    
    private var relationMenuItem: BlockActionMenuItem? {
        nil
    }
    
    private var otherMenuItem: BlockActionMenuItem {
        let children: [BlockActionType] = BlockOtherAction.allCases.map { .other($0) }
        return BlockActionMenuItem(item: .other, children: children)
    }
    
    private var actionsMenuItem: BlockActionMenuItem {
        let children: [BlockActionType] = [BlockAction.delete, BlockAction.duplicate].map { .actions($0) }
        return BlockActionMenuItem(item: .actions, children: children)
    }
    
    private var alignmentMenuItem: BlockActionMenuItem? {
        let children = BlockAlignmentAction.allCases.reduce(into: [BlockActionType]()) { result, alignment in
            guard self.restrictions.availableAlignments.contains(alignment.blockAlignment) else { return }
            result.append(.alignment(alignment))
        }
        if children.isEmpty {
            return nil
        }
        return BlockActionMenuItem(item: .alignment, children: children)
    }
    
    private var blockColorMenuItem: BlockActionMenuItem? {
        if !restrictions.canApplyBlockColor {
            return nil
        }
        return BlockActionMenuItem(item: .color, children: BlockColor.allCases.map { .color($0) })
    }
    
    private var backgroundColorMenuItem: BlockActionMenuItem? {
        if !restrictions.canApplyBackgroundColor {
            return nil
        }
        return BlockActionMenuItem(item: .background, children: BlockBackgroundColor.allCases.map { .background($0) })
    }
}
