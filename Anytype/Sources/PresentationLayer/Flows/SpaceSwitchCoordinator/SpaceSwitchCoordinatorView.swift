import Foundation
import SwiftUI

struct SpaceSwitchCoordinatorView: View {
    
    @StateObject var model: SpaceSwitchCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.spaceSwitchModule()
            .sheet(isPresented: $model.showSpaceCreate) {
                model.spaceCreateModule()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
