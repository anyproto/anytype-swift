import Foundation
import AnytypeCore
import SwiftProtobuf
import ProtobufMessages

public protocol BundledRelationsValueProvider {
    
    var values: [String: Google_Protobuf_Value] { get }
    
    var id: BlockId { get }
    var name: String { get }
    var snippet: String { get }
    var iconEmoji: String { get }
    var iconImageHash: Hash? { get }
    var coverId: String { get }
    var coverType: CoverType { get }
    var isArchived: Bool { get }
    var isFavorite: Bool { get }
    var description: String { get }
    var layout: DetailsLayout { get }
    var layoutAlign: LayoutAlignment { get }
    var isDone: Bool { get }
    var type: String { get }
    var isDraft: Bool { get }
    var isDeleted: Bool { get }
    var featuredRelations: [String] { get }
    var isSelectType: Bool { get }
    var isSelectTemplate: Bool { get }
}


public extension BundledRelationsValueProvider {
    
    var name: String {
        stringValue(with: .name)
    }

    var snippet: String {
        stringValue(with: .snippet).replacedNewlinesWithSpaces
    }
    
    var iconEmoji: String {
        stringValue(with: .iconEmoji)
    }
    
    var iconImageHash: Hash? {
        guard let value = values[BundledRelationKey.iconImage.rawValue] else { return nil }
        return Hash(value.unwrapedListValue.stringValue)
    }
    
    var coverId: String {
        stringValue(with: .coverId)
    }
    
    var coverType: CoverType {
        guard
            let value = values[BundledRelationKey.coverType.rawValue],
            let number = value.unwrapedListValue.safeIntValue,
            let coverType = CoverType(rawValue: number)
        else { return .none }
        
        return coverType
    }
    
    var isArchived: Bool {
        boolValue(with: .isArchived)
    }
    
    var isFavorite: Bool {
        boolValue(with: .isFavorite)
    }
    
    var description: String {
        stringValue(with: .description)
    }
    
    var layout: DetailsLayout {
        guard
            let value = values[BundledRelationKey.layout.rawValue],
            let number = value.unwrapedListValue.safeIntValue,
            let layout = DetailsLayout(rawValue: number)
        else {
            return .basic
        }
        return layout
    }
    
    var layoutAlign: LayoutAlignment {
        guard
            let value = values[BundledRelationKey.layoutAlign.rawValue],
            let number = value.unwrapedListValue.safeIntValue,
            let layout = LayoutAlignment(rawValue: number)
        else {
            return .left
        }
        return layout
    }
    
    var isDone: Bool {
        boolValue(with: .done)
    }
    
    var type: String {
        stringValue(with: .type)
    }
    
    var isDraft: Bool {
        boolValue(with: .isDraft)
    }
    
    var isDeleted: Bool {
        boolValue(with: .isDeleted)
    }
    
    var featuredRelations: [String] {
        guard let value = values[BundledRelationKey.featuredRelations.rawValue] else { return [] }
        
        let ids: [String] = value.listValue.values.compactMap {
            let value = $0.stringValue
            guard value.isNotEmpty else { return nil }
            return value
        }
        
        return ids
    }
    
    var isSelectType: Bool {
        return internalFlag(with: .editorSelectType)
    }
    
    var isSelectTemplate: Bool {
        return internalFlag(with: .editorSelectTemplate)
    }
    
    // MARK: - Private
    
    private func stringValue(with key: BundledRelationKey) -> String {
        guard let value = values[key.rawValue] else { return "" }
        return value.unwrapedListValue.stringValue
    }
    
    private func boolValue(with key: BundledRelationKey) -> Bool {
        guard let value = values[key.rawValue] else { return false }
        return value.unwrapedListValue.boolValue
    }
    
    private func internalFlag(with flag: Anytype_Model_InternalFlag.Value) -> Bool {
        guard let value = values[BundledRelationKey.internalFlags.rawValue] else { return false }
        let rawValues = value.listValue.values
        let internalFlags = rawValues
            .compactMap { $0.safeIntValue }
            .compactMap { Anytype_Model_InternalFlag.Value(rawValue: $0) }
        return internalFlags.contains(flag)
    }
}
