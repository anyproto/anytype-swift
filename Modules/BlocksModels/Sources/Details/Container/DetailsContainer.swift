import AnytypeCore

public final class DetailsContainer: DetailsContainerProtocol {
    // TODO: Remove after migration to single document for whole app
    public static let shared: DetailsContainerProtocol = SharedDetailsContainer()
    
    private var details = SynchronizedDictionary<String, LegacyDetailsModel>()
    
    public init() {}
    
    public func get(by id: String) -> LegacyDetailsModel? {
        details[id]
    }
    
    public func add(model: LegacyDetailsModel, id: BlockId) {
        Self.shared.add(model: model, id: id)
        
        guard details[id] == nil else { return }
        // It is ok if details already exists
        // For example, if we add new page block, we will receive .objectDetailsSet event
        // then store details first time
        // and then we will receive .blockAdd and store details second time
        details[id] = model
    }
}

public final class SharedDetailsContainer: DetailsContainerProtocol {
    private var details = SynchronizedDictionary<String, LegacyDetailsModel>()
    
    public init() {}
    
    public func get(by id: String) -> LegacyDetailsModel? {
        details[id]
    }
    
    public func add(model: LegacyDetailsModel, id: BlockId) {
        details[id] = model
    }
}
