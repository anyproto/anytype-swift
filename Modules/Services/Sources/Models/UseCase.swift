import Foundation
import ProtobufMessages

public enum UseCase {
    case none
    case getStarted
    case personalProjects
    case knowledgeBase
    case notesDiary
    case strategicWriting
    case empty
}

extension UseCase {
    func toMiddleware() -> Anytype_Rpc.Object.ImportUseCase.Request.UseCase {
        switch self {
        case .none:
            return .none
        case .getStarted:
            return .getStarted
        case .personalProjects:
            return .personalProjects
        case .knowledgeBase:
            return .knowledgeBase
        case .notesDiary:
            return .notesDiary
        case .strategicWriting:
            return .strategicWriting
        case .empty:
            return .empty
        }
    }
}
