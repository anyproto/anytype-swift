import Foundation
import SwiftUI

struct RelationValueCoordinatorView: View {
    
    @StateObject private var model: RelationValueCoordinatorViewModel
    
    init(data: RelationValueData, output: RelationValueCoordinatorOutput?) {
        _model = StateObject(wrappedValue: RelationValueCoordinatorViewModel(data: data, output: output))
    }
    
    var body: some View {
        content
            .if(model.mediumDetent) {
                $0.mediumPresentationDetents()
            }
            .snackbar(toastBarData: $model.toastBarData)
            .openUrl(url: $model.safariUrl)
    }
    
    private var content: some View {
        model.relationModule()
    }
}
