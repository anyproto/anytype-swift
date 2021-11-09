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

    public var isFirstResponder: Bool {
        get {
            UserSession.shared.firstResponderId.value == information.id
        }
        set {
            UserSession.shared.firstResponderId.value = information.id
        }
    }

    public func unsetFirstResponder() {
        if isFirstResponder {
            UserSession.shared.firstResponderId.value = nil
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
            guard UserSession.shared.firstResponderId.value == information.id else { return nil }
            return UserSession.shared.focus.value
        }
        set {
            guard UserSession.shared.firstResponderId.value == information.id else { return }
            if let value = newValue {
                UserSession.shared.focus.value = value
            }
            else {
                UserSession.shared.focus.value = nil
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
