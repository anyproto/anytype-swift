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
        let newAttachments = details
            .reduce(into: [String: ObjectDetails]()) { $0[$1.id] = $1 }
        
        if attachmentsDetails != newAttachments {
            attachmentsDetails.merge(newAttachments, uniquingKeysWith: { $1 })
            return true
        } else {
            return false
        }
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
