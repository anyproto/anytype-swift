import Foundation
import SwiftUI

struct AllContentWidgetView: View {
    
    @StateObject private var model: AllContentWidgetViewModel
    @Binding var homeState: HomeWidgetsState
    
    init(homeState: Binding<HomeWidgetsState>, onWidgetTap: @escaping () -> Void) {
        _homeState = homeState
        _model = StateObject(wrappedValue: AllContentWidgetViewModel(onWidgetTap: onWidgetTap))
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
            headerAction: {
                model.onTapWidget()
            },
            removeAction: nil,
            content: { EmptyView() }
        )
    }
}
