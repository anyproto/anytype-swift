import Foundation
import SwiftUI
import Services

struct SpaceShareCoordinatorView: View {
    
    @StateObject private var model: SpaceShareCoordinatorViewModel
    
    init(data: SpaceShareData) {
        self._model = StateObject(wrappedValue: SpaceShareCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SpaceShareView(data: model.data) {
            model.onMoreInfoSelected()
        }
        .sheet(isPresented: $model.showMoreInfo) {
            SpaceMoreInfoView()
        }
    }
}
