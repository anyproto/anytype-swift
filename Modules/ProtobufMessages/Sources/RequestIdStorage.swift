actor RequestIdStorage {
    
    static let `shared` = RequestIdStorage()
    
    private var id: Int = 0
    private init() {}
    
    func createId() -> Int {
        id += 1
        return id
    }
}
