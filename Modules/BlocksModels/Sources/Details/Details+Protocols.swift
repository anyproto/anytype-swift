//
//  Details+Protocols.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import Combine

// MARK: - DetailsActiveRecord
public protocol DetailsActiveRecordModelProtocol: DetailsActiveRecordHasContainerProtocol, DetailsActiveRecordHasModelProtocol, DetailsHasDidChangeInformationPublisherProtocol {}

// MARK: - DetailsActiveRecord / HasContainer
public protocol DetailsActiveRecordHasContainerProtocol {
    
    var container: DetailsStorageProtocol? { get }
    
}

// MARK: - DetailsActiveRecord / HasModel
public protocol DetailsActiveRecordHasModelProtocol {
    
    var detailsModel: DetailsModelProtocol { get }
    
}

// MARK: - DetailsActiveRecord / Publisher
public protocol DetailsHasDidChangeInformationPublisherProtocol {
    
    func changeInformationPublisher() -> AnyPublisher<DetailsProviderProtocol, Never>
    
}
