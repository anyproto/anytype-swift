import SwiftUI
import Services
import Combine
import AnytypeCore

@MainActor
final class SetViewPickerViewModel: ObservableObject {
    @Published var rows: [SetViewRowConfiguration] = []
    @Published var disableDeletion = false
    @Published var canEditViews = false
    @Published var shouldDismiss = false
    
    private let setDocument: any SetDocumentProtocol
    private var cancellable: AnyCancellable?
    
    @Injected(\.dataviewService)
    private var dataviewService: any DataviewServiceProtocol
    
    private weak var output: (any SetViewPickerCoordinatorOutput)?
    
    init(
        setDocument: some SetDocumentProtocol,
        output: (any SetViewPickerCoordinatorOutput)?
    ) {
        self.setDocument = setDocument
        self.output = output
        self.setup()
    }
    
    func move(from: IndexSet, to: Int) {
        from.forEach { viewFromIndex in
            guard viewFromIndex != to, viewFromIndex < setDocument.dataView.views.count else { return }
            let view = setDocument.dataView.views[viewFromIndex]
            let position = to > viewFromIndex ? to - 1 : to
            Task {
                try await dataviewService.setPositionForView(objectId: setDocument.objectId, blockId: setDocument.blockId, viewId: view.id, position: position)
                AnytypeAnalytics.instance().logRepositionView(objectType: setDocument.analyticsType)
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { deleteIndex in
            guard deleteIndex < setDocument.dataView.views.count else { return }
            let view = setDocument.dataView.views[deleteIndex]
            Task {
                let previousActiveViewId = setDocument.dataView.activeViewId
                try await dataviewService.deleteView(objectId: setDocument.objectId, blockId: setDocument.blockId, viewId: view.id)
                try await setActiveViewIfNeeded(previousViewId: previousActiveViewId, newViewId: setDocument.dataView.activeViewId)
                AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
            }
        }
    }
    
    func startSyncTask() async {
        for await _ in setDocument.syncPublisher.receiveOnMain().values {
            canEditViews = setDocument.setPermissions.canEditView
        }
    }
    
    private func setup() {
        cancellable = setDocument.dataviewPublisher.sink { [weak self] dataView in
            self?.updateRows(with: dataView)
        }
    }
    
    private func updateRows(with dataView: BlockDataview) {
        rows = dataView.views.map { view in
            let name = view.nameWithPlaceholder
            return SetViewRowConfiguration(
                id: view.id,
                name: name,
                typeName: view.type.name.lowercased(),
                isSupported: view.type.isSupported,
                isActive: view == dataView.views.first { $0.id == dataView.activeViewId },
                onTap: { [weak self] in
                    self?.handleTap(with: view)
                },
                onEditTap: { [weak self] in
                    self?.handleEditTap(with: view.id)
                }
            )
        }
        disableDeletion = rows.count < 2
    }
    
    private func handleTap(with view: DataviewView) {
        Task {
            let changed = try await setActiveViewIfNeeded(previousViewId: setDocument.dataView.activeViewId, newViewId: view.id)
            if changed {
                setDocument.updateActiveViewIdAndReload(view.id)
                AnytypeAnalytics.instance().logSwitchView(
                    type: view.type.analyticStringValue,
                    objectType: setDocument.analyticsType
                )
                shouldDismiss.toggle()
            }
        }
    }
    
    @discardableResult
    private func setActiveViewIfNeeded(previousViewId: String, newViewId: String) async throws -> Bool  {
        guard previousViewId != newViewId else { return false }
        try await dataviewService.setActiveView(
            objectId: setDocument.objectId,
            blockId: setDocument.blockId,
            viewId: newViewId
        )
        return true
    }
    
    private func handleEditTap(with id: String) {
        let activeView = setDocument.view(by: id)
        output?.onEditButtonTap(dataView: activeView)
    }
    
    func createView() async throws {
        guard let details = setDocument.details else { return }
        
        var type = DataviewViewType.list
        if details.isObjectType {
            let listObjectTypesKeys = [ObjectTypeUniqueKey.task, ObjectTypeUniqueKey.template, ObjectTypeUniqueKey.project]
            type = listObjectTypesKeys.contains(ObjectType(details: details).uniqueKey) ? .list : .table
        }
        
        let newView = setDocument.activeView.updated(
            name: "",
            type: type,
            sorts: [],
            filters: []
        )
        let source = setDocument.details?.filteredSetOf ?? []
        let viewId = try await dataviewService.createView(
            objectId: setDocument.objectId,
            blockId: setDocument.blockId,
            view: newView,
            source: source
        )
        output?.onAddButtonTap(with: viewId)
        AnytypeAnalytics.instance().logAddView(
            type: DataviewViewType.table.analyticStringValue,
            objectType: setDocument.analyticsType
        )
    }
}
