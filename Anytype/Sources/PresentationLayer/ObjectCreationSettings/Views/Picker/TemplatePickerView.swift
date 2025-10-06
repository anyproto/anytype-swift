import SwiftUI

struct TemplatePickerView: View {
    @StateObject var viewModel: TemplatePickerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(.stack)
        .task {
            await viewModel.startTemplateSubscription()
        }
        .onAppear {
            AnytypeAnalytics.instance().logScreenTemplateSelector()
            viewModel.setDismissAction(dismiss)
        }
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

            contentView

            if viewModel.showApplyButton {
                applyButton
            }
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
                .foregroundColor(.Control.secondary)
        }
    }
    
    private var settingsButton: some View {
        Button {
            viewModel.onSettingsButtonTap()
        } label: {
            Image(asset: .X24.more)
                .foregroundColor(.Control.secondary)
        }
    }
}
