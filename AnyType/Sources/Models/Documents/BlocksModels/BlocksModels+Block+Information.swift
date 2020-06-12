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

// MARK: Details as Information
extension Namespace {
    /// What happens here?
    /// We convert details ( PageDetails ) to ready-to-use information.
    struct DetailsAsInformationConverter {
        typealias Information = BlocksModelsInformationModelProtocol
        typealias Content = BlocksModels.Aliases.BlockContent
        var information: Information
        
        private func detailsAsInformation(_ information: Information, _ details: PageDetails.Details) -> Information {
            /// Our ID is <ID>-<Details.key>
            let id = information.id + "-" + details.id()
            
            /// Actually, we don't care about block type.
            /// We only take care about "distinct" block model.
            let content: Content = .text(.empty())
            return InformationModel.init(id: id, content: content)
        }
        
        func callAsFunction(_ details: PageDetails.Details) -> BlocksModelsInformationModelProtocol {
            detailsAsInformation(self.information, details)
        }
    }
}

// MARK: Details as Block
extension Namespace {
    /// We need this converter to convert our details into a block.
    /// First, we convert them to an Information structure.
    /// Then, we convert it to block.
    ///
    /// Why do we need it?
    /// We need it to get block and later configure blocks views with this block and then render them.
    ///
    struct DetailsAsBlockConverter {
        typealias Information = BlocksModelsInformationModelProtocol
        typealias Block = BlocksModels.Block.BlockModel

        var information: Information
        
        private func detailsAsBlock(_ details: PageDetails.Details) -> Block {
            .init(information: DetailsAsInformationConverter(information: self.information)(details))
        }
        
        func callAsFunction(_ details: PageDetails.Details) -> BlocksModelsBlockModelProtocol {
            detailsAsBlock(details)
        }
    }
}
