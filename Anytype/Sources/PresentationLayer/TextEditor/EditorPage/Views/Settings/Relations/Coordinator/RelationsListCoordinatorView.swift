import Foundation
import SwiftUI

struct RelationsListCoordinatorView: View {
    
    @StateObject var model: RelationsListCoordinatorViewModel
    
    var body: some View {
        model.relationsList()
            .sheet(item: $model.relationValueData) {
                model.relationValueCoordinator(data: $0)
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
}
