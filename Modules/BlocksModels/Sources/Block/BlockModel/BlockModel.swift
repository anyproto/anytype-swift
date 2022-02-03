import Foundation
import Combine
import SwiftProtobuf
import ProtobufMessages


public final class BlockModel: ObservableObject, BlockModelProtocol {
    @Published public var information: BlockInformation
    public var parent: BlockModelProtocol?
    public var indentationLevel: Int = 0

    public var isRoot: Bool {
        parent == nil
    }

    public var isToggled: Bool {
        get {
            UserSession.shared.toggles[information.id] ?? false
        }
    }

    public func toggle() {
        let newValue = !isToggled
        UserSession.shared.toggles[information.id] = newValue
    }

    public var kind: BlockKind {
        switch self.information.content {
        case .smartblock: return .meta
        case .layout: return .meta
        default: return .block
        }
    }

    public required init(information: BlockInformation) {
        self.information = information
    }
}
