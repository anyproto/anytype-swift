import Foundation
import SwiftUI

struct SpaceChatWidgetView: View {
    
    @StateObject private var model: SpaceChatWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(spaceId: String, homeState: Binding<HomeWidgetsState>, output: (any CommonWidgetModuleOutput)?) {
        self._homeState = homeState
        self._model = StateObject(wrappedValue: SpaceChatWidgetViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        LinkWidgetViewContainer(
            title: Loc.chat,
            icon: .X24.chat,
            isExpanded: .constant(false),
            dragId: nil,
            homeState: $homeState,
            allowMenuContent: false,
            allowContent: false,
            headerAction: {
                model.onHeaderTap()
            },
            removeAction: nil,
            menu: { },
            content: { EmptyView() }
        )
    }
}
