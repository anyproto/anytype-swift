import Foundation
import SwiftUI
import Services
import Combine

@MainActor
final class RelationInfoViewModel: ObservableObject {
    
    var formatModel: NewRelationFormatSectionView.Model {
        format.asViewModel
    }
    
    var objectTypesRestrictionModel: [NewRelationRestrictionsSectionView.ObjectTypeModel]? {
        objectTypes.flatMap { $0.asViewModel }
    }
    
    var isCreateButtonActive: Bool {
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
    
    let mode: RelationInfoViewMode
    
    @Published var name: String
    @Published private var format: SupportedRelationFormat
    @Published private var objectTypes: [ObjectType]?
    @Published var toastData: ToastBarData = .empty
    
    private let target: RelationsModuleTarget
    private let objectId: String
    private let spaceId: String
    private let relationId: String
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private let relationsInteractor: any RelationsInteractorProtocol
    private weak var output: (any RelationInfoModuleOutput)?
    
    init(
        data: RelationInfoData,
        relationsInteractor: some RelationsInteractorProtocol,
        output: (any RelationInfoModuleOutput)?
    ) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
        self.target = data.target
        self.relationsInteractor = relationsInteractor
        self.output = output
        self.mode = data.mode
        
        self.name = data.name
        self.format = data.mode.format ?? SupportedRelationFormat.object
        self.relationId = data.mode.relationId ?? ""
        handleFormatUpdate()
        data.mode.limitedObjectTypes.flatMap { updateTypesRestriction(objectTypeIds: $0) }
    }
    
}

// MARK: - Internal functions

extension RelationInfoViewModel {
    
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
            let createdRelation = try await relationsInteractor.createRelation(spaceId: spaceId, relation: relationDetails)
            
            switch target {
            case .type(let data):
                try await relationsInteractor.addRelationToType(relation: createdRelation, isFeatured: data.isFeatured)
            case let .dataview(activeViewId, typeDetails):
                try await relationsInteractor.addRelationToDataview(objectId: objectId, relation: createdRelation, activeViewId: activeViewId, typeDetails: typeDetails)
            case .object(let objectId):
                try await relationsInteractor.addRelationToObject(objectId: objectId, relation: createdRelation)
            }
            
            onSuccessfullAction(relationDetails: createdRelation)
        }
    }
    
    private func updateRelation(_ details: RelationDetails) {
        Task {
            try await relationsInteractor.updateRelation(spaceId: spaceId, relation: details)
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
        
        toastData = ToastBarData(text: text, showSnackBar: true)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        output?.didPressConfirm(relationDetails)
    }
}

// MARK: - RelationInfoModuleInput

extension RelationInfoViewModel: RelationInfoModuleInput {
    
    func updateRelationFormat(_ newFormat: SupportedRelationFormat) {
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

private extension RelationInfoViewModel {
    
    func handleFormatUpdate() {
        objectTypes = format == .object ? [] : nil
    }
    
    var objectTypeIds: [String] {
        objectTypes?.map { $0.id } ?? []
    }
    
}

// MARK: - SupportedRelationFormat private extension

private extension SupportedRelationFormat {
    
    var asViewModel: NewRelationFormatSectionView.Model {
        NewRelationFormatSectionView.Model(icon: self.iconAsset, title: self.title)
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
    
    var asViewModel: [NewRelationRestrictionsSectionView.ObjectTypeModel] {
        map {
            NewRelationRestrictionsSectionView.ObjectTypeModel(
                id: $0.id,
                icon: $0.icon,
                title: $0.displayName
            )
        }
    }
    
}
