import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationFilterBuilder {
    
    private let storage: ObjectDetailsStorage
    
    init(storage: ObjectDetailsStorage = ObjectDetailsStorage.shared) {
        self.storage = storage
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
    
    func relation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        switch metadata.format {
        case .object:
            return objectRelation(
                metadata: metadata,
                filter: filter
            )
        case .longText, .shortText:
            return textRelation(
                metadata: metadata,
                filter: filter
            )
        case .number:
            return numberRelation(
                metadata: metadata,
                filter: filter
            )
        case .status:
            return statusRelation(
                metadata: metadata,
                filter: filter
            )
        case .date:
            return dateRelation(
                metadata: metadata,
                filter: filter
            )
        case .file:
            return fileRelation(
                metadata: metadata,
                filter: filter
            )
        case .checkbox:
            return checkboxRelation(
                metadata: metadata,
                filter: filter
            )
        case .url:
            return urlRelation(
                metadata: metadata,
                filter: filter
            )
        case .email:
            return emailRelation(
                metadata: metadata,
                filter: filter
            )
        case .phone:
            return phoneRelation(
                metadata: metadata,
                filter: filter
            )
        case .tag:
            return tagRelation(
                metadata: metadata,
                filter: filter
            )
        default:
            return .text(
                Relation.Text(
                    id: metadata.id,
                    name: metadata.name,
                    isFeatured: false,
                    isEditable: false,
                    isBundled: metadata.isBundled,
                    value: "Unsupported value".localized
                )
            )
        }
    }
}

private extension RelationFilterBuilder {
    func objectRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        let objectOptions: [Relation.Object.Option] = {
            let values: [Google_Protobuf_Value] = {
                if case let .listValue(listValue) = filter.value.kind {
                    return listValue.values
                }
                
                return [filter.value]
            }()
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0.stringValue)
            }

            let objectOptions: [Relation.Object.Option] = objectDetails.map { objectDetail in
                let name = objectDetail.title
                let icon: ObjectIconImage = {
                    if let objectIcon = objectDetail.objectIconImage {
                        return objectIcon
                    } else {
                        return .placeholder(name.first)
                    }
                }()
                
                return Relation.Object.Option(
                    id: objectDetail.id,
                    icon: icon,
                    title: name,
                    type: objectDetail.objectType.name,
                    isArchived: objectDetail.isArchived,
                    isDeleted: objectDetail.isDeleted
                )
            }
            
            return objectOptions
        }()
        
        return .object(
            Relation.Object(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                selectedObjects: objectOptions,
                limitedObjectTypes: metadata.objectTypes
            )
        )
    }
    
    func textRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        .text(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func numberRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        let numberValue: String? = {
            guard let number = filter.value.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: "“\(numberValue ?? "")“"
            )
        )
    }
    
    func phoneRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        .phone(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func emailRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        .email(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func urlRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        .url(
            Relation.Text(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func statusRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        let options: [Relation.Status.Option] = metadata.selections.map {
            Relation.Status.Option(option: $0)
        }
        
        let selectedOption: Relation.Status.Option? = {
            let optionId = filter.value.unwrapedListValue.stringValue
            guard optionId.isNotEmpty else { return nil }
            
            return options.first { $0.id == optionId }
        }()
        
        return .status(
            Relation.Status(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: selectedOption,
                allOptions: options
            )
        )
    }
    
    func tagRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        let tags: [Relation.Tag.Option] = metadata.selections.map { Relation.Tag.Option(option: $0) }
        
        let selectedTags: [Relation.Tag.Option] = {
            let value = filter.value
            
            let selectedTagIds: [String] = value.listValue.values.compactMap {
                let tagId = $0.stringValue
                return tagId.isEmpty ? nil : tagId
            }
            
            return selectedTagIds.compactMap { id in
                tags.first { $0.id == id }
            }
        }()
        
        return .tag(
            Relation.Tag(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                selectedTags: selectedTags,
                allTags: tags
            )
        )
    }
    
    func fileRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        let fileOptions: [Relation.File.Option] = {
            let objectDetails: [ObjectDetails] = filter.value.listValue.values.compactMap {
                return storage.get(id: $0.stringValue)
            }

            let objectOptions: [Relation.File.Option] = objectDetails.map { objectDetail in
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
                        return .staticImage(FileIconConstants.other)
                    }
                    
                    return .staticImage(BlockFileIconBuilder.convert(mime: fileMimeType, fileName: fileName))
                }()
                
                return Relation.File.Option(
                    id: objectDetail.id,
                    icon: icon,
                    title: fileName
                )
            }
            
            return objectOptions
        }()
        
        return .file(
            Relation.File(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                files: fileOptions
            )
        )
    }
    
    func dateRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        let value: DateRelationValue? = {
            guard let timeInterval = filter.value.safeDoubleValue, !timeInterval.isZero
            else { return nil }
            
            let date = Date(timeIntervalSince1970: timeInterval)
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Relation.Date(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: value
            )
        )
    }
    
    func checkboxRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation {
        .checkbox(
            Relation.Checkbox(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                value: filter.value.boolValue
            )
        )
    }
}
