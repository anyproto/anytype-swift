import SwiftUI

struct ObjectActionsView: View {
    
    @StateObject private var viewModel: ObjectActionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(objectId: String, output: ObjectActionsOutput?) {
        self._viewModel = StateObject(wrappedValue: ObjectActionsViewModel(objectId: objectId, output: output))
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(viewModel.objectActions) { setting in
                    ObjectActionRow(setting: setting) {
                        switch setting {
                        case .archive:
                            try await viewModel.changeArchiveState()
                        case .favorite:
                            try await viewModel.changeFavoriteSate()
                        case .locked:
                            try await viewModel.changeLockState()
                        case .undoRedo:
                            viewModel.undoRedoAction()
                        case .duplicate:
                            try await viewModel.duplicateAction()
                        case .linkItself:
                            viewModel.linkItselfAction()
                        case .makeAsTemplate:
                            try await viewModel.makeAsTempalte()
                        case .templateSetAsDefault:
                            viewModel.makeTemplateAsDefault()
                        case .delete:
                            try await viewModel.deleteAction()
                        case .createWidget:
                            try await viewModel.createWidget()
                        case .copyLink:
                            viewModel.copyLinkAction()
                        }
                    }
                }
            }.padding(.horizontal, 16)
        }
        .snackbar(toastBarData: $viewModel.toastData)
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
        .task {
            await viewModel.startDocumentTask()
        }
    }
}
