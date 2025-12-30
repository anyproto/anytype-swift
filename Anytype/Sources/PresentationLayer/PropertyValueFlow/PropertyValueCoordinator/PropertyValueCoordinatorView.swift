import Foundation
import SwiftUI

struct PropertyValueCoordinatorView: View {

    @State private var model: PropertyValueCoordinatorViewModel

    init(data: PropertyValueData, output: (any PropertyValueCoordinatorOutput)?) {
        _model = State(initialValue: PropertyValueCoordinatorViewModel(data: data, output: output))
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
        model.propertyModule()
    }
}
