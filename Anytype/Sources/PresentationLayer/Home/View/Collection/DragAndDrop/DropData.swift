import ProtobufMessages

struct DropData {
    enum Direction {
        case before
        case after
        
        func toBlockModel() -> Anytype_Model_Block.Position {
            switch self {
            case .after:
                return .bottom
            case .before:
                return .top
            }
        }
    }
    
    var draggingCellData: PageCellData?
    var dropPositionCellData: PageCellData?
    var direction: Direction?
}
