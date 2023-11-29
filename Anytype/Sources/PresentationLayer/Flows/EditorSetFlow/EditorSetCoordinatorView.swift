import Foundation
import SwiftUI

struct EditorSetCoordinatorView: View {
    
    @StateObject var model: EditorSetCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        model.setModule()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
