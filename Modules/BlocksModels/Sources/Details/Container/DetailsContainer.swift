public final class DetailsContainer: DetailsContainerProtocol {
    // TODO: Remove after migration to single document for whole app
    public static let shared: DetailsContainerProtocol = DetailsContainer()
    
    private var details: [String: LegacyDetailsModel] = [:]
    
    public init() {}
    
    public func get(by id: String) -> LegacyDetailsModel? {
        details[id]
    }
    
    public func add(model: LegacyDetailsModel, by id: ParentId) {
        guard details[id] == nil else { return }
        // It is ok if details already exists
        // For example, if we add new page block, we will receive .objectDetailsSet event
        // then store details first time
        // and then we will receive .blockAdd and store details second time
        details[id] = model
        Self.shared.add(model: model, by: id)
    }
    
}
