typealias SystemContentConfiguationProvider = (ContentConfigurationProvider & HashableProvier & BlockFocusing & BlockIdProvider)

enum EditorItem: Hashable, @unchecked Sendable {
    case header(ObjectHeader)
    case block(any BlockViewModelProtocol)
    case system(any SystemContentConfiguationProvider)
    
    static func == (lhs: EditorItem, rhs: EditorItem) -> Bool {
        switch (lhs, rhs) {
        case let (.block(lhsBlock), .block(rhsBlock)):
            return lhsBlock.hashable == rhsBlock.hashable
        case let (.header(lhsHeader), .header(rhsHeader)):
            return lhsHeader == rhsHeader
        case let (.system(rhsSystem), .system(lhsSystem)):
            return rhsSystem.hashable == lhsSystem.hashable
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .block(block):
            hasher.combine(block.hashable)
        case let .header(header):
            hasher.combine(header)
        case let.system(system):
            hasher.combine(system.hashable)
        }
    }
    
    var id: String? {
        switch self {
        case let .block(block):
            return block.info.id
        case .header, .system:
            return nil
        }
    }
}

extension EditorItem: HashableProvier {
    var hashable: AnyHashable {
        switch self {
        case .header(let objectHeader):
            return objectHeader.hashable
        case .block(let blockViewModelProtocol):
            return blockViewModelProtocol.hashable
        case .system(let systemContentConfiguationProvider):
            return systemContentConfiguationProvider.hashable
        }
    }
}

extension CollectionDifference where ChangeElement == EditorItem {
    var canPerformAnimation: Bool {
        !insertions.contains { item in
            switch item.element {
            case .block(let blockViewModel):
                if case .featuredRelations = blockViewModel.content {
                    return true
                }

                return false
            default: return false
            }
        }
    }
}

extension EditorItem {
    @MainActor
    func didSelect(in state: EditorEditingState) {
        switch self {
        case .header(let objectHeader):
            objectHeader.didSelectRowInTableView(editorEditingState: state)
        case .block(let blockViewModel):
            blockViewModel.didSelectRowInTableView(editorEditingState: state)
        case .system(let systemContentConfiguationProvider):
            systemContentConfiguationProvider.didSelectRowInTableView(editorEditingState: state)
        }
    }
}

