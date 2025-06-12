import Foundation
import SwiftUI
import Services
import Combine

@MainActor
final class PropertyInfoViewModel: ObservableObject {
    
    var formatModel: NewPropertyFormatSectionView.Model {
        format.asViewModel
    }
    
    var objectTypesRestrictionModel: [NewPropertyRestrictionsSectionView.ObjectTypeModel]? {
        objectTypes.flatMap { $0.asViewModel }
    }
    
    var isSaveButtonActive: Bool {
        name.isNotEmpty
    }
    
    var confirmButtonTitle: String {
        switch mode {
        case .create:
            Loc.create
        case .edit:
            Loc.save
        }
    }
    
    var title: String {
        switch mode {
        case .create:
            Loc.newField
        case .edit:
            Loc.editField
        }
    }
    
    let mode: PropertyInfoViewMode
    let isReadOnly: Bool
    
    @Published var name: String
    @Published private var format: SupportedPropertyFormat
    @Published private var objectTypes: [ObjectType]?
    @Published var toastData: ToastBarData?
    
    private let target: PropertiesModuleTarget
    private let objectId: String?
    private let spaceId: String
    private let relationId: String
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private let relationsInteractor: any PropertiesInteractorProtocol
    private weak var output: (any PropertyInfoModuleOutput)?
    
    init(
        data: PropertyInfoData,
        relationsInteractor: some PropertiesInteractorProtocol,
        output: (any PropertyInfoModuleOutput)?
    ) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
        self.target = data.target
        self.relationsInteractor = relationsInteractor
        self.output = output
        self.mode = data.mode
        self.isReadOnly = data.isReadOnly
        
        self.name = data.name
        self.format = data.mode.format ?? SupportedPropertyFormat.object
        self.relationId = data.mode.relationId ?? ""
        handleFormatUpdate()
        data.mode.limitedObjectTypes.flatMap { updateTypesRestriction(objectTypeIds: $0) }
    }
    
}

// MARK: - Internal functions

extension PropertyInfoViewModel {
    
    func didTapFormatSection() {
        output?.didAskToShowRelationFormats(selectedFormat: format, onSelect: { [weak self] format in
            self?.updateRelationFormat(format)
        })
    }
    
    func didTapTypesRestrictionSection() {
        output?.didAskToShowObjectTypesSearch(selectedObjectTypesIds: objectTypeIds, onSelect: { [weak self] ids in
            self?.updateTypesRestriction(objectTypeIds: ids)
        })
    }
    
    func didTapAddButton() {
        
        let relationDetails = RelationDetails(
            id: relationId,
            key: "",
            name: name,
            format: format.asRelationFormat,
            isHidden: false,
            isReadOnly: false,
            isReadOnlyValue: false,
            objectTypes: objectTypeIds,
            maxCount: 0,
            sourceObject: "",
            isDeleted: false,
            spaceId: ""
        )
        
        switch mode {
        case .create:
            createRelation(relationDetails)
        case .edit:
            updateRelation(relationDetails)
        }
    }
    
    private func createRelation(_ relationDetails: RelationDetails) {
        Task {
            let createdRelation = try await relationsInteractor.createProperty(spaceId: spaceId, relation: relationDetails)
            
            switch target {
            case .type(let data):
                try await relationsInteractor.addPropertyToType(relation: createdRelation, isFeatured: data.isFeatured)
            case let .dataview(objectId, activeViewId, typeDetails):
                try await relationsInteractor.addPropertyToDataview(objectId: objectId, relation: createdRelation, activeViewId: activeViewId, typeDetails: typeDetails)
            case .object(let targetObjectId):
                try await relationsInteractor.addPropertyToObject(objectId: targetObjectId, relation: createdRelation)
            case .library:
                break
            }
            
            onSuccessfullAction(relationDetails: createdRelation)
        }
    }
    
    private func updateRelation(_ details: RelationDetails) {
        Task {
            try await relationsInteractor.updateProperty(spaceId: spaceId, relation: details)
            onSuccessfullAction(relationDetails: details)
        }
    }
    
    private func onSuccessfullAction(relationDetails: RelationDetails) {
        let text = switch mode {
        case .create:
            Loc.Fields.created(relationDetails.name)
        case .edit:
            Loc.Fields.updated(relationDetails.name)
        }
        
        toastData = ToastBarData(text)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        output?.didPressConfirm(relationDetails)
    }
}

// MARK: - PropertyInfoModuleInput

extension PropertyInfoViewModel: PropertyInfoModuleInput {
    
    func updateRelationFormat(_ newFormat: SupportedPropertyFormat) {
        format = newFormat
        handleFormatUpdate()
    }
    
    func updateTypesRestriction(objectTypeIds: [String]) {
        objectTypes = objectTypeIds.compactMap {
            try? objectTypeProvider.objectType(id: $0)
        }
    }
    
}

// MARK: - Private extension

private extension PropertyInfoViewModel {
    
    func handleFormatUpdate() {
        objectTypes = format == .object ? [] : nil
    }
    
    var objectTypeIds: [String] {
        objectTypes?.map { $0.id } ?? []
    }
    
}

// MARK: - SupportedPropertyFormat private extension

private extension SupportedPropertyFormat {
    
    var asViewModel: NewPropertyFormatSectionView.Model {
        NewPropertyFormatSectionView.Model(icon: self.iconAsset, title: self.title)
    }
    
    var asRelationFormat: RelationFormat {
        switch self {
        case .text: return .longText
        case .tag: return .tag
        case .status: return .status
        case .number: return .number
        case .date: return .date
        case .file: return .file
        case .object: return .object
        case .checkbox: return .checkbox
        case .url: return .url
        case .email: return .email
        case .phone: return .phone
        }
    }
}

// MARK: - Array private extension

private extension Array where Element == ObjectType {
    
    var asViewModel: [NewPropertyRestrictionsSectionView.ObjectTypeModel] {
        map {
            NewPropertyRestrictionsSectionView.ObjectTypeModel(
                id: $0.id,
                icon: $0.icon,
                title: $0.displayName
            )
        }
    }
    
}
