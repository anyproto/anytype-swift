import Foundation
import SwiftUI

struct HomeWidgetsView: View {
    
    @ObservedObject var model: HomeWidgetsViewModel
    
    var body: some View {
        ZStack {
            Gradients.widgetsBackground()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(model.models, id: \.objectId) { model in
                        ObjectLintWidgetView(model: model)
                    }
                    Button("Show old home") {
                        model.onDisableNewHomeTap()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct HomeWidgetsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeWidgetsView(
            model: HomeWidgetsViewModel(
                widgeetObjectId: "",
                registry: HomeWidgetsRegistry(),
                output: nil
            )
        )
    }
}
