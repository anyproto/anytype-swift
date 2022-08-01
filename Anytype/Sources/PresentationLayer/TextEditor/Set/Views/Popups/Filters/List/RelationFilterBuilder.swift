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
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation? {
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
        metadata: RelationMetadata,
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
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .text(
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
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
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
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .phone(
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
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .email(
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
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .url(
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
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
        let statuses: [Relation.Status.Option] = metadata.selections.map {
            Relation.Status.Option(option: $0)
        }
        
        let selectedStatuses: [Relation.Status.Option] = {
            let selectedSatusesIds: [String] = filter.value.listValue.values.compactMap {
                let statusId = $0.stringValue
                return statusId.isEmpty ? nil : statusId
            }
            
            return selectedSatusesIds.compactMap { id in
                statuses.first { $0.id == id }
            }
        }()
        
        return .status(
            Relation.Status(
                id: metadata.id,
                name: metadata.name,
                isFeatured: false,
                isEditable: false,
                isBundled: metadata.isBundled,
                values: selectedStatuses,
                allOptions: statuses
            )
        )
    }
    
    func tagRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
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
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        
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
    
    func checkboxRelation(
        metadata: RelationMetadata,
        filter: DataviewFilter
    ) -> Relation? {
        guard filter.condition.hasValues else { return nil }
        return .checkbox(
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
