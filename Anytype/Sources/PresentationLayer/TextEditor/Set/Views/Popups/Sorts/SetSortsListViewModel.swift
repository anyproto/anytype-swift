import Foundation
import SwiftUI
import BlocksModels
import FloatingPanel

final class SetSortsListViewModel: ObservableObject {
    
    @Published var isSearchPresented: Bool = false
    private let setModel: EditorSetViewModel
    
    private(set) var popupLayout = AnytypePopupLayoutType.relationOptions
    private weak var popup: AnytypePopupProxy?

    
    init(setModel: EditorSetViewModel) {
        self.setModel = setModel
    }
    
}

extension SetSortsListViewModel {
    
    func addButtonTapped() {
        isSearchPresented = true
    }
    
    func editButtonTapped() {}
    
    @ViewBuilder
    func makeSearchView() -> some View {}
    
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
