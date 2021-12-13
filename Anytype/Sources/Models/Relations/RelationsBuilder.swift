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
    
    func parsedRelations(
        relationMetadatas: [RelationMetadata],
        objectId: BlockId,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> ParsedRelations {
        guard let objectDetails = detailsStorage.get(id: objectId) else {
            return .empty
        }
        
        var featuredRelations: [Relation] = []
        var otherRelations: [Relation] = []
        
        relationMetadatas.forEach { relationMetadata in
            guard !relationMetadata.isHidden, relationMetadata.scope == scope else { return }
            
            let value = relation(
                relationMetadata: relationMetadata,
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
    
    func relation(relationMetadata: RelationMetadata, details: ObjectDetails, detailsStorage: ObjectDetailsStorageProtocol) -> Relation {
        switch relationMetadata.format {
        case .longText:
            return textRelation(metadata: relationMetadata, details: details)
        case .shortText:
            return textRelation(metadata: relationMetadata, details: details)
        case .number:
            return numberRelation(metadata: relationMetadata, details: details)
        case .status:
            return statusRelation(metadata: relationMetadata, details: details)
        case .date:
            return dateRelation(metadata: relationMetadata, details: details)
        case .file:
            return fileRelation(metadata: relationMetadata, details: details, detailsStorage: detailsStorage)
        case .checkbox:
            return checkboxRelation(metadata: relationMetadata, details: details)
        case .url:
            return urlRelation(metadata: relationMetadata, details: details)
        case .email:
            return emailRelation(metadata: relationMetadata, details: details)
        case .phone:
            return phoneRelation(metadata: relationMetadata, details: details)
        case .tag:
            return tagRelation(metadata: relationMetadata, details: details)
        case .object:
            return objectRelation(metadata: relationMetadata, details: details, detailsStorage: detailsStorage)
        case .unrecognized:
            return .text(
                Relation.Text(
                    id: relationMetadata.id,
                    name: relationMetadata.name,
                    isFeatured: details.featuredRelations.contains(relationMetadata.id),
                    isEditable: !relationMetadata.isReadOnly,
                    value: "Unsupported value".localized
                )
            )
        }
    }
    
    func textRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        .text(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: details.values[metadata.key]?.stringValue
            )
        )
    }
    
    func numberRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        let numberValue: String? = {
            let value = details.values[metadata.key]
            
            guard let number = value?.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: numberValue
            )
        )
    }
    
    func phoneRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        .phone(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: details.values[metadata.key]?.stringValue
            )
        )
    }
    
    func emailRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        .email(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: details.values[metadata.key]?.stringValue
            )
        )
    }
    
    func urlRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        .url(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: details.values[metadata.key]?.stringValue
            )
        )
    }
    
    func statusRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        let options: [Relation.Status.Option] = metadata.selections.map {
            Relation.Status.Option(option: $0)
        }
        
        let selectedOption: Relation.Status.Option? = {
            let value = details.values[metadata.key]
            
            guard
                let optionId = value?.unwrapedListValue.stringValue, optionId.isNotEmpty
            else { return nil }
            
            return options.first { $0.id == optionId }
        }()
        
        return .status(
            Relation.Status(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: selectedOption,
                allOptions: options
            )
        )
    }
    
    func dateRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        let value: DateRelationValue? = {
            let value = details.values[metadata.key]
            
            guard let timeInterval = value?.safeDoubleValue, !timeInterval.isZero
            else { return nil }
            
            let date = Date(timeIntervalSince1970: timeInterval)
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Relation.Date(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: value
            )
        )
    }
    
    func checkboxRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        .checkbox(
            Relation.Checkbox(
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: details.values[metadata.key]?.boolValue ?? false
            )
        )
    }
    
    func tagRelation(metadata: RelationMetadata, details: ObjectDetails) -> Relation {
        let tags: [TagRelationValue] = {
            let value = details.values[metadata.key]
            guard let value = value else { return [] }

            let selectedTagIds: [String] = value.listValue.values.compactMap {
                let tagId = $0.stringValue
                return tagId.isEmpty ? nil : tagId
            }
            
            let options: [RelationMetadata.Option] = metadata.selections.filter {
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
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: tags
            )
        )
    }
    
    func objectRelation(
        metadata: RelationMetadata,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> Relation {
        let objectRelations: [ObjectRelationValue] = {
            let value = details.values[metadata.key]
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
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
                value: objectRelations
            )
        )
    }
    
    func fileRelation(
        metadata: RelationMetadata,
        details: ObjectDetails,
        detailsStorage: ObjectDetailsStorageProtocol
    ) -> Relation {
        let objectRelations: [ObjectRelationValue] = {
            let value = details.values[metadata.key]
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
                id: metadata.id,
                name: metadata.name,
                isFeatured: details.featuredRelations.contains(metadata.id),
                isEditable: !metadata.isReadOnly,
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
