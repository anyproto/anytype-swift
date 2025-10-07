import Foundation
import SwiftUI

struct EditorPageView: View {
    
    @StateObject private var stateModel: EditorPageViewState
    @Environment(\.dismiss) private var dismiss
    
    private var model: EditorPageViewModel { stateModel.model }
    
    init(data: EditorPageObject, output: (any EditorPageModuleOutput)?, showHeader: Bool) {
        self._stateModel = StateObject(
            wrappedValue: Container.shared.legacyEditorPageModuleAssembly().buildStateModel(data: data, output: output, showHeader: showHeader)
        )
    }
    
    var body: some View {
        EditorSwiftUIViewContainer(viewController: stateModel.viewController)
            .anytypeStatusBar(style: .default)
            .homeBottomPanelHidden(model.bottomPanelHidden, animated: model.bottomPanelHiddenAnimated)
            .onChange(of: model.dismiss) {
                dismiss()
            }
            .anytypeSheet(isPresented: $stateModel.model.showUpdateAlert, onDismiss: { dismiss() }) {
                DocumentUpdateAlertView { dismiss() }
            }
            .anytypeSheet(isPresented: $stateModel.model.showCommonOpenError, onDismiss: { dismiss() }) {
                DocumentCommonOpenErrorView { dismiss() }
            }
    }
}
