import ProtobufMessages

public extension SpaceUxType {
    var isStream: Bool {
        self == .stream
    }
    
    var isChat: Bool {
        self == .chat
    }
    
    var isData: Bool {
        self == .data
    }
}

