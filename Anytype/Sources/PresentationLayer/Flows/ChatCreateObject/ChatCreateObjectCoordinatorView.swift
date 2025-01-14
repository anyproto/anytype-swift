import Foundation
import SwiftUI

struct ChatCreateObjectCoordinatorView: View {
    
    @StateObject private var model: ChatCreateObjectCoordinatorViewModel
    
    init(data: EditorScreenData) {
        self._model = StateObject(wrappedValue: ChatCreateObjectCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        EditorCoordinatorView(data: model.data)
            .homeBottomPanelState(.constant(HomeBottomPanelState()))
            .environment(\.pageNavigation, PageNavigation(open: { _ in }, pushHome: { }, pop: { }, popToFirstInSpace: {}, replace: { _ in }))
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    StandardButton(Loc.cancel, style: .secondaryLarge, action: {})
                    StandardButton(Loc.Chat.AttachedObject.attach, style: .primaryLarge, action: {})
                }
                .padding(16)
            }
            .safeAreaInset(edge: .top) {
                DragIndicator()
            }
    }
}
