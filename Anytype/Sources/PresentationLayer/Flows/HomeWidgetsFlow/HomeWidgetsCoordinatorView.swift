import Foundation
import SwiftUI

struct HomeWidgetsCoordinatorView: View {
    
    @StateObject var model: HomeWidgetsCoordinatorViewModel
    
    var body: some View {
        VStack {
            model.homeWidgetsModule()
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .offset(x: -100)))
        }
        .animation(.default, value: model.homeAnimationId)
        .onAppear {
            model.onAppear()
        }
        .sheet(item: $model.showChangeSourceData) { data in
            model.changeSourceModule(data: data)
        }
        .sheet(item: $model.showChangeTypeData) { data in
            model.changeTypeModule(data: data)
        }
        .sheet(item: $model.showSearchData) { data in
            model.searchModule(data: data)
        }
        .sheet(item: $model.showCreateWidgetData) { data in
            model.createWidgetModule(data: data)
        }
        .sheet(isPresented: $model.showSpaceSwitch) {
            model.createSpaceSwitchModule()
        }
    }
}
