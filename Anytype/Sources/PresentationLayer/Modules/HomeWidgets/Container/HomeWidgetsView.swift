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
            VStack {
                Spacer()
                HomeWidgetsBottomPanelView(model: HomeWidgetsBottomPanelViewModel(buttons: [
                    HomeWidgetsBottomPanelViewModel.Button(id: "1", image: .Widget.search, onTap: {
                        print("on tap search")
                    }),
                    HomeWidgetsBottomPanelViewModel.Button(id: "2", image: .Widget.add, onTap: {
                       print("on tap new")
                    }),
                    HomeWidgetsBottomPanelViewModel.Button(id: "3", image: .Widget.add, onTap: {
                      print("on tap space")
                   })
                ]))
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
                widgetObject: HomeWidgetsObject(
                    objectId: "",
                    objectDetailsStorage: DI.makeForPreview().serviceLocator.objectDetailsStorage()
                ),
                registry: DI.makeForPreview().widgetsDI.homeWidgetsRegistry(),
                blockWidgetService: DI.makeForPreview().serviceLocator.blockWidgetService(),
                output: nil
            )
        )
    }
}
