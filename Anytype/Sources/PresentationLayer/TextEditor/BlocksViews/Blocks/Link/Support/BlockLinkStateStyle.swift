import BlocksModels

extension BlockLinkState {
    
    enum Style: Hashable, Equatable {
        case noContent
        case icon(ObjectIconType)
        case checkmark(Bool)
    }
    
}

extension BlockLinkState.Style {
    
    init(details: ObjectDetails) {
        if let objectIcon = details.icon {
            self = .icon(objectIcon)
            return
        }
        
        guard case .todo = details.layout else {
            self = .noContent
            return
        }
        
        self = .checkmark(details.isDone)
    }
    
}
