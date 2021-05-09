import Foundation
import Combine

// MARK: - BlockModel
public protocol BlockModelProtocol: BlockHasInformationProtocol, BlockHasParentProtocol, BlockHasKindProtocol, BlockHasDidChangePublisherProtocol, BlockHasDidChangeInformationPublisherProtocol {}

// MARK: - UserSession
public protocol BlockUserSessionModelProtocol {
    typealias Position = BlockFocusPosition
    /// Get toggled state for block
    ///
    /// - Parameters:
    ///   - id: Block id to get state
    func isToggled(by id: BlockId) -> Bool
    func isFirstResponder(by id: BlockId) -> Bool
    func firstResponderId() -> BlockId?
    func firstResponder() -> BlockModelProtocol?
    func focusAt() -> Position?
    /// Set toggled state for block
    ///
    /// - Parameters:
    ///   - id: Block id to change state
    func setToggled(by id: BlockId, value: Bool)
    func setFirstResponder(with blockModel: BlockModelProtocol)
    func setFocusAt(position: Position)
    
    func unsetFirstResponder()
    func unsetFocusAt()
    
    func didChangePublisher() -> AnyPublisher<Void, Never>
    func didChange()
    
    /// We could also store number here.
}

/// We need to distinct Container and BlockContainer.
/// One of them contains UserSession.
/// Another contains BlockContainer and DetailsContainer.

// MARK: - Container
public protocol BlockHasUserSessionProtocol {
    typealias UserSession = BlockUserSessionModelProtocol
    var userSession: UserSession {get}
}

public protocol BlockHasRootIdProtocol {
    var rootId: BlockId? {get set}
}
public protocol BlockContainerModelProtocol: AnyObject, BlockHasRootIdProtocol, BlockHasUserSessionProtocol {
    // MARK: - Operations / List
    func list() -> AnyIterator<BlockId>
    func children(of id: BlockId) -> [BlockId]
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlockActiveRecordModelProtocol?
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlockModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: BlockId)
    // MARK: - Operations / Add
    func add(_ block: BlockModelProtocol)
    // MARK: - Children / Append
    func append(childId: BlockId, parentId: BlockId)
    // MARK: - Children / Add Before
    func add(child: BlockId, beforeChild: BlockId)
    // MARK: - Children / Add
    func add(child: BlockId, afterChild: BlockId)
    // MARK: - Children / Replace
    func replace(childrenIds: [BlockId], parentId: BlockId, shouldSkipGuardAgainstMissingIds: Bool)
}

// MARK: - ChosenBlock
public protocol BlockActiveRecordModelProtocol: BlockActiveRecordHasContainerProtocol, BlockActiveRecordHasBlockModelProtocol, BlockActiveRecordHasIndentationLevelProtocol, BlockActiveRecordCanBeRootProtocol, BlockActiveRecordFindParentAndRootProtocol, BlockActiveRecordFindChildProtocol, BlockActiveRecordCanBeFirstResponserProtocol, BlockActiveRecordCanBeToggledProtocol, BlockActiveRecordCanHaveFocusAtProtocol, BlockHasDidChangePublisherProtocol, BlockHasDidChangeInformationPublisherProtocol {}
