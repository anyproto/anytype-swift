import Services

struct BlockLinkState: Hashable, Equatable {
    let title: String
    let description: String
    let cardStyle: BlockLink.CardStyle
    let icon: Icon?
    let type: ObjectType?
    let documentCover: DocumentCover?

    let relations: [BlockLink.Relation]
    let iconSize: BlockLink.IconSize
    let descriptionState: BlockLink.Description
    let objectLayout: DetailsLayout
    let screenData: ScreenData

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
        if details.layoutValue == .todo {
            iconSize = .small
        }

        self.init(
            title: details.title.trimmed(numberOfCharacters: Constants.maxTitleLength),
            cardStyle: blockLink.appearance.cardStyle,
            description: description,
            icon: details.objectIconImage,
            type: details.objectType,
            archived: details.isArchived,
            deleted: details.isDeleted,
            relations: blockLink.appearance.relations,
            iconSize: iconSize,
            descriptionState: blockLink.appearance.description,
            documentCover: documentCover,
            objectLayout: details.layoutValue,
            screenData: details.screenData()
        )
    }
    
    init(title: String,
         cardStyle: BlockLink.CardStyle,
         description: String,
         icon: Icon?,
         type: ObjectType?,
         archived: Bool,
         deleted: Bool,
         relations: [BlockLink.Relation],
         iconSize: BlockLink.IconSize,
         descriptionState: BlockLink.Description,
         documentCover: DocumentCover?,
         objectLayout: DetailsLayout,
         screenData: ScreenData
    ) {
        self.title = title
        self.cardStyle = cardStyle
        self.icon = icon
        self.type = type
        self.archived = archived
        self.deleted = deleted
        self.description = description.replacedNewlinesWithSpaces
        self.relations = relations
        self.iconSize = iconSize
        self.descriptionState = descriptionState
        self.documentCover = documentCover
        self.objectLayout = objectLayout
        self.screenData = screenData
    }
}

private extension BlockLinkState {
    enum Constants {
        static let maxTitleLength = 30
    }
}
