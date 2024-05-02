import Foundation
import SwiftUI

struct RelationValueCoordinatorView: View {
    
    @StateObject var model: RelationValueCoordinatorViewModel
    
    var body: some View {
        content
            .if(model.mediumDetent) {
                $0.mediumPresentationDetents()
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
    
    private var content: some View {
        model.relationModule()
    }
}
