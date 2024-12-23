import AnytypeCore

public final class ObjectRestrictionsContainer: Sendable {
    private let restrictionsStorage = AtomicStorage(ObjectRestrictions())
    
    public var restrictions: ObjectRestrictions {
        get { restrictionsStorage.value }
        set { restrictionsStorage.value = newValue }
    }
    
    public init() { }
}
