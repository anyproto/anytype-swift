import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationsBuilder {
    
    private let scope: [Relation.Scope]
    private let storage: ObjectDetailsStorage
    
    init(scope: [Relation.Scope] = [.object], storage: ObjectDetailsStorage = ObjectDetailsStorage.shared) {
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
        relations: [Relation],
        objectId: BlockId,
        isObjectLocked: Bool
    ) -> ParsedRelations {
        guard
            let objectDetails = storage.get(id: objectId)
        else {
            return .empty
        }
        
        var featuredRelationValues: [RelationValue] = []
        var otherRelationValues: [RelationValue] = []
        
        relations.forEach { relation in
            #warning("Fix scope")
            guard !relation.isHidden else { return } // , scope.contains(relationMetadata.scope) else { return }
            
            let value = relationValue(
                relation: relation,
                details: objectDetails,
                isObjectLocked: isObjectLocked
            )
            
            if value.isFeatured {
                featuredRelationValues.append(value)
            } else {
                otherRelationValues.append(value)
            }
        }
        
        return ParsedRelations(featuredRelationValues: featuredRelationValues, otherRelationValues: otherRelationValues)
    }
    
}

// MARK: - Private extension

private extension RelationsBuilder {
    
    func relationValue(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        switch relation.format {
        case .longText:
            return textRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .shortText:
            return textRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .number:
            return numberRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .status:
            return statusRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .date:
            return dateRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .file:
            return fileRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .checkbox:
            return checkboxRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .url:
            return urlRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .email:
            return emailRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .phone:
            return phoneRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .tag:
            return tagRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .object:
            return objectRelation(
                relation: relation,
                details: details,
                isObjectLocked: isObjectLocked
            )
        case .unrecognized:
            return .text(
                RelationValue.Text(
                    id: relation.id,
                    key: relation.key,
                    name: relation.name,
                    isFeatured: relation.isFeatured(details: details),
                    isEditable: relation.isEditable(objectLocked: isObjectLocked),
                    isBundled: relation.isBundled,
                    value: Loc.unsupportedValue
                )
            )
        }
    }
    
    func textRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        .text(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func numberRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        let numberValue: String? = {
            let value = details.values[relation.key]
            
            guard let number = value?.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                value: numberValue
            )
        )
    }
    
    func phoneRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        .phone(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func emailRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        .email(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func urlRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        .url(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                value: details.values[relation.key]?.stringValue
            )
        )
    }
    
    func statusRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        #warning("Fix options")
        
        let selectedOption: RelationValue.Status.Option? = {
            let value = details.values[relation.key]
            
            guard
                let optionId = value?.unwrapedListValue.stringValue, optionId.isNotEmpty
            else { return nil }
            
            guard let optionDetails = storage.get(id: optionId) else { return nil }
            let option = RelationOption(details: optionDetails)
            return RelationValue.Status.Option(option: option)
        }()
        var values = [RelationValue.Status.Option]()
        if let selectedOption = selectedOption {
            values.append(selectedOption)
        }
        return .status(
            RelationValue.Status(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                values: values
            )
        )
    }
    
    func dateRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        let value: DateRelationValue? = {
            let value = details.values[relation.key]
            
            guard let timeInterval = value?.safeDoubleValue, !timeInterval.isZero
            else { return nil }
            
            let date = Date(timeIntervalSince1970: timeInterval)
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            RelationValue.Date(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                value: value
            )
        )
    }
    
    func checkboxRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        .checkbox(
            RelationValue.Checkbox(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                value: details.values[relation.key]?.boolValue ?? false
            )
        )
    }
    
    func tagRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        #warning("Check tags list")
        
        let selectedTags: [RelationValue.Tag.Option] = {
            let value = details.values[relation.key]
            guard let value = value else { return [] }
            
            let selectedTagIds: [String] = value.listValue.values.compactMap {
                let tagId = $0.stringValue
                return tagId.isEmpty ? nil : tagId
            }
            
            let tags = selectedTagIds
                .compactMap { storage.get(id: $0) }
                .map { RelationOption(details: $0) }
                .map { RelationValue.Tag.Option(option: $0) }
            
            return tags
        }()
        
        return .tag(
            RelationValue.Tag(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                selectedTags: selectedTags
            )
        )
    }
    
    func objectRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        let objectOptions: [RelationValue.Object.Option] = {
            let value = details.values[relation.key]
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

            let objectOptions: [RelationValue.Object.Option] = objectDetails.map { objectDetail in
                let name = objectDetail.title
                let icon: ObjectIconImage = {
                    if let objectIcon = objectDetail.objectIconImage {
                        return objectIcon
                    }
                    
                    return .placeholder(name.first)
                }()
                
                return RelationValue.Object.Option(
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
        
        return .object(
            RelationValue.Object(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                selectedObjects: objectOptions,
                limitedObjectTypes: relation.objectTypes
            )
        )
    }
    
    func fileRelation(
        relation: Relation,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        let fileOptions: [RelationValue.File.Option] = {
            let value = details.values[relation.key]
            guard let value = value else { return [] }
            
            let objectDetails: [ObjectDetails] = value.listValue.values.compactMap {
                return storage.get(id: $0.stringValue)
            }

            let objectOptions: [RelationValue.File.Option] = objectDetails.map { objectDetail in
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
                
                return RelationValue.File.Option(
                    id: objectDetail.id,
                    icon: icon,
                    title: fileName
                )
            }
            
            return objectOptions
        }()
        
        return .file(
            RelationValue.File(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: relation.isFeatured(details: details),
                isEditable: relation.isEditable(objectLocked: isObjectLocked),
                isBundled: relation.isBundled,
                files: fileOptions
            )
        )
    }
    
}

extension RelationFormat {
    
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

private extension Relation {
    
    func isFeatured(details: ObjectDetails) -> Bool {
        details.featuredRelations.contains(key)
    }
    
    func isEditable(objectLocked: Bool) -> Bool {
        guard !objectLocked else { return false }
        
        return !self.isReadOnlyValue
    }
}
