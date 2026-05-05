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
        var isLocked: Bool { section.isLocked }
        var title: String { section.localizedTitle }
    }

    private let spaceId: String

    @ObservationIgnored
    @Injected(\.homeSectionsStorage)
    private var storage: any HomeSectionsStorageProtocol

    var rows: [Row] = []

    init(spaceId: String) {
        self.spaceId = spaceId
        let config = storage.configuration(spaceId: spaceId)
        let visibleSections = config.visibleSections
        let hiddenSections = HomeSection.allCases.filter { !visibleSections.contains($0) }
        let visibleRows = visibleSections.map { Row(section: $0, visible: true) }
        let hiddenRows = hiddenSections.map { Row(section: $0, visible: false) }
        self.rows = visibleRows + hiddenRows
        enforceLockedTop()
    }

    func onMove(from: IndexSet, to: Int) {
        rows.move(fromOffsets: from, toOffset: to)
        enforceLockedTop()
        persist()
    }

    func onToggle(section: HomeSection) {
        guard let index = rows.firstIndex(where: { $0.section == section }) else { return }
        guard !rows[index].isLocked else { return }
        rows[index].visible.toggle()
        persist()
    }

    private func enforceLockedTop() {
        if let pinnedIndex = rows.firstIndex(where: { $0.section == .pinned }), pinnedIndex != 0 {
            let row = rows.remove(at: pinnedIndex)
            rows.insert(row, at: 0)
        }
        if let unreadIndex = rows.firstIndex(where: { $0.section == .unread }) {
            let pinnedExists = rows.contains(where: { $0.section == .pinned })
            let target = pinnedExists ? 1 : 0
            if unreadIndex != target {
                let row = rows.remove(at: unreadIndex)
                rows.insert(row, at: target)
            }
        }
    }

    private func persist() {
        let visibleSections = rows.filter(\.visible).map(\.section)
        storage.setConfiguration(
            HomeSectionsConfiguration(visibleSections: visibleSections),
            spaceId: spaceId
        )
    }
}
