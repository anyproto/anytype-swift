import SwiftUI
import Amplitude


struct ObjectActionsView: View {
    let viewModel: ObjectActionsViewModel

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
//                        case .moveTo:
//                            viewModel.moveTo()
//                        case .template:
//                            viewModel.template()
//                        case .search:
//                            viewModel.search()
                        }
                    }
                }
            }
        }
        .frame(height: 108)
    }
}
