import Services

struct SlashMenuItemsBuilder {
    private let typesService: TypesServiceProtocol
    
    init(typesService: TypesServiceProtocol) {
        self.typesService = typesService
    }
    
    func slashMenuItems(spaceId: String, resrictions: BlockRestrictions, relations: [Relation]) async throws -> [SlashMenuItem] {
        let searchObjectsMenuItem = try? await searchObjectsMenuItem(spaceId: spaceId)
        
        return [
            styleMenuItem(restrictions: resrictions),
            mediaMenuItem,
            searchObjectsMenuItem,
            relationMenuItem(relations: relations),
            otherMenuItem,
            actionsMenuItem,
            alignmentMenuItem(restrictions: resrictions),
            blockColorMenuItem(restrictions: resrictions),
            backgroundColorMenuItem(restrictions: resrictions)
        ].compactMap { $0 }
    }
    
    private func styleMenuItem(restrictions: BlockRestrictions) -> SlashMenuItem? {
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
    
    private func searchObjectsMenuItem(spaceId: String) async throws -> SlashMenuItem? {
        guard let searchTypes = try? await typesService.searchObjectTypes(
            text: "", 
            includePins: true,
            includeLists: true,
            includeBookmark: false,
            includeFiles: false,
            incudeNotForCreation: false,
            spaceId: spaceId
        ) else {
            return nil
        }

        let linkTo = SlashActionObject.linkTo
        let objectTypes = searchTypes.map(SlashActionObject.objectType)

        return SlashMenuItem(
            type: .objects,
            children: ([linkTo] + objectTypes).map(SlashAction.objects)
        )
    }
    
    private func relationMenuItem(relations: [Relation]) -> SlashMenuItem? {
        let relations = relations.map {
            SlashAction.relations(.relation($0))
        }
        let childrens = [SlashAction.relations(.newRealtion)] + relations
        return SlashMenuItem(type: .relations, children: childrens)
    }
    
    private func alignmentMenuItem(restrictions: BlockRestrictions) -> SlashMenuItem? {
        let children = SlashActionAlignment.allCases.reduce(into: [SlashAction]()) { result, alignment in
            guard restrictions.availableAlignments.contains(alignment.blockAlignment) else { return }
            result.append(.alignment(alignment))
        }
        if children.isEmpty {
            return nil
        }
        return SlashMenuItem(type: .alignment, children: children)
    }
    
    private func blockColorMenuItem(restrictions: BlockRestrictions) -> SlashMenuItem? {
        if !restrictions.canApplyBlockColor {
            return nil
        }
        return SlashMenuItem(type: .color, children: BlockColor.allCases.map { .color($0) })
    }
    
    private func backgroundColorMenuItem(restrictions: BlockRestrictions) -> SlashMenuItem? {
        if !restrictions.canApplyBackgroundColor {
            return nil
        }
        return SlashMenuItem(type: .background, children: BlockBackgroundColor.allCases.map { .background($0) })
    }
}
