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
            case .basic, .set, .collection, .file, .image, .chat:
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
                if FeatureFlags.newTypeIcons {
                    ObjectTypeIconPicker(
                        isRemoveButtonAvailable: viewModel.isRemoveButtonAvailable,
                        onIconSelect: { _ in
                            // TBD;
                        }, removeIcon: {
                            viewModel.removeIcon()
                        })
                } else {
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
                }
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
            case .todo, .note, .bookmark, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList, .audio, .video, .pdf, .date, .space, .spaceView, .tag, .chatDerived:
                EmptyView()
                    .onAppear {
                        anytypeAssertionFailure("Not supported layout")
                    }
            }
        }
    }
}
