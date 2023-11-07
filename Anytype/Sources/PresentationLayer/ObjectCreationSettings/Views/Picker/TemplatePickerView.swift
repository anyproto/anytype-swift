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
            
            TabView(selection: $viewModel.selectedTab) {
                ForEach(viewModel.items) { item in
                    VStack(spacing: 0) {
                        switch item {
                        case .blank:
                            blankView
                        case let .template(model):
                            model.viewController
                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                    .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)
            
            button
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                closeButton
            }
            ToolbarItem(placement: .principal) {
                AnytypeText(
                    Loc.TemplateSelection.Available.title(viewModel.items.count),
                    style: .caption1Medium,
                    color: .Text.primary
                )
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                settingsButton
            }
        }
    }
    
    private var blankView: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(125)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    AnytypeText(Loc.BlockText.ContentType.Title.placeholder, style: .title, color: .Text.secondary)
                    AnytypeText(Loc.TemplateSelection.Template.subtitle, style: .relation2Regular, color: .Text.secondary)
                }
                Spacer()
            }
        }
        .padding([.horizontal], 20)
    }

    private func storyIndicatorView(isSelected: Bool) -> some View {
        Spacer
            .fixedHeight(4)
            .background(isSelected ? Color.Text.primary : Color.Stroke.primary)
            .cornerRadius(2)
            .frame(maxWidth: 20)
    }

    private var button: some View {
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
                .foregroundColor(.Button.active)
        }
    }
    
    private var settingsButton: some View {
        Button {
            viewModel.onSettingsButtonTap()
        } label: {
            Image(asset: .X24.more)
                .foregroundColor(.Button.active)
        }
    }
}
