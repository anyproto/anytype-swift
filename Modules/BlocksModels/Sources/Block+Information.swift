//
//  Block+Information.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Block.Information

extension Block {
    public enum Information {}
}

extension Namespace {
    public struct InformationModel {
        public typealias BlockId = TopLevel.AliasesMap.BlockId
        public typealias Content = TopLevel.AliasesMap.BlockContent
        public typealias ChildrenIds = TopLevel.AliasesMap.ChildrenIds
        public typealias BackgroundColor = TopLevel.AliasesMap.BackgroundColor
        public typealias Alignment = TopLevel.AliasesMap.Alignment

        public var id: BlockId
        public var childrenIds: ChildrenIds = []
        public var content: Content
        
        public var fields: [String : AnyHashable] = [:]
        var restrictions: [String] = []
        
        public var backgroundColor: BackgroundColor = ""
        public var alignment: Alignment = .left
                
        static func defaultValue() -> Self { .default }
        
        public init(id: BlockId, content: Content) {
            self.id = id
            self.content = content
        }
        
        public init(information: Self) {
            self.id = information.id
            self.content = information.content
            self.childrenIds = information.childrenIds
            
            self.fields = information.fields
            self.restrictions = information.restrictions
            
            self.backgroundColor = information.backgroundColor
            self.alignment = information.alignment
        }
        
        private static let `defaultId`: BlockId = "DefaultIdentifier"
        private static let `defaultBlockType`: Content = .text(.createDefault(text: "DefaultText"))
        private static let `default`: Self = .init(id: Self.defaultId, content: Self.defaultBlockType)
    }
}

// MARK: Hashable
extension Namespace.InformationModel: Hashable {

}
extension Namespace.Alignment: Hashable {}

// MARK: Alignment
extension Namespace {
    public enum Alignment {
        case left, center, right
    }
}

// MARK: Details as Information
extension Namespace {
    /// What happens here?
    /// We convert details ( PageDetails ) to ready-to-use information.
    struct DetailsAsInformationConverter {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias Content = TopLevel.AliasesMap.BlockContent
        typealias Details = TopLevel.AliasesMap.DetailsContent
        var blockId: BlockId

        private func detailsAsInformation(_ blockId: BlockId, _ details: Details) -> InformationModel {
            /// Our ID is <ID>/<Details.key>.
            /// Look at implementation in `IdentifierBuilder`
            
            let id = Namespace.DetailsAsBlockConverter.IdentifierBuilder.asBlockId(blockId, details.id())

            /// Actually, we don't care about block type.
            /// We only take care about "distinct" block model.
            let content: Content = .text(.empty())
            return InformationModel.init(id: id, content: content)
        }

        func callAsFunction(_ details: Details) -> InformationModel {
            detailsAsInformation(self.blockId, details)
        }
    }
}

/// TODO: Time to remove Details Crutches.
public extension Namespace.DetailsAsBlockConverter {
    struct IdentifierBuilder {
        public typealias Details = TopLevel.AliasesMap.DetailsContent
        public typealias DetailsId = TopLevel.AliasesMap.DetailsId
        public typealias BlockId = TopLevel.AliasesMap.BlockId
        static var separator: Character = "/"
        public static func asBlockId(_ blockId: BlockId, _ id: DetailsId) -> BlockId {
            blockId + "\(self.separator)" + id
        }
        public static func asDetails(_ id: BlockId) -> (BlockId, DetailsId) {
            guard let index = id.lastIndex(of: self.separator) else { return (id, "") }
            let substring = id[index...].dropFirst()
            let prefix = String(id.prefix(upTo: index))
            switch String(substring) {
            case Details.Title.id: return (prefix, Details.Title.id)
            case Details.Emoji.id: return (prefix, Details.Emoji.id)
            default: return ("", "")
            }
        }
    }
}

// MARK: Details as Block
public extension Namespace {
    /// We need this converter to convert our details into a block.
    /// First, we convert them to an Information structure.
    /// Then, we convert it to block.
    ///
    /// Why do we need it?
    /// We need it to get block and later configure blocks views with this block and then render them.
    ///
    struct DetailsAsBlockConverter {
        public typealias Details = TopLevel.AliasesMap.DetailsContent
        public typealias BlockModel = BlockModelProtocol
        public typealias BlockId = TopLevel.AliasesMap.BlockId
        
        var blockId: BlockId

        private func detailsAsBlock(_ details: Details) -> BlockModel {
            TopLevel.Builder.blockBuilder.build(information: DetailsAsInformationConverter(blockId: self.blockId)(details))
        }

        public func callAsFunction(_ details: Details) -> BlockModelProtocol {
            detailsAsBlock(details)
        }
        
        // MARK: - Memberwise Initializer
        public init(blockId: BlockId) {
            self.blockId = blockId
        }
    }
}
