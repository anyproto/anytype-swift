import Foundation
import SwiftUI

struct ChatCreateObjectCoordinatorView: View {
    
    @StateObject private var model: ChatCreateObjectCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pageNavigation) private var parentPageNavigation
    
    @State private var topInset: CGFloat = 0
    @State private var bottomInset: CGFloat = 0
    
    init(data: EditorScreenData) {
        self._model = StateObject(wrappedValue: ChatCreateObjectCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        EditorCoordinatorView(data: model.data)
            .onAppear {
                model.parentPageNavigation = parentPageNavigation
                model.dismiss = dismiss
            }
            .task {
                await model.startSubscriptions()
            }
            .homeBottomPanelState(.constant(HomeBottomPanelState()))
            .pageNavigation(model.pageNavigation)
            .pageEditorAdditionalSafeAreaInsets(UIEdgeInsets(top: topInset, left: 0, bottom: 80, right: 0))
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    StandardButton(Loc.cancel, style: .secondaryLarge, action: {
                        model.onTapCacel()
                    })
                    StandardButton(Loc.Chat.AttachedObject.attach, style: .primaryLarge, action: {
                        model.onTapAttach()
                    })
                }
                .padding(16)
                .background(Color.Background.primary)
                .newDivider(alignment: .top)
                .readSize {
                    bottomInset = $0.height
                }
            }
            .safeAreaInset(edge: .top) {
                DragIndicator()
                    .readSize {
                        topInset = $0.height
                    }
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
