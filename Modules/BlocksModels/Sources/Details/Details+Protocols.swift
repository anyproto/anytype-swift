//
//  Details+Protocols.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import Combine

// MARK: - DetailsContainer / HasDetailsContainer
public protocol BlockHasDetailsContainerModelProtocol {
    typealias DetailsContainer = DetailsContainerModelProtocol
    var detailsContainer: DetailsContainer {get}
}

// MARK: - DetailsContainer
public protocol DetailsContainerModelProtocol {
    typealias DetailsId = TopLevel.DetailsId
    // MARK: - Operations / List
    func list() -> AnyIterator<DetailsId>
    // MARK: - Operations / Choose
    func choose(by id: DetailsId) -> DetailsActiveRecordModelProtocol?
    // MARK: - Operations / Get
    func get(by id: DetailsId) -> DetailsModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: DetailsId)
    // MARK: - Operations / Add
    func add(_ model: DetailsModelProtocol)
}

// MARK: - DetailsModel
public protocol DetailsModelProtocol: DetailsHasInformationProtocol, DetailsHasParentProtocol, DetailsHasDidChangeInformationPublisherProtocol {}

// MARK: - DetaisModel / Has Details
public protocol DetailsHasInformationProtocol {
    var details: DetailsInformationModelProtocol {get set}
    init(details: DetailsInformationModelProtocol)
}

// MARK: DetailsModel / Has DetailsParent
public protocol DetailsHasParentProtocol {
    typealias DetailsId = TopLevel.DetailsId
    var parent: DetailsId? {get set}
}

// MARK: - DetailsActiveRecord
public protocol DetailsActiveRecordModelProtocol: DetailsActiveRecordHasContainerProtocol, DetailsActiveRecordHasModelProtocol, DetailsHasDidChangeInformationPublisherProtocol {}

// MARK: - DetailsActiveRecord / HasContainer
public protocol DetailsActiveRecordHasContainerProtocol {
    var container: DetailsContainerModelProtocol? {get}
}

// MARK: - DetailsActiveRecord / HasModel
public protocol DetailsActiveRecordHasModelProtocol {
    var detailsModel: DetailsModelProtocol {get}
}

// MARK: - DetailsActiveRecord / Publisher
public protocol DetailsHasDidChangeInformationPublisherProtocol {
    func didChangeInformationPublisher() -> AnyPublisher<DetailsInformationModelProtocol, Never>
}
