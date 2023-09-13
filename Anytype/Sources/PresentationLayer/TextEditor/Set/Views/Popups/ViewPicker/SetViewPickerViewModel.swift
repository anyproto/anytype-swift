import SwiftUI
import Services
import Combine
import AnytypeCore

@MainActor
final class SetViewPickerViewModel: ObservableObject {
    @Published var rows: [SetViewRowConfiguration] = []
    @Published var disableDeletion = false
    
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
        if FeatureFlags.newSetSettings {
            createView()
        } else {
            output?.onAddButtonTap()
        }
    }
    
    func move(from: IndexSet, to: Int) {
        from.forEach { viewFromIndex in
            guard viewFromIndex != to, viewFromIndex < setDocument.dataView.views.count else { return }
            let view = setDocument.dataView.views[viewFromIndex]
            let position = to > viewFromIndex ? to - 1 : to
            Task {
                try await dataviewService.setPositionForView(view.id, position: position)
                AnytypeAnalytics.instance().logRepositionView(objectType: setDocument.analyticsType)
            }
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        indexSet.forEach { deleteIndex in
            guard deleteIndex < setDocument.dataView.views.count else { return }
            let view = setDocument.dataView.views[deleteIndex]
            Task {
                try await dataviewService.deleteView(view.id)
                AnytypeAnalytics.instance().logRemoveView(objectType: setDocument.analyticsType)
            }
        }
    }
    
    private func setup() {
        cancellable = setDocument.dataviewPublisher.sink { [weak self] dataView in
            self?.updateRows(with: dataView)
        }
    }
    
    private func updateRows(with dataView: BlockDataview) {
        rows = dataView.views.map { view in
            let name = view.name.isNotEmpty ? view.name : Loc.SetViewTypesPicker.Settings.Textfield.Placeholder.untitled
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
        setDocument.updateActiveViewId(view.id)
        AnytypeAnalytics.instance().logSwitchView(
            type: view.type.stringValue,
            objectType: setDocument.analyticsType
        )
    }
    
    private func handleEditTap(with id: String) {
        guard let activeView = setDocument.dataView.views.first(where: { $0.id == id }) else {
            return
        }
        output?.onEditButtonTap(dataView: activeView)
    }
    
    private func createView() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let viewId = try await dataviewService.createView(
                DataviewView.created(with: "", type: .table),
                source: setDocument.details?.setOf ?? []
            )
            output?.onAddButtonTap(with: viewId)
            AnytypeAnalytics.instance().logAddView(
                type: DataviewViewType.table.stringValue,
                objectType: setDocument.analyticsType
            )
        }
    }
}
