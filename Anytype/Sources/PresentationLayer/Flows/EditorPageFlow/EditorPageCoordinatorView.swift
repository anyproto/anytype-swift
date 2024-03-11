import Foundation
import SwiftUI

struct EditorPageCoordinatorView: View {
    
    @StateObject var model: EditorPageCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        model.pageModule()
            .ignoresSafeArea()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .sheet(item: $model.relationValueData) { data in
                model.relationValueCoordinator(data: data)
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
}
