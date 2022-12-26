import Foundation
import SwiftUI

struct HomeWidgetsView: View {
    
    @ObservedObject var model: HomeWidgetsViewModel
    
    var body: some View {
        ZStack {
            Gradients.widgetsBackground()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(model.models, id: \.componentId) { model in
                        model.view
                    }
                    Button("Show old home") {
                        model.onDisableNewHomeTap()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
}

struct HomeWidgetsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeWidgetsView(
            model: HomeWidgetsViewModel(
                widgetObject: HomeWidgetsObject(objectId: ""),
                registry: DI.makeForPreview().serviceLocator.homeWidgetsRegistry(),
                blockWidgetService: DI.makeForPreview().serviceLocator.blockWidgetService(),
                output: nil
            )
        )
    }
}
