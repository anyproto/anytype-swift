import Foundation
import SwiftUI

struct RelationValueCoordinatorView: View {
    
    @StateObject var model: RelationValueCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        model.relationModule()
            .if(model.mediumDetent) {
                $0.mediumPresentationDetents()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
