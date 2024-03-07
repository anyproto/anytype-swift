struct RelationModuleConfiguration {
    let title: String
    let isEditable: Bool
    let relationKey: String
    let objectId: String
    let spaceId: String
    let selectionMode: RelationSelectionOptionsMode
    let analyticsType: AnalyticsEventsRelationType
    
    init(
        title: String, 
        isEditable: Bool, 
        relationKey: String,
        objectId: String,
        spaceId: String,
        selectionMode: RelationSelectionOptionsMode = .single,
        analyticsType: AnalyticsEventsRelationType
    ) {
        self.title = title
        self.isEditable = isEditable
        self.relationKey = relationKey
        self.objectId = objectId
        self.spaceId = spaceId
        self.selectionMode = selectionMode
        self.analyticsType = analyticsType
    }
    
    static let `default` = RelationModuleConfiguration(
        title: "Relation",
        isEditable: true,
        relationKey: "relationKey",
        objectId: "objectId",
        spaceId: "spaceId",
        selectionMode: .single,
        analyticsType: .block
    )
}
