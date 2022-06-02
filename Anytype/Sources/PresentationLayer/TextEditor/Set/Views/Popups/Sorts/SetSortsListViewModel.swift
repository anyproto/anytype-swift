import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class SetSortsListViewModel: ObservableObject {
    
    @Published var isSearchPresented: Bool = false
    private let setModel: EditorSetViewModel
    private let service: DataviewServiceProtocol
    
    private(set) var popupLayout = AnytypePopupLayoutType.fullScreen
    private weak var popup: AnytypePopupProxy?

    
    init(setModel: EditorSetViewModel, service: DataviewServiceProtocol) {
        self.setModel = setModel
        self.service = service
    }
    
}

extension SetSortsListViewModel {
    
    func addButtonTapped() {
        isSearchPresented = true
    }
    
    func delete(_ indexSet: IndexSet) {
        var sorts = setModel.sorts
        sorts.remove(atOffsets: indexSet)
        updateView(with: sorts)
    }
    
    func move(from: IndexSet, to: Int) {
        var sorts = setModel.sorts
        sorts.move(fromOffsets: from, toOffset: to)
        updateView(with: sorts)
    }
    
    @ViewBuilder
    func makeSearchView() -> some View {}
    
    private func updateView(with sorts: [SetSort]) {
        let dataviewSorts = sorts.map { $0.sort }
        let newView = setModel.activeView.updated(sorts: dataviewSorts)
        service.updateView(newView)
    }
}

extension SetSortsListViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView:
                SetSortsListView()
                .environmentObject(self)
                .environmentObject(setModel)
        )
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}
