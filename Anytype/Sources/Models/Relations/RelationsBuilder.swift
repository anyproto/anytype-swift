import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationsBuilder {

    // MARK: - Private variables
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    // MARK: - Internal functions
    
    func buildRelations(
        using relations: [RelationMetadata],
        objectId: BlockId,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> ParsedRelations {
        guard let objectDetails = detailsStorage.get(id: objectId) else {
            return ParsedRelations(featuredRelations: [], otherRelations: [])
        }
        
        var featuredRelations: [Relation] = []
        var otherRelations: [Relation] = []
        
        let featuredRelationIds = objectDetails.featuredRelations
        relations.forEach { relation in
            guard !relation.isHidden, relation.scope == .object else { return }
            
            let value = relationValue(
                relation: relation,
                details: objectDetails,
                detailsStorage: detailsStorage
            )
            
            let relationData = Relation(
                id: relation.id,
                name: relation.name,
                value: value,
                hint: relation.format.hint,
                isFeatured: featuredRelationIds.contains(relation.id),
                isEditable: !relation.isReadOnly
            )
            
            if relationData.isFeatured {
                featuredRelations.append(relationData)
            } else {
                otherRelations.append(relationData)
            }
        }
        
        return ParsedRelations(featuredRelations: featuredRelations, otherRelations: otherRelations)
    }
    
}

// MARK: - Private extension

private extension RelationsBuilder {
    
    func relationValue(
        relation: RelationMetadata,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> RelationValue {
        switch relation.format {
        case .longText:
            return textRelationValue(relation: relation, details: details)
        case .shortText:
            return textRelationValue(relation: relation, details: details)
        case .number:
            return numberRelationValue(relation: relation, details: details)
        case .status:
            return statusRelationValue(relation: relation, details: details)
        case .date:
            return dateRelationValue(relation: relation, details: details)
        case .file:
            return fileRelationValue(relation: relation, details: details, detailsStorage: detailsStorage)
        case .checkbox:
            return checkboxRelationValue(relation: relation, details: details)
        case .url:
            return textRelationValue(relation: relation, details: details)
        case .email:
            return textRelationValue(relation: relation, details: details)
        case .phone:
            return textRelationValue(relation: relation, details: details)
        case .tag:
            return tagRelationValue(relation: relation, details: details)
        case .object:
            return objectRelationValue(relation: relation, details: details, detailsStorage: detailsStorage)
        case .unrecognized:
            return .text("Unsupported value".localized)
        }
    }
    
    func textRelationValue(relation: RelationMetadata, details: ObjectDetails) -> RelationValue {
        let value = details.values[relation.key]
        let text: String? = value?.stringValue
        
        return .text(text)
    }
    
    func numberRelationValue(relation: RelationMetadata, details: ObjectDetails) -> RelationValue {
        let value = details.values[relation.key]
        
        guard let number = value?.safeDoubleValue else {
            return .number(nil)
        }
        
        let text: String? = numberFormatter.string(from: NSNumber(floatLiteral: number))
        return .number(text)
    }
    
    func statusRelationValue(relation: RelationMetadata, details: ObjectDetails) -> RelationValue {
        let value = details.values[relation.key]
        
        guard
            let optionId = value?.unwrapedListValue.stringValue, optionId.isNotEmpty
        else { return .status(nil) }
        
        let option: RelationMetadata.Option? = relation.selections.first { $0.id == optionId }

        guard let option = option else { return .status(nil) }
        
        let middlewareColor = MiddlewareColor(rawValue: option.color)
        let anytypeColor: AnytypeColor = middlewareColor?.asDarkColor ?? .grayscale90
        
        return .status(
            StatusRelation(
                text: option.text,
                color: anytypeColor
            )
        )
    }
    
    func dateRelationValue(relation: RelationMetadata, details: ObjectDetails) -> RelationValue {
        let value = details.values[relation.key]
        
        guard let number = value?.safeDoubleValue else { return .text(nil) }
        
        let date = Date(timeIntervalSince1970: number)
        
        return .text(dateFormatter.string(from: date))
    }
    
    func checkboxRelationValue(relation: RelationMetadata, details: ObjectDetails) -> RelationValue {
        let value = details.values[relation.key]
        
        return .checkbox(value?.boolValue ?? false)
    }
    
    func tagRelationValue(relation: RelationMetadata, details: ObjectDetails) -> RelationValue {
        let value = details.values[relation.key]
        guard let value = value else { return .tag([]) }

        let selectedTagIds: [String] = value.listValue.values.compactMap {
            let tagId = $0.stringValue
            return tagId.isEmpty ? nil : tagId
        }
        
        let options: [RelationMetadata.Option] = relation.selections.filter {
            selectedTagIds.contains($0.id)
        }
        
        let tags: [TagRelation] = options.map {
            TagRelation(
                text: $0.text,
                textColor: MiddlewareColor(rawValue: $0.color)?.asDarkColor ?? .grayscale90,
                backgroundColor: MiddlewareColor(rawValue: $0.color)?.asLightColor ?? .grayscaleWhite
            )
        }
        
        return .tag(tags)
    }
    
    func objectRelationValue(
        relation: RelationMetadata,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> RelationValue {
        let value = details.values[relation.key]
        guard let value = value else { return .object([]) }
        
        let values: [Google_Protobuf_Value] = {
            if case let .listValue(listValue) = value.kind {
                return listValue.values
            }
            
            return [value]
        }()
        
        let objectDetails: [ObjectDetails] = values.compactMap {
            let objectId = $0.stringValue
            guard objectId.isNotEmpty else { return nil }
            let objectDetails = detailsStorage.get(id: objectId)
            return objectDetails
        }

        let objectRelations: [ObjectRelation] = objectDetails.map { objectDetail in
            let name = objectDetail.name
            let icon: ObjectIconImage = {
                if let objectIcon = objectDetail.objectIconImage {
                    return objectIcon
                }
                
                return .placeholder(name.first)
            }()
            
            return ObjectRelation(icon: icon, text: name)
        }
        
        
        return .object(objectRelations)
    }
    
    func fileRelationValue(
        relation: RelationMetadata,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> RelationValue {
        let value = details.values[relation.key]
        guard let value = value else { return .object([]) }
        
        let objectDetails: [ObjectDetails] = value.listValue.values.compactMap {
            let objectId = $0.stringValue
            guard objectId.isNotEmpty else { return nil }
            
            let objectDetails = detailsStorage.get(id: objectId)
            return objectDetails
        }

        let objectRelations: [ObjectRelation] = objectDetails.map { objectDetail in
            let fileName: String = {
                let name = objectDetail.name
                let fileExt = objectDetail.values[BundledRelationKey.fileExt.rawValue]
                let fileExtString = fileExt?.stringValue
                
                guard
                    let fileExtString = fileExtString, fileExtString.isNotEmpty
                else { return name }
                
                return "\(name).\(fileExtString)"
            }()
            
            let icon: ObjectIconImage = {
                if let objectIconType = objectDetail.icon {
                    return .icon(objectIconType)
                }
                
                let fileMimeType = objectDetail.values[BundledRelationKey.fileMimeType.rawValue]?.stringValue
                guard let fileMimeType = fileMimeType else {
                    return .image(UIImage.blockFile.content.other)
                }
                
                return .image(BlockFileIconBuilder.convert(mime: fileMimeType))
            }()
            
            return ObjectRelation(icon: icon, text: fileName)
        }
        
        return .object(objectRelations)
    }
    
}

extension RelationMetadata.Format {
    
    var hint: String {
        switch self {
        case .longText:
            return "Enter text".localized
        case .shortText:
            return "Enter text".localized
        case .number:
            return "Enter number".localized
        case .date:
            return "Enter date".localized
        case .url:
            return "Enter URL".localized
        case .email:
            return "Enter e-mail".localized
        case .phone:
            return "Enter phone".localized
        case .status:
            return "Select status".localized
        case .tag:
            return "Select tags".localized
        case .file:
            return "Select files".localized
        case .object:
            return "Select objects".localized
        case .checkbox:
            return ""
        case .unrecognized:
            return "Enter value".localized
        }
    }
    
}
