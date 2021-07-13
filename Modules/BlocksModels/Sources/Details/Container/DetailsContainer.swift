public final class DetailsContainer: DetailsContainerProtocol {
    
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
    }
    
}
