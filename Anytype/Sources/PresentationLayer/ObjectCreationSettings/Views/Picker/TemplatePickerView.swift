import SwiftUI

struct TemplatePickerView: View {
    @StateObject var viewModel: TemplatePickerViewModel

    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(6)
            
            HStack(spacing: 4) {
                ForEach(viewModel.items) {
                    storyIndicatorView(isSelected: $0.id == viewModel.selectedItem().id)
                }
            }
            .padding([.horizontal], 16)
            
            Spacer.fixedHeight(6)
            
            if #available(iOS 16.4, *) {
                contentView
            } else {
                if viewModel.items.isNotEmpty {
                    contentView
                } else {
                    Spacer()
                }
            }
            
            if viewModel.showApplyButton {
                applyButton
            }
        }
        .task {
            await viewModel.startTemplateSubscription()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .principal) {
                AnytypeText(
                    Loc.TemplateSelection.Available.title(viewModel.items.count),
                    style: .caption1Medium
                )
                .foregroundColor(.Text.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                settingsButton
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(viewModel.items) { item in
                item.view
                    .tag(item.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxHeight: .infinity)
    }

    private func storyIndicatorView(isSelected: Bool) -> some View {
        Spacer
            .fixedHeight(4)
            .background(isSelected ? Color.Text.primary : Color.Shape.primary)
            .cornerRadius(2)
            .frame(maxWidth: 20)
    }

    private var applyButton: some View {
        StandardButton(Loc.TemplateSelection.selectTemplate, style: .primaryLarge) { [weak viewModel] in
            viewModel?.onApplyButton()
        }
        .padding([.horizontal], 20)
        .padding([.bottom], 10)
    }
    
    private var closeButton: some View {
        Button {
            viewModel.onCloseButtonTap()
        } label: {
            Image(asset: .X24.close)
                .foregroundColor(.Control.active)
        }
    }
    
    private var settingsButton: some View {
        Button {
            viewModel.onSettingsButtonTap()
        } label: {
            Image(asset: .X24.more)
                .foregroundColor(.Control.active)
        }
    }
}
