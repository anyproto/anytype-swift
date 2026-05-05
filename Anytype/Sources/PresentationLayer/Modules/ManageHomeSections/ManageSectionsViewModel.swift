import Foundation
import SwiftUI
import AnytypeCore

@MainActor
@Observable
final class ManageSectionsViewModel {

    struct Row: Identifiable {
        let section: HomeSection
        var visible: Bool
        var id: HomeSection { section }
    }

    private let spaceId: String

    @ObservationIgnored
    @Injected(\.homeSectionsStorage)
    private var storage: any HomeSectionsStorageProtocol

    let lockedSections: [HomeSection] = HomeSection.lockedSections
    var rows: [Row] = []

    init(spaceId: String) {
        self.spaceId = spaceId
        let config = storage.configuration(spaceId: spaceId)
        let visible = config.visibleSections.filter { !$0.isLocked }
        let hidden = HomeSection.allCases.filter { !$0.isLocked && !visible.contains($0) }
        self.rows = (visible + hidden).map { Row(section: $0, visible: visible.contains($0)) }
    }

    func onMove(from: IndexSet, to: Int) {
        rows.move(fromOffsets: from, toOffset: to)
        persist()
    }

    func onToggle(section: HomeSection) {
        guard let index = rows.firstIndex(where: { $0.section == section }) else { return }
        rows[index].visible.toggle()
        persist()
    }

    private func persist() {
        let visible = HomeSection.lockedSections + rows.filter(\.visible).map(\.section)
        storage.setConfiguration(
            HomeSectionsConfiguration(visibleSections: visible),
            spaceId: spaceId
        )
    }
}
