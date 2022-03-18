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
        ToggleStorage.shared.isToggled(blockId: information.id)
    }

    public func toggle() {
        ToggleStorage.shared.toggle(blockId: information.id)
    }

    public var kind: BlockKind {
        switch self.information.content {
        case .smartblock, .layout:
            return .meta
        case .text, .file, .divider, .bookmark, .link, .featuredRelations, .relation, .dataView, .unsupported:
            return .block
        }
    }

    public required init(information: BlockInformation) {
        self.information = information
    }
}
