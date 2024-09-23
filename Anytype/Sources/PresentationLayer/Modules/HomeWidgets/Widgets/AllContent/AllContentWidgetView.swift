import Foundation
import SwiftUI

struct AllContentWidgetView: View {
    
    @StateObject private var model: AllContentWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(
        spaceId: String,
        homeState: Binding<HomeWidgetsState>,
        output: (any CommonWidgetModuleOutput)?
    ) {
        _homeState = homeState
        _model = StateObject(wrappedValue: AllContentWidgetViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        LinkWidgetViewContainer(
            title: Loc.allContent,
            icon: .Widget.allContent,
            isExpanded: .constant(false),
            dragId: nil,
            homeState: $homeState,
            allowMenuContent: false,
            allowContent: false,
            allowContextMenuItems: false,
            headerAction: {
                model.onTapWidget()
            },
            removeAction: nil,
            content: { EmptyView() }
        )
    }
}
