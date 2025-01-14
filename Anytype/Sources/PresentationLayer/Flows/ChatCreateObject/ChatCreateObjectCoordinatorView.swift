import Foundation
import SwiftUI

struct ChatCreateObjectCoordinatorView: View {
    
    @StateObject private var model: ChatCreateObjectCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pageNavigation) private var parentPageNavigation
    
    init(data: EditorScreenData) {
        self._model = StateObject(wrappedValue: ChatCreateObjectCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        EditorCoordinatorView(data: model.data)
            .onAppear {
                model.parentPageNavigation = parentPageNavigation
            }
            .task {
                await model.startSubscriptions()
            }
            .homeBottomPanelState(.constant(HomeBottomPanelState()))
            .environment(\.pageNavigation, model.pageNavigation)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    StandardButton(Loc.cancel, style: .secondaryLarge, action: {})
                    StandardButton(Loc.Chat.AttachedObject.attach, style: .primaryLarge, action: {})
                }
                .padding(16)
                .background(Color.Background.primary)
                .newDivider(alignment: .top)
            }
            .safeAreaInset(edge: .top) {
                DragIndicator()
            }
            .interactiveDismissDisabled(model.interactiveDismissDisable) {
                model.tryDismiss()
            }
            .anytypeSheet(isPresented: $model.dismissConfirmationAlert) {
                ChatCreateObjectDiscardAlert {
                    model.onConfirmDiscardChanges()
                }
            }
            .anytypeSheet(item: $model.openObjectConfirmationAlert) { item in
                ChatCreateObjectDiscardAlert {
                    model.openObjectConfirm(data: item)
                }
            }
    }
}
