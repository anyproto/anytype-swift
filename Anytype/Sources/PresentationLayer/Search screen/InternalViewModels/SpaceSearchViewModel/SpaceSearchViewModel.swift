import Foundation
import SwiftUI
import Combine

@MainActor
final class SpaceSearchViewModel: SearchViewModelProtocol {
    @Published var searchData = [SearchDataSection<SpaceView>]()
    var onSelect: (SpaceView) -> ()
    var placeholder: String { Loc.Spaces.Search.title }
    var lastSearchText: String = ""
    
    private let participantSpacesStorage: ParticipantSpacesStorageProtocol
    private var spaces = [SpaceView]()
    private var cancellables = [AnyCancellable]()
    
    init(
        participantSpacesStorage: ParticipantSpacesStorageProtocol,
        onSelect: @escaping (SpaceView) -> Void
    ) {
        self.participantSpacesStorage = participantSpacesStorage
        self.onSelect = onSelect
        
        setupSubscription()
    }
    
    private func setupSubscription() {
        participantSpacesStorage.activeParticipantSpacesPublisher.sink { [weak self] participantSpaces in
            self?.spaces = participantSpaces.filter(\.participant.canEdit).map(\.spaceView)
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
