//
//  BlocksModels+Block+Protocols+ChosenBlock.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

// MARK: - Container
protocol BlocksModelsHasUserSessionProtocol {
    typealias UserSession = BlocksModelsUserSessionModelProtocol
    var userSession: UserSession {get}
}

protocol BlocksModelsHasRootIdProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    var rootId: BlockId? {get set}
}

// MARK: - ChosenBlock / BlockModel
protocol BlocksModelsHasContainerProtocol {
    var container: BlocksModelsContainerModelProtocol? {get}
}

// MARK: - ChosenBlock / BlockModel
protocol BlocksModelsHasBlockModelProtocol {
    var blockModel: BlocksModelsBlockModelProtocol {get}
}

// MARK: - ChosenBlock / IndentationLevel
protocol BlocksModelsHasIndentationLevelProtocol {
    static var defaultIndentationLevel: Int {get}
    var indentationLevel: Int {get}
}

// MARK: - ChosenBlock / isRoot
protocol BlocksModelsCanBeRootProtocol {
    var isRoot: Bool {get}
}

// MARK: - ChosenBlock / FindRoot and FindParent
protocol BlocksModelsFindParentAndRootProtocol {
    func findParent() -> Self?
    func findRoot() -> Self?
}

// MARK: - ChosenBlock / Children
protocol BlocksModelsFindChildProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    func childrenIds() -> [BlockId]
    func findChild(by id: BlockId) -> Self?
}

// MARK: - ChosenBlock / isFirstRepsonder
protocol BlocksModelsCanBeFirstResponserProtocol {
    var isFirstResponder: Bool {get set}
    func unsetFirstResponder()
}

// MARK: - ChosenBlock / isToggled
protocol BlocksModelsCanBeToggledProtocol {
    var isToggled: Bool {get set}
}

// MARK: - ChosenBlock / FocusAt
protocol BlocksModelsCanHaveFocusAtProtocol {
    typealias Position = BlocksModels.Aliases.FocusPosition
    var focusAt: Position? {get set}
}

extension BlocksModelsCanHaveFocusAtProtocol {
    mutating func unsetFocusAt() { self.focusAt = nil }
}

// MARK: - ChosenBlock / Publishing
protocol BlocksModelsHasDidChangePublisherProtocol {
    func didChangePublisher() -> AnyPublisher<Void, Never>
    func didChange()
}
