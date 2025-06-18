import Services
import Foundation


protocol SingleRelationBuilderProtocol {
    func relation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation?
}

final class SingleRelationBuilder: SingleRelationBuilderProtocol {
    private let dateFormatter = DateFormatter.relativeDateFormatter
    private let numberFormatter = NumberFormatter.decimalWithNoSeparator
    
    
    func relation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation? {
        switch relationDetails.format {
        case .longText:
            return textRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .shortText:
            return textRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .number:
            return numberRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .status:
            return statusRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
        case .date:
            return dateRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .file:
            return fileRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
        case .checkbox:
            return checkboxRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .url:
            return urlRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .email:
            return emailRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .phone:
            return phoneRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked
            )
        case .tag:
            return tagRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
        case .object:
            return objectRelation(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                relationValuesIsLocked: relationValuesIsLocked,
                storage: storage
            )
        case .unrecognized:
            return .text(
                Relation.Text(
                    id: relationDetails.id,
                    key: relationDetails.key,
                    name: relationDetails.name,
                    isFeatured: isFeatured,
                    isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                    canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                    isDeleted: relationDetails.isDeleted,
                    value: Loc.unsupportedValue
                )
            )
        }
    }
}

private extension SingleRelationBuilder {    
    func textRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool
    ) -> Relation {
        .text(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func numberRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool
    ) -> Relation? {
        
        let numberValue: String?
        if relationDetails.key == BundledPropertyKey.origin.rawValue,
           let origin = details.intValue(for: relationDetails.key).flatMap({ ObjectOrigin(rawValue: $0) }) {
            if let title = origin.title {
                numberValue = title
            } else {
                return nil
            }
        } else if relationDetails.key == BundledPropertyKey.importType.rawValue,
                   let importType = details.intValue(for: relationDetails.key).flatMap({ ObjectImportType(rawValue: $0) }) {
            if let title = importType.title {
                numberValue = title
            } else {
                return nil
            }
        } else {
            numberValue = details.doubleValue(for: relationDetails.key).flatMap { numberFormatter.string(from: NSNumber(floatLiteral: $0)) }
        }
        
        return .number(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: numberValue
            )
        )
    }
    
    func phoneRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool
    ) -> Relation {
        .phone(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func emailRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool
    ) -> Relation {
        .email(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func urlRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool
    ) -> Relation {
        .url(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func statusRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
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
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                values: values
            )
        )
    }
    
    func dateRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool
    ) -> Relation {
        let value: DatePropertyValue? = {
            guard let date = details.dateValue(for: relationDetails.key) else { return nil }
            return DatePropertyValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Relation.Date(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: value
            )
        )
    }
    
    func checkboxRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool
    ) -> Relation {
        .checkbox(
            Relation.Checkbox(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.boolValue(for: relationDetails.key)
            )
        )
    }
    
    func tagRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
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
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                selectedTags: selectedTags
            )
        )
    }
    
    func objectRelation(
        relationDetails: RelationDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Relation {
        let objectOptions: [Relation.Object.Option] = {
            
            let values = details.stringValueOrArray(for: relationDetails)

            let objectOptions: [Relation.Object.Option] = values.compactMap { valueId in
                
                if relationDetails.key == BundledPropertyKey.type.rawValue {
                    let type = details.objectType
                    return Relation.Object.Option(
                        id: type.id,
                        icon: nil,
                        title: type.displayName,
                        type: "",
                        isArchived: type.isArchived,
                        isDeleted: type.isDeleted,
                        editorScreenData: nil
                    )
                }
                
                guard let objectDetail = storage.get(id: valueId) else { return nil }
                    
                if relationDetails.key == BundledPropertyKey.setOf.rawValue, objectDetail.isDeleted {
                    return Relation.Object.Option(
                        id: valueId,
                        icon: .object(.placeholder("")),
                        title: Loc.deleted,
                        type: "",
                        isArchived: true,
                        isDeleted: true,
                        editorScreenData: objectDetail.screenData()
                    )
                }
                
                return Relation.Object.Option(
                    id: objectDetail.id,
                    icon: objectDetail.objectIconImage,
                    title: objectDetail.title,
                    type: objectDetail.objectType.displayName,
                    isArchived: objectDetail.isArchived,
                    isDeleted: objectDetail.isDeleted,
                    editorScreenData: objectDetail.screenData()
                )
            }
            
            return objectOptions
        }()
        
        return .object(
            Relation.Object(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
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
        isFeatured: Bool,
        relationValuesIsLocked: Bool,
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
                    editorScreenData: objectDetail.screenData()
                )
            }
            
            return objectOptions
        }()
        
        return .file(
            Relation.File(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: relationValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                files: fileOptions
            )
        )
    }
}


private extension RelationDetails {
    
    func isEditable(valueLockedInObject: Bool) -> Bool {
        guard !valueLockedInObject else { return false }

        return !self.isReadOnlyValue
    }
}

extension Container {
    var singleRelationBuilder: Factory<any SingleRelationBuilderProtocol> {
        self { SingleRelationBuilder() }.shared
    }
}
