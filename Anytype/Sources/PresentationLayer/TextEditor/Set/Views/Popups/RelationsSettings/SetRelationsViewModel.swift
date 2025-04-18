import FloatingPanel
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore
import Combine

@MainActor
final class SetRelationsViewModel: ObservableObject {
    @Published var view: DataviewView = .empty
    @Published var relations = [SetViewSettingsRelation]()
    
    private let setDocument: any SetDocumentProtocol
    private let viewId: String
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    
    private weak var output: (any SetRelationsCoordinatorOutput)?
    
    private var cancellable: (any Cancellable)?
    
    init(
        setDocument: some SetDocumentProtocol,
        viewId: String,
        output: (any SetRelationsCoordinatorOutput)?
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.output = output
        self.setup()
    }
    
    func deleteRelations(indexes: IndexSet) {
        indexes.forEach { index in
            guard let relation = setDocument.sortedRelations(for: viewId)[safe: index] else {
                anytypeAssertionFailure("No relation to delete", info: ["index": "\(index)"])
                return
            }
            Task {
                let key = relation.relationDetails.key
                guard let details = setDocument.details else { return }
                
                if FeatureFlags.openTypeAsSet, details.isObjectType {
                    try await relationsService.deleteTypeRelation(
                        details: details,
                        relationId: relation.relationDetails.id
                    )
                } else {
                    try await dataviewService.deleteRelation(
                        objectId: setDocument.objectId,
                        blockId: setDocument.blockId,
                        relationKey: key
                    )
                }
                
                if let details = setDocument.details, FeatureFlags.openTypeAsSet && details.isObjectType {
                    try await relationsService.deleteTypeRelation(details: details, relationId: relation.relationDetails.id)
                } else {
                    try await dataviewService.removeViewRelations(
                        objectId: setDocument.objectId,
                        blockId: setDocument.blockId,
                        keys: [key],
                        viewId: viewId
                    )
                }
            }
        }
    }
    
    func moveRelation(from: IndexSet, to: Int) {
        from.forEach { [weak self] sortedRelationsFromIndex in
            guard let self, sortedRelationsFromIndex != to else { return }
            
            let sortedRelations = setDocument.sortedRelations(for: viewId)
            let relationFrom = sortedRelations[sortedRelationsFromIndex]
            let sortedRelationsToIndex = to > sortedRelationsFromIndex ? to - 1 : to // map insert index to item index
            let relationTo = sortedRelations[sortedRelationsToIndex]
            let options = view.options
            
            // index in all options array (includes hidden options)
            guard let indexFrom = options.index(of: relationFrom) else {
                anytypeAssertionFailure("No from relation for move", info: ["key": relationFrom.relationDetails.key])
                return
            }
            guard let indexTo = options.index(of: relationTo) else {
                anytypeAssertionFailure("No to relation for move", info: ["key": relationTo.relationDetails.key])
                return
            }
            
            var newOptions = options
            newOptions.moveElement(from: indexFrom, to: indexTo)
            let keys = newOptions.map { $0.key }
            Task { [weak self] in
                guard let self else { return }
                try await dataviewService.sortViewRelations(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    keys: keys,
                    viewId: viewId
                )
            }
        }
    }
    
    func showAddRelationInfoView() {
        output?.onAddButtonTap { [spaceId = setDocument.spaceId] relation, isNew in
            AnytypeAnalytics.instance().logAddExistingOrCreateRelation(
                format: relation.format,
                isNew: isNew,
                type: .dataview,
                key: relation.analyticsKey,
                spaceId: spaceId
            )
        }
    }
    
    private func setup() {
        cancellable = setDocument.syncPublisher.receiveOnMain().sink {  [weak self] in
            guard let self else { return }
            view = setDocument.view(by: viewId)
            
            relations = setDocument.sortedRelations(for: viewId).map { relation in
                SetViewSettingsRelation(
                    id: relation.id,
                    image: relation.relationDetails.format.iconAsset,
                    title: relation.relationDetails.name,
                    isOn: relation.option.isVisible,
                    canBeRemovedFromObject: relation.relationDetails.canBeRemovedFromObject,
                    onChange: { [weak self] isVisible in
                        self?.onRelationVisibleChange(relation, isVisible: isVisible)
                    }
                )
            }
        }
    }
    
    private func onRelationVisibleChange(_ relation: SetRelation, isVisible: Bool) {
        Task {
            let newOption = relation.option.updated(isVisible: isVisible).asMiddleware
            try await dataviewService.replaceViewRelation(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                key: relation.option.key,
                with: newOption,
                viewId: viewId
            )
        }
    }
}
