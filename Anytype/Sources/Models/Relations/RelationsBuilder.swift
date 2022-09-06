import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationsBuilder {
    
    private let scope: [RelationMetadata.Scope]
    private let storage: ObjectDetailsStorage
    
    init(scope: [RelationMetadata.Scope] = [.object], storage: ObjectDetailsStorage = ObjectDetailsStorage.shared) {
        self.scope = scope
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
    
    // MARK: - Internal functions
    
    func parsedRelations(
        relationsDetails: [RelationDetails],
        objectId: BlockId,
        isObjectLocked: Bool
    ) -> ParsedRelations {
        guard
            let objectDetails = storage.get(id: objectId)
        else {
            return .empty
        }
        
        var featuredRelations: [Relation] = []
        var otherRelations: [Relation] = []
        
        relationsDetails.forEach { relationDetails in
            #warning("Fix scope")
            guard !relationDetails.isHidden else { return } // , scope.contains(relationMetadata.scope) else { return }
            
            let value = relation(
                relationDetails: relationDetails,
                details: objectDetails,
                isObjectLocked: isObjectLocked
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
    
    func relation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        switch relationDetails.format {
        case .longText:
            return textRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .shortText:
            return textRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .number:
            return numberRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .status:
            return statusRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .date:
            return dateRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .file:
            return fileRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .checkbox:
            return checkboxRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .url:
            return urlRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .email:
            return emailRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .phone:
            return phoneRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .tag:
            return tagRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .object:
            return objectRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .unrecognized:
            return .text(
                Relation.Text(
                    key: relationDetails.key,
                    name: relationDetails.name,
                    isFeatured: relationDetails.isFeatured(details: details),
                    isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                    isBundled: relationDetails.isBundled,
                    value: Loc.unsupportedValue
                )
            )
        }
    }
    
    func textRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .text(
            Relation.Text(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.values[relationDetails.key]?.stringValue
            )
        )
    }
    
    func numberRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let numberValue: String? = {
            let value = details.values[relationDetails.key]
            
            guard let number = value?.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            Relation.Text(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: numberValue
            )
        )
    }
    
    func phoneRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .phone(
            Relation.Text(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.values[relationDetails.key]?.stringValue
            )
        )
    }
    
    func emailRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .email(
            Relation.Text(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.values[relationDetails.key]?.stringValue
            )
        )
    }
    
    func urlRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .url(
            Relation.Text(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.values[relationDetails.key]?.stringValue
            )
        )
    }
    
    func statusRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        #warning("Fix options")
        let options: [Relation.Status.Option] = []
//        let options: [Relation.Status.Option] = relationDetails.selections.map {
//            Relation.Status.Option(option: $0)
//        }
        
        let selectedOption: Relation.Status.Option? = {
            let value = details.values[relationDetails.key]
            
            guard
                let optionId = value?.unwrapedListValue.stringValue, optionId.isNotEmpty
            else { return nil }
            
            return options.first { $0.id == optionId }
        }()
        var values = [Relation.Status.Option]()
        if let selectedOption = selectedOption {
            values.append(selectedOption)
        }
        return .status(
            Relation.Status(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                values: values,
                allOptions: options
            )
        )
    }
    
    func dateRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let value: DateRelationValue? = {
            let value = details.values[relationDetails.key]
            
            guard let timeInterval = value?.safeDoubleValue, !timeInterval.isZero
            else { return nil }
            
            let date = Date(timeIntervalSince1970: timeInterval)
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Relation.Date(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: value
            )
        )
    }
    
    func checkboxRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        .checkbox(
            Relation.Checkbox(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.values[relationDetails.key]?.boolValue ?? false
            )
        )
    }
    
    func tagRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        #warning("Fix tags list")
//        let tags: [Relation.Tag.Option] = relationDetails.selections.map { Relation.Tag.Option(option: $0) }
        let tags: [Relation.Tag.Option] = []
        
        let selectedTags: [Relation.Tag.Option] = {
            let value = details.values[relationDetails.key]
            guard let value = value else { return [] }
            
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
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                selectedTags: selectedTags,
                allTags: tags
            )
        )
    }
    
    func objectRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let objectOptions: [Relation.Object.Option] = {
            let value = details.values[relationDetails.key]
            guard let value = value else { return [] }
            
            let values: [Google_Protobuf_Value] = {
                if case let .listValue(listValue) = value.kind {
                    return listValue.values
                }
                
                return [value]
            }()
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0.stringValue)
            }

            let objectOptions: [Relation.Object.Option] = objectDetails.map { objectDetail in
                let name = objectDetail.title
                let icon: ObjectIconImage = {
                    if let objectIcon = objectDetail.objectIconImage {
                        return objectIcon
                    }
                    
                    return .placeholder(name.first)
                }()
                
                return Relation.Object.Option(
                    id: objectDetail.id,
                    icon: icon,
                    title: name,
                    type: objectDetail.objectType.name,
                    isArchived: objectDetail.isArchived,
                    isDeleted: objectDetail.isDeleted,
                    editorViewType: objectDetail.editorViewType
                )
            }
            
            return objectOptions
        }()
        
        #warning("Check object type")
        return .object(
            Relation.Object(
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                selectedObjects: objectOptions,
                limitedObjectTypes: relationDetails.objectTypes
            )
        )
    }
    
    func fileRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let fileOptions: [Relation.File.Option] = {
            let value = details.values[relationDetails.key]
            guard let value = value else { return [] }
            
            let objectDetails: [ObjectDetails] = value.listValue.values.compactMap {
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
                        return .imageAsset(FileIconConstants.other)
                    }
                    
                    return .imageAsset(BlockFileIconBuilder.convert(mime: fileMimeType, fileName: fileName))
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
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                files: fileOptions
            )
        )
    }
    
}

extension RelationMetadata.Format {
    
    var hint: String {
        switch self {
        case .longText:
            return Loc.enterText
        case .shortText:
            return Loc.enterText
        case .number:
            return Loc.enterNumber
        case .date:
            return Loc.enterDate
        case .url:
            return Loc.enterURL
        case .email:
            return Loc.enterEMail
        case .phone:
            return Loc.enterPhone
        case .status:
            return Loc.selectStatus
        case .tag:
            return Loc.selectTags
        case .file:
            return Loc.selectFiles
        case .object:
            return Loc.selectObjects
        case .checkbox:
            return ""
        case .unrecognized:
            return Loc.enterValue
        }
    }
    
}

//private extension RelationMetadata {
//
//    func isFeatured(details: ObjectDetails) -> Bool {
//        details.featuredRelations.contains(self.id)
//    }
//
//    func isEditable(objectLocked: Bool) -> Bool {
//        guard !objectLocked else { return false }
//
//        return !self.isReadOnly
//    }
//
//}

private extension RelationDetails {
    
    func isFeatured(details: ObjectDetails) -> Bool {
        details.featuredRelations.contains(key)
    }
    
    func isEditable(objectLocked: Bool) -> Bool {
        guard !objectLocked else { return false }
        
        return !self.isReadOnlyValue
    }
}

#warning("Move to different file")
extension RelationDetails {
    var isBundled: Bool {
        guard let keyType = BundledRelationKey(rawValue: key) else { return false }
        return BundledRelationKey.notRemovableRelationKeys.contains(keyType)
    }
}
