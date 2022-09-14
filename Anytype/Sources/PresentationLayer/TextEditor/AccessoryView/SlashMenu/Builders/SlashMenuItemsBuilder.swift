import BlocksModels
import AnytypeCore

struct SlashMenuItemsBuilder {
    
    private let restrictions: BlockRestrictions
    private let searchService: SearchServiceProtocol
    private let relations: [Relation]
    
    init(
        blockType: BlockContentType,
        searchService: SearchServiceProtocol = ServiceLocator.shared.searchService(),
        relations: [Relation]
    ) {
        self.restrictions = BlockRestrictionsBuilder.build(contentType: blockType)
        self.searchService = searchService
        self.relations = relations
    }
    
    var slashMenuItems: [SlashMenuItem] {
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
    
    private var styleMenuItem: SlashMenuItem? {
        let children = SlashActionStyle.allCases.reduce(into: [SlashAction]()) { result, type in
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
        return SlashMenuItem(type: .style, children: children)
    }
    
    private var mediaMenuItem: SlashMenuItem? {
        let children: [SlashAction] = SlashActionMedia.allCases.map { .media($0) }
        return SlashMenuItem(type: .media, children: children)
    }
    
    private var objectsMenuItem: SlashMenuItem? {
        let searchTypes = searchService.searchObjectTypes(text: "", filteringTypeId: nil, shouldIncludeSets: false) ?? []

        let linkTo = SlashActionObject.linkTo
        let objectTypes = searchTypes.map(SlashActionObject.objectType)

        return SlashMenuItem(
            type: .objects,
            children: ([linkTo] + objectTypes).map(SlashAction.objects)
        )
    }
    
    private var relationMenuItem: SlashMenuItem? {
        let relations = relations.map {
            SlashAction.relations(.relation($0))
        }
        let childrens = [SlashAction.relations(.newRealtion)] + relations
        return SlashMenuItem(type: .relations, children: childrens)
    }
    
    private var otherMenuItem: SlashMenuItem {
        let defaultTableAction: SlashActionOther = .table(rowsCount: 3, columnsCount: 3)
        let allOtherSlashActions: [SlashActionOther] = [.lineDivider, .dotsDivider, .tableOfContents, defaultTableAction]

        let children: [SlashAction] = allOtherSlashActions.map { .other($0) }

        return SlashMenuItem(type: .other, children: children)
    }
    
    private var actionsMenuItem: SlashMenuItem {
        let children: [SlashAction] = BlockAction.allCases.map { .actions($0) }
        return SlashMenuItem(type: .actions, children: children)
    }
    
    private var alignmentMenuItem: SlashMenuItem? {
        let children = SlashActionAlignment.allCases.reduce(into: [SlashAction]()) { result, alignment in
            guard self.restrictions.availableAlignments.contains(alignment.blockAlignment) else { return }
            result.append(.alignment(alignment))
        }
        if children.isEmpty {
            return nil
        }
        return SlashMenuItem(type: .alignment, children: children)
    }
    
    private var blockColorMenuItem: SlashMenuItem? {
        if !restrictions.canApplyBlockColor {
            return nil
        }
        return SlashMenuItem(type: .color, children: BlockColor.allCases.map { .color($0) })
    }
    
    private var backgroundColorMenuItem: SlashMenuItem? {
        if !restrictions.canApplyBackgroundColor {
            return nil
        }
        return SlashMenuItem(type: .background, children: BlockBackgroundColor.allCases.map { .background($0) })
    }
}
