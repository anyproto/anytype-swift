import Foundation
import SwiftUI
import Combine

@MainActor
final class SpaceSearchViewModel: SearchViewModelProtocol {
    @Published var searchData = [SearchDataSection<SpaceView>]()
    var onSelect: (SpaceView) -> ()
    var placeholder: String { Loc.Spaces.Search.title }
    var lastSearchText: String = ""
    
    private let workspacesStorage: WorkspacesStorageProtocol
    private var spaces = [SpaceView]()
    private var cancellables = [AnyCancellable]()
    
    init(
        workspacesStorage: WorkspacesStorageProtocol,
        onSelect: @escaping (SpaceView) -> Void
    ) {
        self.workspacesStorage = workspacesStorage
        self.onSelect = onSelect
        
        setupSubscription()
    }
    
    private func setupSubscription() {
        workspacesStorage.workspsacesPublisher.sink { [weak self] spaces in
            self?.spaces = spaces
            self?.search(text: self?.lastSearchText ?? "")
        }.store(in: &cancellables)
    }
    
    func search(text: String) {
        let searchSpacesResult: [SpaceView]
        if text.isNotEmpty {
            searchSpacesResult = spaces.filter { $0.name.contains(text) }
        } else {
            searchSpacesResult = spaces
        }
        
        searchData = [.init(searchData: searchSpacesResult, sectionName: "")]
        
        lastSearchText = text
    }
}

extension SpaceView: SearchDataProtocol {
    var iconImage: Icon? { objectIconImage }
    var description: String { "" }
    var callout: String { "" }
    var typeId: String { "" }
    var shouldShowCallout: Bool { false }
    var verticalInset: CGFloat { 0 }
    var editorScreenData: EditorScreenData { .recentOpen }
    var shouldShowDescription: Bool { false }
    var descriptionTextColor: Color { Color.Text.primary }
    var descriptionFont: AnytypeFont { .relation3Regular}
}
