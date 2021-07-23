import Foundation
import Combine
import os

public final class BlockModel: ObservableObject {
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

    public required init(information: BlockInformation) {
        self._information = information
        self._didChangePublisher = self._didChangeSubject.eraseToAnyPublisher()
    }
}

extension BlockModel: BlockModelProtocol {
    public var information: BlockInformation {
        get { self._information }
        set { self._information = newValue }
    }
    
    public var parent: BlockId? {
        get { self._parent }
        set { self._parent = newValue }
    }
    
    public var kind: BlockKind { self._kind }
    
    public func didChangePublisher() -> AnyPublisher<Void, Never> { self._didChangePublisher }
    public func didChange() { self._didChangeSubject.send() }
    
    public func didChangeInformationPublisher() -> AnyPublisher<BlockInformation, Never> {
        self.$_information.eraseToAnyPublisher()
    }
}
