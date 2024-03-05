import Foundation
import SwiftUI

struct RelationsListCoordinatorView: View {
    
    @StateObject var model: RelationsListCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        model.relationsList()
            .sheet(item: $model.relationValueData) {
                model.relationValueCoordinator(data: $0)
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
