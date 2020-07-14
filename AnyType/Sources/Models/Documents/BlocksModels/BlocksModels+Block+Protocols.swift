//
//  BlocksModels+Block+Protocols.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

// MARK: - BlockModel
protocol BlocksModelsBlockModelProtocol: BlocksModelsHasInformationProtocol, BlocksModelsHasParentProtocol, BlocksModelsHasKindProtocol, BlocksModelsHasDidChangePublisherProtocol {}

// MARK: - UserSession
protocol BlocksModelsUserSessionModelProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    typealias Position = BlocksModels.Aliases.FocusPosition
    func isToggled(by id: BlockId) -> Bool
    func isFirstResponder(by id: BlockId) -> Bool
    func firstResponder() -> BlockId?
    func focusAt() -> Position?
    func setToggled(by id: BlockId, value: Bool)
    func setFirstResponder(by id: BlockId)
    func setFocusAt(position: Position)
    
    func unsetFirstResponder()
    func unsetFocusAt()
    
    func didChangePublisher() -> AnyPublisher<Void, Never>
    func didChange()
}

/// We need to distinct Container and BlockContainer.
/// One of them contains UserSession.
/// Another contains BlockContainer and DetailsContainer.

// MARK: - Container
protocol BlocksModelsContainerModelProtocol: class, BlocksModelsHasRootIdProtocol, BlocksModelsHasUserSessionProtocol, BlocksModelsHasDetailsContainerModelProtocol {
    // MARK: - Operations / List
    func list() -> AnyIterator<BlockId>
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlocksModelsChosenBlockModelProtocol?
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlocksModelsBlockModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: BlockId)
    // MARK: - Operations / Add
    func add(_ block: BlocksModelsBlockModelProtocol)
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
protocol BlocksModelsChosenBlockModelProtocol: BlocksModelsHasContainerProtocol, BlocksModelsHasBlockModelProtocol, BlocksModelsHasIndentationLevelProtocol, BlocksModelsCanBeRootProtocol, BlocksModelsFindParentAndRootProtocol, BlocksModelsFindChildProtocol, BlocksModelsCanBeFirstResponserProtocol, BlocksModelsCanBeToggledProtocol, BlocksModelsCanHaveFocusAtProtocol, BlocksModelsHasDidChangePublisherProtocol {}

// MARK: - DetailsContainer / Has
protocol BlocksModelsHasDetailsContainerModelProtocol {
    typealias DetailsContainer = BlocksModelsDetailsContainerModelProtocol
    var detailsContainer: DetailsContainer {get}
}

// MARK: - DetailsContainer
protocol BlocksModelsDetailsContainerModelProtocol {
    typealias DetailsId = BlocksModels.Aliases.BlockId
    // MARK: - Operations / List
    func list() -> AnyIterator<DetailsId>
    // MARK: - Operations / Choose
    func choose(by id: DetailsId) -> BlocksModelsChosenDetailsModelProtocol?
    // MARK: - Operations / Get
    func get(by id: DetailsId) -> BlocksModelsDetailsModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: DetailsId)
}

// MARK: - DetailsModel
protocol BlocksModelsDetailsModelProtocol: BlocksModelsHasDetailsProtocol, BlocksModelsHasDetailsParentProtocol {}

// MARK: - DetaisModel / Has Details
protocol BlocksModelsHasDetailsProtocol {
    typealias Details = BlocksModels.Aliases.PageDetails
    var details: Details {get set}
    init(details: Details)
}

// MARK: DetailsModel / Has DetailsParent
protocol BlocksModelsHasDetailsParentProtocol {
    typealias DetailsId = BlocksModels.Aliases.BlockId
    var parent: DetailsId? {get set}
}

// MARK: - ChosenDetailsModel
protocol BlocksModelsChosenDetailsModelProtocol: BlocksModelsHasDetailsContainerProtocol, BlocksModelsHasDetailsModelProtocol {}
//BlocksModelsHasDidChangePublisherProtocol

// MARK: - ChosenDetailsModel / BlockModel
protocol BlocksModelsHasDetailsContainerProtocol {
    var container: BlocksModelsDetailsContainerModelProtocol? {get}
}

// MARK: - ChosenDetailsModel / BlockModel
protocol BlocksModelsHasDetailsModelProtocol {
    var detailsModel: BlocksModelsDetailsModelProtocol {get}
}
