import Foundation
import Combine
import SwiftProtobuf
import ProtobufMessages


public final class BlockModel: ObservableObject, BlockModelProtocol {
    public weak var container: BlockContainerModelProtocol?

    @Published public var information: BlockInformation
    public var parent: BlockModelProtocol?
    public var indentationLevel: Int = 0

    public var isRoot: Bool {
        parent == nil
    }

    public var isFirstResponder: Bool {
        get {
            UserSession.shared.firstResponderId == information.id
        }
        set {
            UserSession.shared.firstResponderId = information.id
        }
    }

    public func unsetFirstResponder() {
        if isFirstResponder {
            UserSession.shared.firstResponderId = nil
        }
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

    public var focusAt: BlockFocusPosition? {
        get {
            guard UserSession.shared.firstResponderId == information.id else { return nil }
            return UserSession.shared.focus
        }
        set {
            guard UserSession.shared.firstResponderId == information.id else { return }
            if let value = newValue {
                UserSession.shared.focus = value
            }
            else {
                UserSession.shared.focus = nil
            }
        }
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
