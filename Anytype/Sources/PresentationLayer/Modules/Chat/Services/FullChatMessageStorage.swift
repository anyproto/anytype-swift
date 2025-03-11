import Services

struct ChatMessageAttachmentsStorage {
    private(set) var attachmentsDetails: [String: ObjectDetails] = [:]
    
    func details(ids: [String]) -> [ObjectDetails] {
        ids.compactMap { attachmentsDetails[$0] }
    }
    
    func details(id: String) -> ObjectDetails? {
        attachmentsDetails[id]
    }
    
    @discardableResult
    mutating func update(details: [ObjectDetails]) async -> Bool {
        let newAttachments = details
            .reduce(into: [String: ObjectDetails]()) { $0[$1.id] = $1 }
        
        if attachmentsDetails != newAttachments {
            attachmentsDetails.merge(newAttachments, uniquingKeysWith: { $1 })
            return true
        } else {
            return false
        }
    }
    
    var ids: [String] {
        Array(attachmentsDetails.keys)
    }
}
