//
//  BlockModel+NewModels+Information.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: Information
extension BlockModels.Block {
    struct Information: MiddlewareBlockInformationModel {
        static func defaultValue() -> BlockModels.Block.Information { .default }
        
        var id: String
        var content: BlockType
        var childrenIds: [String] = []
        var fields: [String: Any] = .init()
        var restrictions: [String] = []
        
        var alignment: Alignment = .left
        
        /// TODO: Add later to Protocol.
        var backgroundColor: String = ""
        
        /// TODO: Extract it and refactor later.
        ///
        /// Discussion
        ///
        /// We don't have Smartblocks now, so, we need to `emulate` them.
        /// Again, this is "emulation" of `smartblock`, so, we don't need to add them to protocol.
        ///
        var details: PageDetails = .empty
        
        init(id: String, content: BlockType) {
            self.id = id
            self.content = content
            self.backgroundColor = ""
        }
        
        init(information: MiddlewareBlockInformationModel) {
            self.id = information.id
            self.content = information.content
            self.childrenIds = information.childrenIds
            self.fields = information.fields
            self.restrictions = information.restrictions
            self.backgroundColor = information.backgroundColor
            
            if let concreteInformation = information as? Self {
                self.alignment = concreteInformation.alignment
                self.details = concreteInformation.details
            }
        }
        
        static let `defaultId`: String = "DefaultIdentifier"
        static let `defaultBlockType`: BlockType = .text(.init(text: "DefaultText", contentType: .text))
        static let `default`: Information = .init(id: Self.defaultId, content: Self.defaultBlockType)
    }
}

// MARK: Alignment
extension BlockModels.Block.Information {
    enum Alignment {
        case left, center, right
    }
}

// MARK: Details as Information
extension BlockModels.Block.Information {
    /// What happens here?
    /// We convert details ( PageDetails ) to ready-to-use information.
    struct DetailsAsInformationConverter {
        typealias Information = BlockModels.Block.Information
        
        var information: Information
        
        func detailsAsInformation(_ information: Information, _ details: Details) -> Information {
            /// Our ID is <ID>-<Details.key>
            let id = information.id + "-" + details.id()
            
            /// Actually, we don't care about block type.
            /// We only take care about "distinct" block model.
            let blockType: BlockType = .text(.empty())
            return .init(id: id, content: blockType)
        }
        
        func callAsFunction(_ details: Details) -> Information {
            detailsAsInformation(self.information, details)
        }
    }
    
    func detailsAsInformation(_ details: Details) -> BlockModels.Block.Information {
        DetailsAsInformationConverter(information: self)(details)
    }
}

// MARK: Details as Block
extension BlockModels.Block.Information {
    /// We need this converter to convert our details into a block.
    /// First, we convert them to an Information structure.
    /// Then, we convert it to block.
    ///
    /// Why do we need it?
    /// We need it to get block and later configure blocks views with this block and then render them.
    ///
    struct DetailsAsBlockConverter {
                
        typealias Block = BlockModels.Block.RealBlock
        typealias Information = BlockModels.Block.Information
        
        var information: Information
        
        func detailsAsBlock(_ details: Details) -> Block {
            .init(information: DetailsAsInformationConverter(information: self.information)(details))
        }
        
        func callAsFunction(_ details: Details) -> Block {
            detailsAsBlock(details)
        }
    }
}
