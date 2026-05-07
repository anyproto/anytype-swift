import Foundation
import SwiftUI
import Services

@MainActor
@Observable
final class MyFavoritesSectionViewModel {

    @ObservationIgnored
    let listModel: MyFavoritesListViewModel

    @ObservationIgnored
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol

    var isExpanded: Bool = true

    init(
        spaceId: String,
        personalWidgetsObject: any BaseDocumentProtocol,
        channelWidgetsObject: any BaseDocumentProtocol,
        output: (any CommonWidgetModuleOutput)?,
        onRowsCountChange: @escaping (Int) -> Void
    ) {
        self.listModel = MyFavoritesListViewModel(
            spaceId: spaceId,
            personalWidgetsObject: personalWidgetsObject,
            channelWidgetsObject: channelWidgetsObject,
            onObjectSelected: { [weak output] details in
                output?.onObjectSelected(screenData: details.screenData())
            },
            onRowsCountChange: onRowsCountChange
        )
        // Default to true so users without persisted state see the section open.
        self.isExpanded = expandedService.isExpanded(section: .myFavorites, defaultValue: true)
    }

    func startSubscriptions() async {
        await listModel.startSubscriptions()
    }

    func onTapHeader() {
        withAnimation { isExpanded.toggle() }
        expandedService.setState(section: .myFavorites, isExpanded: isExpanded)
    }
}
