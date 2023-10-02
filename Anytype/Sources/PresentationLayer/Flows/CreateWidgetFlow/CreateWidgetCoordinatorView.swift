import Foundation
import SwiftUI

struct CreateWidgetCoordinatorView: View {
    
    @StateObject var model: CreateWidgetCoordinatorViewModel
    @Environment(\.presentationMode) @Binding var presentationMode
    
    var body: some View {
        model.makeWidgetSourceModule()
        .sheet(item: $model.showWidgetTypeData) { data in
            model.makeWidgetTypeModule(data: data)
        }
        .onChange(of: model.dismiss) { _ in
            presentationMode.dismiss()
        }
    }
}
