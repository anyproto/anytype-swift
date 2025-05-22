struct PropertyModuleConfiguration {
    let title: String
    let isEditable: Bool
    let relationKey: String
    let objectId: String
    let spaceId: String
    let selectionMode: PropertySelectionOptionsMode
    let analyticsType: AnalyticsEventsRelationType
    
    init(
        title: String, 
        isEditable: Bool, 
        relationKey: String,
        objectId: String,
        spaceId: String,
        selectionMode: PropertySelectionOptionsMode = .single,
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
    
    static let `default` = PropertyModuleConfiguration(
        title: "Relation",
        isEditable: true,
        relationKey: "relationKey",
        objectId: "objectId",
        spaceId: "spaceId",
        selectionMode: .single,
        analyticsType: .block
    )
}
