import SwiftUI


struct ObjectActionsView: View {
    
    @ObservedObject var viewModel: ObjectActionsViewModel
 
    var body: some View {
        if viewModel.objectActions.isEmpty {
            EmptyView()
        } else {
            content
        }
    }
    
    var content: some View {
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
                        case .undoRedo:
                            viewModel.undoRedoAction()
                        case .duplicate:
                            viewModel.duplicateAction()
                        case .linkItself:
                            viewModel.linkItselfAction()
                        case .makeAsTemplate:
                            viewModel.makeAsTempalte()
                        case .templateSetAsDefault:
                            viewModel.makeTemplateAsDefault()
                        case .delete:
                            viewModel.deleteAction()
                        case .createWidget:
                            viewModel.createWidget()
                        case .copyLink:
                            viewModel.copyLinkAction()
                        }
                    }
                }
            }.padding(.horizontal, 16)
        }
        .frame(height: 108)
        .snackbar(toastBarData: $viewModel.toastData)
    }
}
