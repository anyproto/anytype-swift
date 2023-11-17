import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

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
    
    func parsedRelations(
        relationsDetails: [RelationDetails],
        typeRelationsDetails: [RelationDetails],
        objectId: BlockId,
        isObjectLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> ParsedRelations {
        guard
            let objectDetails = storage.get(id: objectId)
        else {
            return .empty
        }
        
        var featuredRelations: [Relation] = []
        var deletedRelations: [Relation] = []
        var otherRelations: [Relation] = []
        
        relationsDetails.forEach { relationDetails in
            guard !relationDetails.isHidden else { return }
            
            let value = relation(
                relationDetails: relationDetails,
                details: objectDetails,
                isObjectLocked: isObjectLocked,
                storage: storage
            )
            
            if value.isFeatured {
                featuredRelations.append(value)
            } else if value.isDeleted {
                deletedRelations.append(value)
            } else {
                otherRelations.append(value)
            }
        }
        
        let typeRelations: [Relation] = typeRelationsDetails.compactMap { relationDetails in
            guard !relationDetails.isHidden else { return nil }
            return relation(
                relationDetails: relationDetails,
                details: objectDetails,
                isObjectLocked: isObjectLocked,
                storage: storage
            )
        }
        
        return ParsedRelations(
            featuredRelations: featuredRelations,
            deletedRelations: deletedRelations,
            typeRelations: typeRelations,
            otherRelations: otherRelations
        )
    }
    
}

// MARK: - Private extension

private extension RelationsBuilder {
    
    func relation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool,
        storage: ObjectDetailsStorage
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
                isObjectLocked: isObjectLocked,
                storage: storage
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
                isObjectLocked: isObjectLocked,
                storage: storage
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
                isObjectLocked: isObjectLocked,
                storage: storage
            )
        case .object:
            return objectRelation(
                relationDetails: relationDetails,
                details: details,
                isObjectLocked: isObjectLocked,
                storage: storage
            )
        case .unrecognized:
            return .text(
                Relation.Text(
                    id: relationDetails.id,
                    key: relationDetails.key,
                    name: relationDetails.name,
                    isFeatured: relationDetails.isFeatured(details: details),
                    isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                    canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                    isDeleted: relationDetails.isDeleted,
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
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func numberRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let numberValue: String? = {
            guard let number = details.doubleValue(for: relationDetails.key) else { return nil }
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        
        return .number(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
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
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
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
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
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
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func statusRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation {
        
        let selectedOption: Relation.Status.Option? = {
            let optionId = details.stringValue(for: relationDetails.key)
            
            guard optionId.isNotEmpty else { return nil }
            
            guard let optionDetails = storage.get(id: optionId) else { return nil }
            let option = RelationOption(details: optionDetails)
            return Relation.Status.Option(option: option)
        }()
        var values = [Relation.Status.Option]()
        if let selectedOption = selectedOption {
            values.append(selectedOption)
        }
        return .status(
            Relation.Status(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                values: values
            )
        )
    }
    
    func dateRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool
    ) -> Relation {
        let value: DateRelationValue? = {
            guard let date = details.dateValue(for: relationDetails.key) else { return nil }
            return DateRelationValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Relation.Date(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
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
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.boolValue(for: relationDetails.key)
            )
        )
    }
    
    func tagRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation {
        
        let selectedTags: [Relation.Tag.Option] = {
            let selectedTagIds = details.stringArrayValue(for: relationDetails.key)
            
            let tags = selectedTagIds
                .compactMap { storage.get(id: $0) }
                .map { RelationOption(details: $0) }
                .map { Relation.Tag.Option(option: $0) }

            return tags
        }()
        
        return .tag(
            Relation.Tag(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                selectedTags: selectedTags
            )
        )
    }
    
    func objectRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation {
        let objectOptions: [Relation.Object.Option] = {
            
            let values = details.stringValueOrArray(for: relationDetails)

            let objectOptions: [Relation.Object.Option] = values.compactMap { valueId in
                
                if relationDetails.key == BundledRelationKey.type.rawValue {
                    let type = details.objectType
                    return Relation.Object.Option(
                        id: type.id,
                        icon: nil,
                        title: type.name,
                        type: "",
                        isArchived: type.isArchived,
                        isDeleted: type.isDeleted,
                        editorScreenData: nil
                    )
                }
                
                guard let objectDetail = storage.get(id: valueId) else { return nil }
                    
                if relationDetails.key == BundledRelationKey.setOf.rawValue, objectDetail.isDeleted {
                    return Relation.Object.Option(
                        id: valueId,
                        icon: .object(.placeholder(nil)),
                        title: Loc.deleted,
                        type: .empty,
                        isArchived: true,
                        isDeleted: true,
                        editorScreenData: objectDetail.editorScreenData()
                    )
                }
                
                return Relation.Object.Option(
                    id: objectDetail.id,
                    icon: objectDetail.objectIconImage,
                    title: objectDetail.title,
                    type: objectDetail.objectType.name,
                    isArchived: objectDetail.isArchived,
                    isDeleted: objectDetail.isDeleted,
                    editorScreenData: objectDetail.editorScreenData()
                )
            }
            
            return objectOptions
        }()
        
        return .object(
            Relation.Object(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                selectedObjects: objectOptions,
                limitedObjectTypes: relationDetails.objectTypes
            )
        )
    }
    
    func fileRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isObjectLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation {
        let fileOptions: [Relation.File.Option] = {
            let values = details.stringArrayValue(for: relationDetails.key)
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0)
            }

            let objectOptions: [Relation.File.Option] = objectDetails.map { objectDetail in      
                return Relation.File.Option(
                    id: objectDetail.id,
                    icon: objectDetail.objectIconImage,
                    title: objectDetail.title,
                    editorScreenData: objectDetail.editorScreenData()
                )
            }
            
            return objectOptions
        }()
        
        return .file(
            Relation.File(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: relationDetails.isFeatured(details: details),
                isEditable: relationDetails.isEditable(objectLocked: isObjectLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
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
            return Loc.selectDate
        case .url:
            return Loc.addLink
        case .email:
            return Loc.addEmail
        case .phone:
            return Loc.addPhone
        case .status:
            return Loc.selectStatus
        case .tag:
            return Loc.selectTag
        case .file:
            return Loc.selectFile
        case .object:
            return Loc.selectObject
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

        return !self.isReadOnlyValue
    }
}
