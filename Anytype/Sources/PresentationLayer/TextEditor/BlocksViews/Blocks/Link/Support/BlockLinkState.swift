import BlocksModels

struct BlockLinkState: Hashable, Equatable {
    let title: String
    let description: String
    let cardStyle: BlockLink.CardStyle
    let style: Style
    let type: ObjectType?
    let viewType: EditorViewType
    let documentCover: DocumentCover?

    let relations: [BlockLink.Relation]
    let iconSize: BlockLink.IconSize
    let descriptionState: BlockLink.Description
    let objectLayout: DetailsLayout

    let archived: Bool
    let deleted: Bool
    
    init(details: ObjectDetails, blockLink: BlockLink) {
        var description = ""

        switch blockLink.appearance.description {
        case .content:
            description = details.snippet
        case .added:
            description = details.description
        case .none:
            description = ""
        }

        let documentCover = (details.layoutValue != .note && blockLink.appearance.relations.contains(.cover)) ?
        details.documentCover : nil

        var iconSize = blockLink.appearance.iconSize
        if details.layoutValue == .todo, iconSize == .medium {
            iconSize = .small
        }

        self.init(
            title: details.name,
            cardStyle: blockLink.appearance.cardStyle,
            description: description,
            style: Style(details: details),
            typeId: details.type,
            viewType: details.editorViewType,
            archived: details.isArchived,
            deleted: details.isDeleted,
            relations: blockLink.appearance.relations,
            iconSize: iconSize,
            descriptionState: blockLink.appearance.description,
            documentCover: documentCover,
            objectLayout: details.layoutValue
        )
    }
    
    init(title: String,
         cardStyle: BlockLink.CardStyle,
         description: String,
         style: Style,
         typeId: String,
         viewType: EditorViewType,
         archived: Bool,
         deleted: Bool,
         relations: [BlockLink.Relation],
         iconSize: BlockLink.IconSize,
         descriptionState: BlockLink.Description,
         documentCover: DocumentCover?,
         objectLayout: DetailsLayout
    ) {
        self.title = title
        self.cardStyle = cardStyle
        self.style = style
        self.type = ObjectTypeProvider.shared.objectType(id: typeId)
        self.viewType = viewType
        self.archived = archived
        self.deleted = deleted
        self.description = description
        self.relations = relations
        self.iconSize = iconSize
        self.descriptionState = descriptionState
        self.documentCover = documentCover
        self.objectLayout = objectLayout
    }
}
