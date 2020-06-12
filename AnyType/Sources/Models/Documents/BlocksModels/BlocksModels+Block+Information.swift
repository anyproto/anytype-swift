//
//  BlocksModels+Block+Information.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 04.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

protocol BlocksModelsInformationModelProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    typealias Content = BlocksModels.Aliases.BlockContent
    typealias ChildrenIds = BlocksModels.Aliases.ChildrenIds
    typealias BackgroundColor = BlocksModels.Aliases.BackgroundColor
    typealias Alignment = BlocksModels.Aliases.Alignment
    typealias PageDetails = BlocksModels.Aliases.PageDetails
    
    var id: BlockId {get set}
    var childrenIds: ChildrenIds {get set}
    var content: Content {get set}
    
    var fields: [String: Any] {get set}
    var restrictions: [String] {get set}
    
    var backgroundColor: BackgroundColor {get set}
    var alignment: Alignment {get set}
    
    var pageDetails: PageDetails {get set}
    
    static func defaultValue() -> Self
    
    init(id: BlockId, content: Content)
    init(information: BlocksModelsInformationModelProtocol)
}

fileprivate typealias Namespace = BlocksModels.Block.Information
extension BlocksModels.Block {
    enum Information {}
}

extension Namespace {
    struct InformationModel: BlocksModelsInformationModelProtocol {
        var id: BlockId
        var childrenIds: ChildrenIds = []
        var content: Content
        
        var fields: [String : Any] = [:]
        var restrictions: [String] = []
        
        var backgroundColor: BackgroundColor = ""
        var alignment: Alignment = .left
        
        var pageDetails: PageDetails = .empty
        
        static func defaultValue() -> Self { .default }
        
        init(id: BlockId, content: Content) {
            self.id = id
            self.content = content
        }
        
        init(information: BlocksModelsInformationModelProtocol) {
            self.id = information.id
            self.content = information.content
            self.childrenIds = information.childrenIds
            
            self.fields = information.fields
            self.restrictions = information.restrictions
            
            self.backgroundColor = information.backgroundColor
            self.alignment = information.alignment
            
            self.pageDetails = information.pageDetails
        }
        
        private static let `defaultId`: BlockId = "DefaultIdentifier"
        private static let `defaultBlockType`: Content = .text(.createDefault(text: "DefaultText"))
        private static let `default`: Self = .init(id: Self.defaultId, content: Self.defaultBlockType)
    }
}

// MARK: Alignment
extension Namespace {
    enum Alignment {
        case left, center, right
    }
}
