import Foundation
import SwiftUI

struct HomeWidgetsView: View {
    
    @ObservedObject var model: HomeWidgetsViewModel
    
    var body: some View {
        ZStack {
            Gradients.widgetsBackground()
            Button("Show old home") {
                model.onDisableNewHomeTap()
            }
        }
    }
}

struct HomeWidgetsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeWidgetsView(
            model: HomeWidgetsViewModel(
                widgeetObjectId: "",
                output: nil,
                navigationContext: DI.makeForPreview().uihelpersDI.commonNavigationContext
            )
        )
    }
}
