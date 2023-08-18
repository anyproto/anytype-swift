import ProtobufMessages

public enum BlocksSortType {
    case asc
    case desc

    var asMiddleware: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum {
        switch self {
        case .asc:
            return .asc
        case .desc:
            return .desc
        }
    }
}
