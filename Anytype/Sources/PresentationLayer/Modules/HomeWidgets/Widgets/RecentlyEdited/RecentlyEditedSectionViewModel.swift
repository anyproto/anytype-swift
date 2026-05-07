import Foundation
import SwiftUI
import Services

@MainActor
@Observable
final class RecentlyEditedSectionViewModel {

    @ObservationIgnored
    let listModel: RecentlyEditedListViewModel

    @ObservationIgnored
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol

    var isExpanded: Bool

    init(
        spaceId: String,
        output: (any CommonWidgetModuleOutput)?,
        onRowsCountChange: @escaping (Int) -> Void
    ) {
        self.listModel = RecentlyEditedListViewModel(
            spaceId: spaceId,
            onObjectSelected: { [weak output] details in
                output?.onObjectSelected(screenData: details.screenData())
            },
            onRowsCountChange: onRowsCountChange
        )
        // Default to true so users without persisted state see the section open.
        self.isExpanded = HomeSection.recentlyEdited.expandedStorageId
            .map { expandedService.isExpanded(id: $0, defaultValue: true) } ?? true
    }

    func startSubscriptions() async {
        await listModel.startSubscriptions()
    }

    func onTapHeader() {
        withAnimation { isExpanded.toggle() }
        if let id = HomeSection.recentlyEdited.expandedStorageId {
            expandedService.setState(id: id, isExpanded: isExpanded)
        }
    }
}
