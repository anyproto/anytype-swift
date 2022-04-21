import BlocksModels

struct BlockLinkState: Hashable, Equatable {
    let title: String
    let description: String
    let style: Style
    let type: ObjectType?
    let viewType: EditorViewType
    
    let archived: Bool
    let deleted: Bool
    let hasDescription: Bool
    let objectPreviewFields: ObjectPreviewFields
    
    init(details: ObjectDetails, objectPreviewFields: ObjectPreviewFields) {
        let description = details.description.isEmpty ? details.snippet : details.description

        self.init(
            title: details.name,
            description: description,
            style: Style(details: details),
            typeUrl: details.type,
            viewType: details.editorViewType,
            archived: details.isArchived,
            deleted: details.isDeleted,
            objectPreviewFields: objectPreviewFields
        )
    }
    
    init(title: String, description: String, style: Style, typeUrl: String?, viewType: EditorViewType, archived: Bool, deleted: Bool, objectPreviewFields: ObjectPreviewFields) {
        self.title = title
        self.style = style
        self.type = ObjectTypeProvider.objectType(url: typeUrl)
        self.viewType = viewType
        self.archived = archived
        self.deleted = deleted
        self.objectPreviewFields = objectPreviewFields
        self.description = description

        let hasDescriptionInFields = objectPreviewFields.featuredRelationsIds.contains(BundledRelationKey.description.rawValue) && !deleted
        self.hasDescription = description.isNotEmpty && hasDescriptionInFields
    }
    
}

extension BlockLinkState {
    
    static let empty = BlockLinkState(title: .empty, description: .empty, style: .noContent, typeUrl: nil, viewType: .page, archived: false, deleted: false, objectPreviewFields: .init(icon: .none, layout: .text, withName: false, featuredRelationsIds: []))
    
}
