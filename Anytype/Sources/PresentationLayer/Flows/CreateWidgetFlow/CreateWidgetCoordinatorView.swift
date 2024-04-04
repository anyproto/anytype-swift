import Foundation
import SwiftUI

struct CreateWidgetCoordinatorView: View {
    
    @StateObject var model: CreateWidgetCoordinatorViewModel
    @Environment(\.presentationMode) @Binding var presentationMode
    
    var body: some View {
        model.makeWidgetSourceModule()
        .sheet(item: $model.showWidgetTypeData) {
            WidgetTypeCreateObjectView(data: $0)
        }
        .onChange(of: model.dismiss) { _ in
            presentationMode.dismiss()
        }
    }
}
