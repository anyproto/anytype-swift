import Foundation
import SwiftUI

struct EditorPageView: View {
    
    @StateObject var model: EditorPageViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GenericUIKitToSwiftUIView(viewController: model.viewController)
            .navigationBarHidden(true)
            .homeBottomPanelHidden(model.bottomPanelHidden)
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
