import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationsBuilder {
    
    private let scope: RelationMetadata.Scope
    
    init(scope: RelationMetadata.Scope = .object) {
        self.scope = scope
    }

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
            return .empty
        }
        
        var featuredRelations: [Relation] = []
        var otherRelations: [Relation] = []
        
        relations.forEach { relation in
            guard !relation.isHidden, relation.scope == scope else { return }
            
            let value = relationValue(
                relation: relation,
                details: objectDetails,
                detailsStorage: detailsStorage
            )
            
            if value.isFeatured {
                featuredRelations.append(value)
            } else {
                otherRelations.append(value)
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
    ) -> Relation {
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
            return urlRelationValue(relation: relation, details: details)
        case .email:
            return emailRelationValue(relation: relation, details: details)
        case .phone:
            return phoneRelationValue(relation: relation, details: details)
        case .tag:
            return tagRelationValue(relation: relation, details: details)
        case .object:
            return objectRelationValue(relation: relation, details: details, detailsStorage: detailsStorage)
        case .unrecognized:
            return .text(
                Relation.Text(
                    id: relation.id,
                    name: relation.name,
                    isFeatured: details.featuredRelations.contains(relation.id),
                    isEditable: !relation.isReadOnly,
                    value: "Unsupported value".localized
                )
            )
        }
    }
    
    func textRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        .text(
            Relation.Text(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func numberRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        let numberValue: String? = {
            let value = details.values[relation.key]
            
            guard let number = value?.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            Relation.Text(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: numberValue
            )
        )
    }
    
    func phoneRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        .phone(
            Relation.Text(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func emailRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        .email(
            Relation.Text(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func urlRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        .url(
            Relation.Text(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func statusRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        let options: [Relation.Status.Option] = relation.selections.map {
            Relation.Status.Option(option: $0)
        }
        
        let selectedOption: Relation.Status.Option? = {
            let value = details.values[relation.key]
            
            guard
                let optionId = value?.unwrapedListValue.stringValue, optionId.isNotEmpty
            else { return nil }
            
            return options.first { $0.id == optionId }
        }()
        
        return .status(
            Relation.Status(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: selectedOption,
                allOptions: options
            )
        )
    }
    
    func dateRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        let value: DateRelationValue? = {
            let value = details.values[relation.key]
            
            guard let timeInterval = value?.safeDoubleValue, !timeInterval.isZero
            else { return nil }
            
            let date = Date(timeIntervalSince1970: timeInterval)
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Relation.Date(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: value
            )
        )
    }
    
    func checkboxRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        .checkbox(
            Relation.Checkbox(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: details.values[relation.key]?.boolValue ?? false
            )
        )
    }
    
    func tagRelationValue(relation: RelationMetadata, details: ObjectDetails) -> Relation {
        let tags: [TagRelationValue] = {
            let value = details.values[relation.key]
            guard let value = value else { return [] }

            let selectedTagIds: [String] = value.listValue.values.compactMap {
                let tagId = $0.stringValue
                return tagId.isEmpty ? nil : tagId
            }
            
            let options: [RelationMetadata.Option] = relation.selections.filter {
                selectedTagIds.contains($0.id)
            }
            
            let tags: [TagRelationValue] = options.map {
                TagRelationValue(
                    text: $0.text,
                    textColor: MiddlewareColor(rawValue: $0.color)?.asDarkColor ?? .grayscale90,
                    backgroundColor: MiddlewareColor(rawValue: $0.color)?.asLightColor ?? .grayscaleWhite
                )
            }
            
            return tags
        }()
        
        return .tag(
            Relation.Tag(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: tags
            )
        )
    }
    
    func objectRelationValue(
        relation: RelationMetadata,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> Relation {
        let objectRelations: [ObjectRelationValue] = {
            let value = details.values[relation.key]
            guard let value = value else { return [] }
            
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

            let objectRelations: [ObjectRelationValue] = objectDetails.map { objectDetail in
                let name = objectDetail.name
                let icon: ObjectIconImage = {
                    if let objectIcon = objectDetail.objectIconImage {
                        return objectIcon
                    }
                    
                    return .placeholder(name.first)
                }()
                
                return ObjectRelationValue(icon: icon, text: name)
            }
            
            return objectRelations
        }()
        
        return .object(
            Relation.Object(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: objectRelations
            )
        )
    }
    
    func fileRelationValue(
        relation: RelationMetadata,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> Relation {
        let objectRelations: [ObjectRelationValue] = {
            let value = details.values[relation.key]
            guard let value = value else { return [] }
            
            let objectDetails: [ObjectDetails] = value.listValue.values.compactMap {
                let objectId = $0.stringValue
                guard objectId.isNotEmpty else { return nil }
                
                let objectDetails = detailsStorage.get(id: objectId)
                return objectDetails
            }

            let objectRelations: [ObjectRelationValue] = objectDetails.map { objectDetail in
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
                    let fileName = objectDetail.values[BundledRelationKey.name.rawValue]?.stringValue

                    guard let fileMimeType = fileMimeType, let fileName = fileName else {
                        return .image(UIImage.blockFile.content.other)
                    }
                    
                    return .image(BlockFileIconBuilder.convert(mime: fileMimeType, fileName: fileName))
                }()
                
                return ObjectRelationValue(icon: icon, text: fileName)
            }
            
            return objectRelations
        }()
        
        return .object(
            Relation.Object(
                id: relation.id,
                name: relation.name,
                isFeatured: details.featuredRelations.contains(relation.id),
                isEditable: !relation.isReadOnly,
                value: objectRelations
            )
        )
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
