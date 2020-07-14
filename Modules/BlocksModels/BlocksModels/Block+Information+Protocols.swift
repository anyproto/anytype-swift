//
//  Block+Information+Protocols.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

public protocol BlockInformationModelProtocol {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Content = TopLevel.AliasesMap.BlockContent
    typealias ChildrenIds = TopLevel.AliasesMap.ChildrenIds
    typealias BackgroundColor = TopLevel.AliasesMap.BackgroundColor
    typealias Alignment = TopLevel.AliasesMap.Alignment
    
    typealias Diffable = AnyHashable
    
    var id: BlockId {get set}
    var childrenIds: ChildrenIds {get set}
    var content: Content {get set}
    
    var fields: [String: AnyHashable] {get set}
    var restrictions: [String] {get set}
    
    var backgroundColor: BackgroundColor {get set}
    var alignment: Alignment {get set}
        
    static func defaultValue() -> Self
    
    func diffable() -> Diffable
    
    init(id: BlockId, content: Content)
    init(information: BlockInformationModelProtocol)
}

protocol BlockInformationModelProtocolWithHashable: BlockInformationModelProtocol, Hashable {}
