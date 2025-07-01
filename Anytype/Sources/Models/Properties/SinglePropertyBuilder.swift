import Services
import Foundation


protocol SinglePropertyBuilderProtocol {
    func property(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Property?
}

final class SinglePropertyBuilder: SinglePropertyBuilderProtocol {
    private let dateFormatter = DateFormatter.relativeDateFormatter
    private let numberFormatter = NumberFormatter.decimalWithNoSeparator
    
    
    func property(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Property? {
        switch relationDetails.format {
        case .longText:
            return textProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .shortText:
            return textProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .number:
            return numberProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .status:
            return statusProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked,
                storage: storage
            )
        case .date:
            return dateProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .file:
            return fileProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked,
                storage: storage
            )
        case .checkbox:
            return checkboxProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .url:
            return urlProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .email:
            return emailProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .phone:
            return phoneProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked
            )
        case .tag:
            return tagProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked,
                storage: storage
            )
        case .object:
            return objectProperty(
                relationDetails: relationDetails,
                details: details,
                isFeatured: isFeatured,
                propertyValuesIsLocked: propertyValuesIsLocked,
                storage: storage
            )
        case .unrecognized:
            return .text(
                Property.Text(
                    id: relationDetails.id,
                    key: relationDetails.key,
                    name: relationDetails.name,
                    isFeatured: isFeatured,
                    isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                    canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                    isDeleted: relationDetails.isDeleted,
                    value: Loc.unsupportedValue
                )
            )
        }
    }
}

private extension SinglePropertyBuilder {    
    func textProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool
    ) -> Property {
        .text(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func numberProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool
    ) -> Property? {
        
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
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: numberValue
            )
        )
    }
    
    func phoneProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool
    ) -> Property {
        .phone(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func emailProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool
    ) -> Property {
        .email(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func urlProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool
    ) -> Property {
        .url(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.stringValue(for: relationDetails.key)
            )
        )
    }
    
    func statusProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Property {
        
        let selectedOption: Property.Status.Option? = {
            let optionId = details.stringValue(for: relationDetails.key)
            
            guard optionId.isNotEmpty else { return nil }
            
            guard let optionDetails = storage.get(id: optionId) else { return nil }
            let option = PropertyOption(details: optionDetails)
            return Property.Status.Option(option: option)
        }()
        var values = [Property.Status.Option]()
        if let selectedOption = selectedOption {
            values.append(selectedOption)
        }
        return .status(
            Property.Status(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                values: values
            )
        )
    }
    
    func dateProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool
    ) -> Property {
        let value: DatePropertyValue? = {
            guard let date = details.dateValue(for: relationDetails.key) else { return nil }
            return DatePropertyValue(date: date, text: dateFormatter.string(from: date))
        }()
        
        return .date(
            Property.Date(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: value
            )
        )
    }
    
    func checkboxProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool
    ) -> Property {
        .checkbox(
            Property.Checkbox(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: details.boolValue(for: relationDetails.key)
            )
        )
    }
    
    func tagProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Property {
        
        let selectedTags: [Property.Tag.Option] = {
            let selectedTagIds = details.stringArrayValue(for: relationDetails.key)
            
            let tags = selectedTagIds
                .compactMap { storage.get(id: $0) }
                .map { PropertyOption(details: $0) }
                .map { Property.Tag.Option(option: $0) }

            return tags
        }()
        
        return .tag(
            Property.Tag(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                selectedTags: selectedTags
            )
        )
    }
    
    func objectProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Property {
        let objectOptions: [Property.Object.Option] = {
            
            let values = details.stringValueOrArray(for: relationDetails)

            let objectOptions: [Property.Object.Option] = values.compactMap { valueId in
                
                if relationDetails.key == BundledPropertyKey.type.rawValue {
                    let type = details.objectType
                    return Property.Object.Option(
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
                    return Property.Object.Option(
                        id: valueId,
                        icon: .object(.placeholder("")),
                        title: Loc.deleted,
                        type: "",
                        isArchived: true,
                        isDeleted: true,
                        editorScreenData: objectDetail.screenData()
                    )
                }
                
                return Property.Object.Option(
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
            Property.Object(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                selectedObjects: objectOptions,
                limitedObjectTypes: relationDetails.objectTypes
            )
        )
    }
    
    func fileProperty(
        relationDetails: PropertyDetails,
        details: ObjectDetails,
        isFeatured: Bool,
        propertyValuesIsLocked: Bool,
        storage: ObjectDetailsStorage
    ) -> Property {
        let fileOptions: [Property.File.Option] = {
            let values = details.stringArrayValue(for: relationDetails.key)
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0)
            }

            let objectOptions: [Property.File.Option] = objectDetails.map { objectDetail in
                return Property.File.Option(
                    id: objectDetail.id,
                    icon: objectDetail.objectIconImage,
                    title: objectDetail.title,
                    editorScreenData: objectDetail.screenData()
                )
            }
            
            return objectOptions
        }()
        
        return .file(
            Property.File(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: isFeatured,
                isEditable: relationDetails.isEditable(valueLockedInObject: propertyValuesIsLocked),
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                files: fileOptions
            )
        )
    }
}


private extension PropertyDetails {
    
    func isEditable(valueLockedInObject: Bool) -> Bool {
        guard !valueLockedInObject else { return false }

        return !self.isReadOnlyValue
    }
}

extension Container {
    var singlePropertyBuilder: Factory<any SinglePropertyBuilderProtocol> {
        self { SinglePropertyBuilder() }.shared
    }
}
