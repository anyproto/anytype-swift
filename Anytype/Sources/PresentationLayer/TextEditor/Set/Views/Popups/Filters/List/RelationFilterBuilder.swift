import Foundation
import BlocksModels
import SwiftProtobuf

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
        return dateFormatter
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    func relation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        switch relationDetails.format {
        case .object:
            return objectRelation(
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
                relationDetails: relationDetails,
                filter: filter
            )
        case .file:
            return fileRelation(
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
                    isDeleted: objectDetail.isDeleted,
                    editorViewType: objectDetail.editorViewType
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
                .compactMap { storage.get(id: $0) }
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
                isFeatured: false,
                isEditable: false,
                isSystem: relationDetails.isSystem,
                isDeleted: relationDetails.isDeleted,
                selectedTags: selectedTags
            )
        )
    }
    
    func fileRelation(
        relationDetails: RelationDetails,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
        let fileOptions: [Relation.File.Option] = {
            let objectDetails: [ObjectDetails] = filter.value.listValue.values.compactMap {
                return storage.get(id: $0.stringValue)
            }

            let objectOptions: [Relation.File.Option] = objectDetails.map { objectDetail in
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
