import Foundation
import SwiftUI

struct EditorPageView: View {
    
    @StateObject var model: EditorPageViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GenericUIKitToSwiftUIView(viewController: model.viewController)
            .navigationBarHidden(true)
            .anytypeStatusBar(style: .default)
            .homeBottomPanelHidden(model.bottomPanelHidden, animated: model.bottomPanelHiddenAnimated)
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
