import Foundation
import SwiftUI
import Combine

@MainActor
final class SpaceSearchViewModel: ObservableObject {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    private let data: SpaceSearchData
    private var spaces = [SpaceView]()
    
    @Published var searchData = [SearchDataSection<SpaceView>]()
    
    var lastSearchText: String = ""
    
    init(data: SpaceSearchData) {
        self.data = data
    }
    
    func onSelect(searchData: SpaceView) {
        data.onSelect(searchData)
    }
    
    func startParticipantTask() async {
        for await participantSpaces in participantSpacesStorage.activeParticipantSpacesPublisher.values {
            spaces = participantSpaces.filter(\.canEdit).map(\.spaceView)
            search(text: lastSearchText)
        }
    }
    
    func search(text: String) {
        let searchSpacesResult: [SpaceView]
        if text.isNotEmpty {
            searchSpacesResult = spaces.filter { $0.title.contains(text) }
        } else {
            searchSpacesResult = spaces
        }
        
        searchData = [.init(searchData: searchSpacesResult, sectionName: "")]
        
        lastSearchText = text
    }
}

extension SpaceView: SearchDataProtocol {
    var iconImage: Icon? { objectIconImage }
    var callout: String { "" }
    var typeId: String { "" }
    var shouldShowCallout: Bool { false }
    var verticalInset: CGFloat { 0 }
    var screenData: ScreenData { .editor(.recentOpen(spaceId: targetSpaceId)) }
    var shouldShowDescription: Bool { false }
    var descriptionTextColor: Color { Color.Text.primary }
    var descriptionFont: AnytypeFont { .relation3Regular}
}
