import SwiftUI
import AnytypeCore

struct ObjectActionsView: View {
    
    @StateObject private var viewModel: ObjectActionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(objectId: String, spaceId: String, output: (any ObjectActionsOutput)?) {
        self._viewModel = StateObject(wrappedValue: ObjectActionsViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(viewModel.objectActions) { setting in
                    ObjectActionRow(setting: setting) {
                        switch setting {
                        case .archive:
                            try await viewModel.changeArchiveState()
                        case .pin:
                            try await viewModel.changePinState()
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
                        case .templateToggleDefaultState:
                            try await viewModel.templateToggleDefaultState()
                        case .delete:
                            try await viewModel.deleteAction()
                        case .createWidget:
                            try await viewModel.createWidget()
                        case .copyLink:
                            try await viewModel.copyLinkAction()
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
