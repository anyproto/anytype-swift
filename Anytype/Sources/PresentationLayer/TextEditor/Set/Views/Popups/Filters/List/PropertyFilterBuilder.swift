import Foundation
import Services
import SwiftProtobuf
import AnytypeCore

final class PropertyFilterBuilder {
        
    // MARK: - Private variables
    
    private let dateFormatter = DateFormatter.defaultDateFormatter
    private let numberFormatter = NumberFormatter.decimalWithNoSeparator
    
    func relation(
        detailsStorage: ObjectDetailsStorage,
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        switch relationDetails.format {
        case .object:
            return objectRelation(
                detailsStorage: detailsStorage,
                relationDetails: relationDetails,
                filter: filter
            )
        case .longText, .shortText:
            return textRelation(
                relationDetails: relationDetails,
                filter: filter
            )
        case .number:
            return numberRelation(
                relationDetails: relationDetails,
                filter: filter
            )
        case .status:
            return statusRelation(
                detailsStorage: detailsStorage,
                relationDetails: relationDetails,
                filter: filter
            )
        case .file:
            return fileRelation(
                detailsStorage: detailsStorage,
                relationDetails: relationDetails,
                filter: filter
            )
        case .checkbox:
            return checkboxRelation(
                relationDetails: relationDetails,
                filter: filter
            )
        case .url:
            return urlRelation(
                relationDetails: relationDetails,
                filter: filter
            )
        case .email:
            return emailRelation(
                relationDetails: relationDetails,
                filter: filter
            )
        case .phone:
            return phoneRelation(
                relationDetails: relationDetails,
                filter: filter
            )
        case .tag:
            return tagRelation(
                detailsStorage: detailsStorage,
                relationDetails: relationDetails,
                filter: filter
            )
        default:
            return .text(
                Property.Text(
                    id: relationDetails.id,
                    key: relationDetails.key,
                    name: relationDetails.name,
                    isFeatured: false,
                    isEditable: false,
                    canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                    isDeleted: relationDetails.isDeleted,
                    value: Loc.unsupportedValue
                )
            )
        }
    }
    
    func dateString(for filter: DataviewFilter) -> String {
        guard filter.condition.hasValues else { return "" }
        
        switch filter.quickOption {
        case .exactDate:
            return buildExactDateString(for: filter)
        case .numberOfDaysAgo, .numberOfDaysNow:
            return buildNumberOfDaysDateString(for: filter, option: filter.quickOption)
        default:
            return filter.quickOption.title.lowercased()
        }
    }
}

private extension PropertyFilterBuilder {
    func objectRelation(
        detailsStorage: ObjectDetailsStorage,
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        
        let objectOptions: [Property.Object.Option] = {
            let values: [Google_Protobuf_Value] = {
                if case let .listValue(listValue) = filter.value.kind {
                    return listValue.values
                }
                
                return [filter.value]
            }()
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return detailsStorage.get(id: $0.stringValue)
            }

            let objectOptions: [Property.Object.Option] = objectDetails.map { objectDetail in
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
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                selectedObjects: objectOptions,
                limitedObjectTypes: relationDetails.objectTypes
            )
        )
    }
    
    func textRelation(
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        return .text(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func numberRelation(
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        
        let numberValue: String? = {
            guard let number = filter.value.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        return .number(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: "“\(numberValue ?? "")“"
            )
        )
    }
    
    func phoneRelation(
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        return .phone(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func emailRelation(
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        return .email(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func urlRelation(
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        return .url(
            Property.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func statusRelation(
        detailsStorage: ObjectDetailsStorage,
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        
        let selectedStatuses: [Property.Status.Option] = {
            let selectedSatusesIds: [String] = filter.value.listValue.values.compactMap {
                let statusId = $0.stringValue
                return statusId.isEmpty ? nil : statusId
            }
            
            return selectedSatusesIds
                .compactMap { detailsStorage.get(id: $0) }
                .map { PropertyOption(details: $0) }
                .map { Property.Status.Option(option: $0) }
        }()
        
        return .status(
            Property.Status(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                values: selectedStatuses
            )
        )
    }
    
    func tagRelation(
        detailsStorage: ObjectDetailsStorage,
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        
        let selectedTags: [Property.Tag.Option] = {
            let value = filter.value
            
            let selectedTagIds: [String] = value.listValue.values.compactMap {
                let tagId = $0.stringValue
                return tagId.isEmpty ? nil : tagId
            }
            
            let tags = selectedTagIds
                .compactMap { detailsStorage.get(id: $0) }
                .map { PropertyOption(details: $0) }
                .map { Property.Tag.Option(option: $0) }
            
            return tags
        }()
        
        return .tag(
            Property.Tag(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                selectedTags: selectedTags
            )
        )
    }
    
    func fileRelation(
        detailsStorage: ObjectDetailsStorage,
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        
        let fileOptions: [Property.File.Option] = {
            let objectDetails: [ObjectDetails] = filter.value.listValue.values.compactMap {
                return detailsStorage.get(id: $0.stringValue)
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
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                files: fileOptions
            )
        )
    }
    
    func checkboxRelation(
        relationDetails: PropertyDetails,
        filter: DataviewFilter
    ) -> Property? {
        guard filter.condition.hasValues else { return nil }
        return .checkbox(
            Property.Checkbox(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                canBeRemovedFromObject: relationDetails.canBeRemovedFromObject,
                isDeleted: relationDetails.isDeleted,
                value: filter.value.boolValue
            )
        )
    }
    
    func buildExactDateString(for filter: DataviewFilter) -> String {
        guard let timeInterval = filter.value.safeDoubleValue, !timeInterval.isZero else {
            return Loc.Relation.View.Hint.empty
        }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        return dateFormatter.string(from: date)
    }
    
    func buildNumberOfDaysDateString(for filter: DataviewFilter, option: DataviewFilter.QuickOption) -> String {
        let count = "\(filter.value.safeIntValue ?? 0)"
        return option == .numberOfDaysAgo ?
        Loc.EditSet.Popup.Filter.Date.Option.NumberOfDaysAgo.short(count) :
        Loc.EditSet.Popup.Filter.Date.Option.NumberOfDaysFromNow.short(count)
    }
}
