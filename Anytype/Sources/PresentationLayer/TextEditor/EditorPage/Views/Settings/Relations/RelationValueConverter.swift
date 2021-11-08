import Foundation
import SwiftProtobuf
import BlocksModels
import SwiftUI

enum RelationValueConverter {
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    static func dateString(from value: Google_Protobuf_Value?) -> String? {
        guard let number = value?.safeDoubleValue else { return nil }
        
        let date = Date(timeIntervalSince1970: number)
        
        return dateFormatter.string(from: date)
    }
    
    static func numberString(from value: Google_Protobuf_Value?) -> String? {
        guard let number = value?.safeIntValue else { return nil }
        
        return String(number)
    }
    
    static func status(from value: Google_Protobuf_Value?, selections: [Relation.Option]) -> StatusRelation? {
        guard
            let optionId = value?.unwrapedListValue.stringValue, optionId.isNotEmpty
        else { return nil }
        
        let option: Relation.Option? = selections.first { $0.id == optionId }

        guard let option = option else { return nil }
        
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        let anytypeColor: AnytypeColor = middlewareColor?.asDarkColor ?? .grayscale90

        return StatusRelation(
            text: option.text,
            color: anytypeColor
        )
    }
    
    static func tags(from value: Google_Protobuf_Value?, selections: [Relation.Option]) -> [TagRelation] {
        guard let value = value else { return [] }

        let selectedTagIds: [String] = value.listValue.values.compactMap {
            let tagId = $0.stringValue
            return tagId.isEmpty ? nil : tagId
        }
        
        let options: [Relation.Option] = selections.filter {
            selectedTagIds.contains($0.id)
        }
        
        let tags: [TagRelation] = options.map {
            TagRelation(
                text: $0.text,
                textColor: MiddlewareColor(rawValue: $0.color)?.asDarkColor ?? .grayscale90,
                backgroundColor: MiddlewareColor(rawValue: $0.color)?.asLightColor ?? .grayscaleWhite
            )
        }
        
        return tags
    }
    
}
