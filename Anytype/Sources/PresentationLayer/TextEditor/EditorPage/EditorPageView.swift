import Foundation
import SwiftUI

struct EditorPageView: View {
    
    @StateObject var model: EditorPageViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        editor
            .anytypeStatusBar(style: .default)
            .homeBottomPanelHidden(model.bottomPanelHidden, animated: model.bottomPanelHiddenAnimated)
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .anytypeSheet(isPresented: $model.showUpdateAlert, onDismiss: { dismiss() }) {
                DocumentUpdateAlertView { dismiss() }
            }
            .anytypeSheet(isPresented: $model.showCommonOpenError, onDismiss: { dismiss() }) {
                DocumentCommonOpenErrorView { dismiss() }
            }
    }
    
    @ViewBuilder
    private var editor: some View {
        if let viewController = model.viewController {
            GenericUIKitToSwiftUIView(viewController: viewController)
        }
    }
}
