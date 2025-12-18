import Foundation
import SwiftUI
import AnytypeCore
import DesignKit

struct ChatCreateView: View {

    @State private var model: ChatCreateViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pageNavigation) private var pageNavigation

    init(data: ChatCreateScreenData) {
        _model = State(wrappedValue: ChatCreateViewModel(data: data))
    }

    var body: some View {
        content
            .onAppear {
                model.pageNavigation = pageNavigation
                model.onAppear()
            }
            .onChange(of: model.dismiss) {
                dismiss()
            }
            .sheet(item: $model.iconPickerData) { data in
                ObjectBasicIconPicker(
                    isRemoveButtonAvailable: data.iconSelection != nil,
                    mediaPickerContentType: .images,
                    onSelectItemProvider: { itemProvider in
                        model.onSelectItemProvider(itemProvider)
                    },
                    onSelectEmoji: { emoji in
                        model.onSelectEmoji(emoji)
                    },
                    removeIcon: {
                        model.onRemoveIcon()
                    }
                )
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.createChat)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    iconSection

                    FramedTextField(
                        placeholder: Loc.Chat.Create.namePlaceholder,
                        axis: .vertical,
                        text: $model.chatName
                    )
                }
            }
            .safeAreaInset(edge: .bottom) {
                StandardButton(
                    model: StandardButtonModel(
                        text: Loc.create,
                        inProgress: model.createLoadingState,
                        style: .primaryLarge,
                        action: { model.onTapCreate() }
                    )
                )
                .disabled(model.chatName.isEmpty)
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.Background.primary)
        .snackbar(toastBarData: $model.toastBarData)
    }

    private var iconSection: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(8)
            IconView(icon: model.chatIcon)
                .frame(width: 96, height: 96)
                .overlay(alignment: .bottomTrailing) {
                    editIconButton
                }
            Spacer.fixedHeight(20)
        }
        .fixTappableArea()
        .onTapGesture {
            model.onIconTapped()
        }
    }

    private var editIconButton: some View {
        Circle()
            .fill(Color.Background.primary)
            .frame(width: 28, height: 28)
            .overlay {
                Image(asset: .X24.edit)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(Color.Text.primary)
            }
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}
