import Services

struct ChatMessageAttachmentsStorage: Sendable {
    
    private var attachmentsDetails: [String: ObjectDetails] = [:]
    
    func details(ids: [String]) -> [ObjectDetails] {
        ids.compactMap { attachmentsDetails[$0] }
    }
    
    func details(id: String) -> ObjectDetails? {
        attachmentsDetails[id]
    }
    
    @discardableResult
    mutating func update(details: [ObjectDetails]) -> Bool {
        var updated = false
        for detail in details where attachmentsDetails[detail.id] != detail {
            attachmentsDetails[detail.id] = detail
            updated = true
        }
        return updated
    }
    
    mutating func remove(ids: [String]) {
        for id in ids {
            attachmentsDetails.removeValue(forKey: id)
        }
    }
    
    var ids: some Collection<String> {
        attachmentsDetails.keys
    }
}
