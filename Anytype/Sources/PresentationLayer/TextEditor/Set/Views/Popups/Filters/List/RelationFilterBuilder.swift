import Foundation
import Services
import SwiftProtobuf
import AnytypeCore

final class RelationFilterBuilder {
        
    // MARK: - Private variables
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    func relation(
        document: BaseDocumentProtocol,
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        switch relationDetails.format {
        case .object:
            return objectRelation(
                document: document,
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
                document: document,
                relationDetails: relationDetails,
                filter: filter
            )
        case .file:
            return fileRelation(
                document: document,
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
                document: document,
                relationDetails: relationDetails,
                filter: filter
            )
        default:
            return .text(
                Relation.Text(
                    id: relationDetails.id,
                    key: relationDetails.key,
                    name: relationDetails.name,
                    isFeatured: false,
                    isEditable: false,
                    isSystem: relationDetails.isSystem,
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

private extension RelationFilterBuilder {
    func objectRelation(
        document: BaseDocumentProtocol,
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
        let objectOptions: [Relation.Object.Option] = {
            let values: [Google_Protobuf_Value] = {
                if case let .listValue(listValue) = filter.value.kind {
                    return listValue.values
                }
                
                return [filter.value]
            }()
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return document.detailsStorage.get(id: $0.stringValue)
            }

            let objectOptions: [Relation.Object.Option] = objectDetails.map { objectDetail in
                return Relation.Object.Option(
                    id: objectDetail.id,
                    icon: FeatureFlags.deleteObjectPlaceholder ? objectDetail.objectIconImage : objectDetail.objectIconImageWithPlaceholder,
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
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                selectedObjects: objectOptions,
                limitedObjectTypes: relationDetails.objectTypes
            )
        )
    }
    
    func textRelation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .text(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func numberRelation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
        let numberValue: String? = {
            guard let number = filter.value.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        return .number(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: "“\(numberValue ?? "")“"
            )
        )
    }
    
    func phoneRelation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .phone(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func emailRelation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .email(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func urlRelation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .url(
            Relation.Text(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func statusRelation(
        document: BaseDocumentProtocol,
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
        let selectedStatuses: [Relation.Status.Option] = {
            let selectedSatusesIds: [String] = filter.value.listValue.values.compactMap {
                let statusId = $0.stringValue
                return statusId.isEmpty ? nil : statusId
            }
            
            return selectedSatusesIds
                .compactMap { document.detailsStorage.get(id: $0) }
                .map { RelationOption(details: $0) }
                .map { Relation.Status.Option(option: $0) }
        }()
        
        return .status(
            Relation.Status(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                values: selectedStatuses
            )
        )
    }
    
    func tagRelation(
        document: BaseDocumentProtocol,
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
        let selectedTags: [Relation.Tag.Option] = {
            let value = filter.value
            
            let selectedTagIds: [String] = value.listValue.values.compactMap {
                let tagId = $0.stringValue
                return tagId.isEmpty ? nil : tagId
            }
            
            let tags = selectedTagIds
                .compactMap { document.detailsStorage.get(id: $0) }
                .map { RelationOption(details: $0) }
                .map { Relation.Tag.Option(option: $0) }
            
            return tags
        }()
        
        return .tag(
            Relation.Tag(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                selectedTags: selectedTags
            )
        )
    }
    
    func fileRelation(
        document: BaseDocumentProtocol,
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
        let fileOptions: [Relation.File.Option] = {
            let objectDetails: [ObjectDetails] = filter.value.listValue.values.compactMap {
                return document.detailsStorage.get(id: $0.stringValue)
            }

            let objectOptions: [Relation.File.Option] = objectDetails.map { objectDetail in
                return Relation.File.Option(
                    id: objectDetail.id,
                    icon: FeatureFlags.deleteObjectPlaceholder ? objectDetail.objectIconImage : objectDetail.objectIconImageWithPlaceholder,
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
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                files: fileOptions
            )
        )
    }
    
    func checkboxRelation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .checkbox(
            Relation.Checkbox(
                id: relationDetails.id,
                key: relationDetails.key,
                name: relationDetails.name,
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
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
