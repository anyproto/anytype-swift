import SwiftUI


struct ObjectActionsView: View {
    
    @ObservedObject var viewModel: ObjectActionsViewModel
 
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(viewModel.objectActions) { setting in
                    ObjectActionRow(setting: setting) {
                        switch setting {
                        case .archive:
                            viewModel.changeArchiveState()
                        case .favorite:
                            viewModel.changeFavoriteSate()
                        case .locked:
                            viewModel.changeLockState()
                        }
                    }
                }
            }
        }
        .frame(height: 108)
    }
}
