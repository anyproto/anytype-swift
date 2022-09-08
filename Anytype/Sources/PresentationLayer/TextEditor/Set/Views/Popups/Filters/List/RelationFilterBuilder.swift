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
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        switch relation.format {
        case .object:
            return objectRelation(
                relation: relation,
                filter: filter
            )
        case .longText, .shortText:
            return textRelation(
                relation: relation,
                filter: filter
            )
        case .number:
            return numberRelation(
                relation: relation,
                filter: filter
            )
        case .status:
            return statusRelation(
                relation: relation,
                filter: filter
            )
        case .file:
            return fileRelation(
                relation: relation,
                filter: filter
            )
        case .checkbox:
            return checkboxRelation(
                relation: relation,
                filter: filter
            )
        case .url:
            return urlRelation(
                relation: relation,
                filter: filter
            )
        case .email:
            return emailRelation(
                relation: relation,
                filter: filter
            )
        case .phone:
            return phoneRelation(
                relation: relation,
                filter: filter
            )
        case .tag:
            return tagRelation(
                relation: relation,
                filter: filter
            )
        default:
            return .text(
                RelationValue.Text(
                    id: relation.id,
                    key: relation.key,
                    name: relation.name,
                    isFeatured: false,
                    isEditable: false,
                    isBundled: relation.isBundled,
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
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        
        let objectOptions: [RelationValue.Object.Option] = {
            let values: [Google_Protobuf_Value] = {
                if case let .listValue(listValue) = filter.value.kind {
                    return listValue.values
                }
                
                return [filter.value]
            }()
            
            let objectDetails: [ObjectDetails] = values.compactMap {
                return storage.get(id: $0.stringValue)
            }

            let objectOptions: [RelationValue.Object.Option] = objectDetails.map { objectDetail in
                let name = objectDetail.title
                let icon: ObjectIconImage = {
                    if let objectIcon = objectDetail.objectIconImage {
                        return objectIcon
                    } else {
                        return .placeholder(name.first)
                    }
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
        
        #warning("Check limit object types")
        return .object(
            RelationValue.Object(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                selectedObjects: objectOptions,
                limitedObjectTypes: relation.objectTypes
            )
        )
    }
    
    func textRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        return .text(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func numberRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        
        let numberValue: String? = {
            guard let number = filter.value.safeDoubleValue else { return nil }
            
            return numberFormatter.string(from: NSNumber(floatLiteral: number))
        }()
        return .number(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                value: "“\(numberValue ?? "")“"
            )
        )
    }
    
    func phoneRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        return .phone(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func emailRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        return .email(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func urlRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        return .url(
            RelationValue.Text(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                value: "“\(filter.value.stringValue)“"
            )
        )
    }
    
    func statusRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        #warning("Fix selection status")
//        let statuses: [RelationValue.Status.Option] = relation.selections.map {
//            RelationValue.Status.Option(option: $0)
//        }
        let statuses = [RelationValue.Status.Option]()
        
        let selectedStatuses: [RelationValue.Status.Option] = {
            let selectedSatusesIds: [String] = filter.value.listValue.values.compactMap {
                let statusId = $0.stringValue
                return statusId.isEmpty ? nil : statusId
            }
            
            return selectedSatusesIds.compactMap { id in
                statuses.first { $0.id == id }
            }
        }()
        
        return .status(
            RelationValue.Status(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                values: selectedStatuses,
                allOptions: statuses
            )
        )
    }
    
    func tagRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        #warning("fix selections")
//        let tags: [RelationValue.Tag.Option] = relation.selections.map { RelationValue.Tag.Option(option: $0) }
        let tags = [RelationValue.Tag.Option]()
        
        let selectedTags: [RelationValue.Tag.Option] = {
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
            RelationValue.Tag(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                selectedTags: selectedTags,
                allTags: tags
            )
        )
    }
    
    func fileRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        
        let fileOptions: [RelationValue.File.Option] = {
            let objectDetails: [ObjectDetails] = filter.value.listValue.values.compactMap {
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
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
                files: fileOptions
            )
        )
    }
    
    func checkboxRelation(
        relation: Relation,
        filter: DataviewFilter
    ) -> RelationValue? {
        guard filter.condition.hasValues else { return nil }
        return .checkbox(
            RelationValue.Checkbox(
                id: relation.id,
                key: relation.key,
                name: relation.name,
                isFeatured: false,
                isEditable: false,
                isBundled: relation.isBundled,
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
