import Foundation
import SwiftUI
import Services

struct SpaceShareCoordinatorView: View {
    
    @StateObject private var model: SpaceShareCoordinatorViewModel
    
    init(workspaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: SpaceShareCoordinatorViewModel(workspaceInfo: workspaceInfo))
    }
    
    var body: some View {
        SpaceShareView(workspaceInfo: model.workspaceInfo) {
            model.onMoreInfoSelected()
        }
        .sheet(isPresented: $model.showMoreInfo) {
            SpaceMoreInfoView()
        }
    }
}
