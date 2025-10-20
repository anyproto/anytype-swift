import SwiftUI
import AnytypeCore

struct ObjectIconPicker: View {
    
    @StateObject var viewModel: ObjectIconPickerViewModel
    
    init(data: ObjectIconPickerData) {
        self._viewModel = StateObject(wrappedValue: ObjectIconPickerViewModel(data: data))
    }
    
    var body: some View {
        Group {
            switch viewModel.detailsLayout {
            case .basic, .set, .collection, .file, .image, .chatDerived:
                ObjectBasicIconPicker(
                    isRemoveButtonAvailable: viewModel.isRemoveButtonAvailable,
                    mediaPickerContentType: viewModel.mediaPickerContentType,
                    onSelectItemProvider: { itemProvider in
                        viewModel.uploadImage(from: itemProvider)
                    },
                    onSelectEmoji: { emoji in
                        viewModel.setEmoji(emoji.emoji)
                    },
                    removeIcon: {
                        viewModel.removeIcon()
                    }
                )
            case .objectType:
                ObjectTypeIconPicker(
                    isRemoveButtonAvailable: viewModel.isRemoveButtonAvailable,
                    onIconSelect: { icon, color in
                        viewModel.setIcon(icon, color: color)
                    }, removeIcon: {
                        viewModel.removeIcon()
                    })
            case .profile, .participant:
                ObjectProfileIconPicker(
                    isRemoveEnabled: viewModel.isRemoveEnabled,
                    mediaPickerContentType: viewModel.mediaPickerContentType,
                    onSelectItemProvider: { itemProvider in
                        viewModel.uploadImage(from: itemProvider)
                    },
                    removeIcon: {
                        viewModel.removeIcon()
                    }
                )
            case nil:
                EmptyView()
            case .todo, .note, .bookmark, .UNRECOGNIZED, .relation, .relationOption,
                    .dashboard, .relationOptionsList, .audio, .video, .pdf, .date, .space,
                    .spaceView, .tag, .chat, .notification, .missingObject, .devices:
                EmptyView()
                    .onAppear {
                        anytypeAssertionFailure("Not supported layout")
                    }
            }
        }
    }
}
