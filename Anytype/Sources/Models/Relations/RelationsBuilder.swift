import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class RelationsBuilder {
    
    private let scope: [RelationDetails.Scope]
    private let storage: ObjectDetailsStorage
    
    init(scope: [RelationDetails.Scope] = [.object, .type], storage: ObjectDetailsStorage = ObjectDetailsStorage.shared) {
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
        
        var featuredRelationValues: [RelationValue] = []
        var otherRelationValues: [RelationValue] = []
        
        relationsDetails.forEach { relationDetails in
            #warning("Fix scope")
            guard !relationDetails.isHidden else { return } // , scope.contains(relationMetadata.scope) else { return }
            
            let value = relationValue(
                relationDetails: relationDetails,
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
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
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
                RelationValue.Text(
                    id: relationDetails.id,
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
    ) -> RelationValue {
        .text(
            RelationValue.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func numberRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        let numberValue: String? = {
            guard let number = details.doubleValue(for: relationDetails.key) else { return nil }
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            RelationValue.Text(
                id: relationDetails.id,
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
    ) -> RelationValue {
        .phone(
            RelationValue.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func emailRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        .email(
            RelationValue.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func urlRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        .url(
            RelationValue.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func statusRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        #warning("Fix options")
        
        let selectedOption: RelationValue.Status.Option? = {
            let optionId = details.stringValue(for: relationDetails.key)
            
            guard optionId.isNotEmpty else { return nil }
            
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
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                values: values
            )
        )
    }
    
    func dateRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        let value: DateRelationValue? = {
            guard let date = details.dateValue(for: relationDetails.key) else { return nil }
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            RelationValue.Date(
                id: relationDetails.id,
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
    ) -> RelationValue {
        .checkbox(
            RelationValue.Checkbox(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                value: details.boolValue(for: relationDetails.key)
            )
        )
    }
    
    func tagRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        #warning("Check tags list")
        
        let selectedTags: [RelationValue.Tag.Option] = {
            let selectedTagIds = details.stringArrayValue(for: relationDetails.key)
            
            let tags = selectedTagIds
                .compactMap { storage.get(id: $0) }
                .map { RelationOption(details: $0) }
                .map { RelationValue.Tag.Option(option: $0) }

            return tags
        }()
        
        return .tag(
            RelationValue.Tag(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                isBundled: relationDetails.isBundled,
                selectedTags: selectedTags
            )
        )
    }
    
    func objectRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> RelationValue {
        let objectOptions: [RelationValue.Object.Option] = {
            let values = details.stringArrayValue(for: relationDetails.key)
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0)
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
                id: relationDetails.id,
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
    ) -> RelationValue {
        let fileOptions: [RelationValue.File.Option] = {
            let values = details.stringArrayValue(for: relationDetails.key)
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0)
            }

            let objectOptions: [RelationValue.File.Option] = objectDetails.map { objectDetail in
                let fileName: String = {
                    let name = objectDetail.name
                    let fileExt = objectDetail.fileExt
                    
                    guard fileExt.isNotEmpty
                    else { return name }
                    
                    return "\(name).\(fileExt)"
                }()
                
                let icon: ObjectIconImage = {
                    if let objectIconType = objectDetail.icon {
                        return .icon(objectIconType)
                    }
                    
                    let fileMimeType = objectDetail.fileMimeType
                    let fileName = objectDetail.name

                    guard fileMimeType.isNotEmpty, fileName.isNotEmpty else {
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
                id: relationDetails.id,
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

private extension RelationDetails {
    
    func isFeatured(details: ObjectDetails) -> Bool {
        details.featuredRelations.contains(key)
    }
    
    func isEditable(objectLocked: Bool) -> Bool {
        guard !objectLocked else { return false }

        if id == BundledRelationKey.setOf.rawValue { return true }

        return !self.isReadOnlyValue
    }
}
