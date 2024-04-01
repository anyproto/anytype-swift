import SwiftUI
import Services
import Combine
import AnytypeCore

@MainActor
final class SetViewPickerViewModel: ObservableObject {
    @Published var rows: [SetViewRowConfiguration] = []
    @Published var disableDeletion = false
    @Published var canEditViews = false
    
    private let setDocument: SetDocumentProtocol
    private var cancellable: AnyCancellable?
    private let dataviewService: DataviewServiceProtocol
    private weak var output: SetViewPickerCoordinatorOutput?
    
    init(
        setDocument: SetDocumentProtocol,
        dataviewService: DataviewServiceProtocol,
        output: SetViewPickerCoordinatorOutput?
    ) {
        self.setDocument = setDocument
        self.dataviewService = dataviewService
        self.output = output
        self.setup()
    }
    
    func addButtonTapped() {
        createView()
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
                try await dataviewService.deleteView(objectId: setDocument.objectId, blockId: setDocument.blockId, viewId: view.id)
                AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
            }
        }
    }
    
    func startSyncTask() async {
        for await _ in setDocument.syncPublisher.values {
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
        setDocument.updateActiveViewIdAndReload(view.id)
        AnytypeAnalytics.instance().logSwitchView(
            type: view.type.analyticStringValue,
            objectType: setDocument.analyticsType
        )
    }
    
    private func handleEditTap(with id: String) {
        let activeView = setDocument.view(by: id)
        output?.onEditButtonTap(dataView: activeView)
    }
    
    private func createView() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let newView = setDocument.activeView.updated(
                name: "",
                type: .table,
                sorts: [],
                filters: []
            )
            let source = setDocument.details?.setOf ?? []
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
}
