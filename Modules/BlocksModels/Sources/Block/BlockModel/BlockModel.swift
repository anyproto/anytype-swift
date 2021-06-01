import Foundation
import Combine
import os

final class BlockModel: ObservableObject {
    @Published private var _information: BlockInformation
    private var _parent: BlockId?
    private var _kind: BlockKind {
        switch self._information.content {
        case .smartblock, .divider: return .meta
        case let .layout(layout) where layout.style == .div: return .meta
        case let .layout(layout) where layout.style == .header: return .meta
        default: return .block
        }
    }
    private var _didChangeSubject: PassthroughSubject<Void, Never> = .init()
    private var _didChangePublisher: AnyPublisher<Void, Never>

    required init(information: BlockInformation) {
        self._information = information
        self._didChangePublisher = self._didChangeSubject.eraseToAnyPublisher()
    }
}

extension BlockModel: BlockModelProtocol {
    var information: BlockInformation {
        get { self._information }
        set { self._information = newValue }
    }
    
    var parent: BlockId? {
        get { self._parent }
        set { self._parent = newValue }
    }
    
    var kind: BlockKind { self._kind }
    
    func didChangePublisher() -> AnyPublisher<Void, Never> { self._didChangePublisher }
    func didChange() { self._didChangeSubject.send() }
    
    func didChangeInformationPublisher() -> AnyPublisher<BlockInformation, Never> {
        self.$_information.eraseToAnyPublisher()
    }
}
