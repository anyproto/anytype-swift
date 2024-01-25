import Foundation
import SwiftUI

struct SelectRelationListCoordinatorView: View {
    
    @StateObject var model: SelectRelationListCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.selectRelationListModule()
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
