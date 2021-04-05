//
//  Details+Information+Protocols.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

public protocol DetailsInformationModelProtocol {
    typealias DetailsId = TopLevel.DetailsId
    typealias DetailsContent = TopLevel.DetailsContent
    
    var details: [DetailsId : DetailsContent] {get set}
    
    var parentId: String? {get set}
    
    init(_ details: [DetailsId : DetailsContent])
    
    static func defaultValue() -> Self
}

// MARK: ToList
public extension DetailsInformationModelProtocol {
    func toList() -> [DetailsContent] {
        Array(self.details.values)
    }
}

// MARK: Inits
public extension DetailsInformationModelProtocol {
    init(_ list: [DetailsContent]) {
        let keys = list.compactMap({($0.id(), $0)})
        self.init(.init(keys, uniquingKeysWith: {(_, rhs) in rhs}))
    }
}
