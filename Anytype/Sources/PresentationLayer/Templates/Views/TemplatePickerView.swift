import SwiftUI

struct TemplatePickerView: View {
    let viewModel: TemplatePickerViewModel

    @State private var index: Int = 0

    var body: some View {
        Spacer
            .fixedHeight(8)
        HStack(spacing: 4) {
            ForEach(viewModel.items) {
                storyIndicatorView(isSelected: $0.id == viewModel.items[index].id)
            }
        }
        .padding([.horizontal], 16)
        Spacer.fixedHeight(11)
        AnytypeText(Loc.TemplatePicker.chooseTemplate, style: .caption1Medium, color: .primary)
            .frame(alignment: .center)

        TabView(selection: $index) {
            ForEach(viewModel.items) { item in
                VStack() {
                    item.viewController
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .tag(item.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxHeight: .infinity)
        .onChange(of: index) { tab in
            viewModel.onTabChange(selectedTab: tab)
        }

        buttons
    }

    func storyIndicatorView(isSelected: Bool) -> some View {
        Spacer
            .fixedHeight(4)
            .background(isSelected ? Color.textPrimary : Color.strokePrimary)
            .cornerRadius(2)
            .frame(maxWidth: .infinity)
    }

    var buttons: some View {
        HStack(spacing: 10) {
            StandardButton(text: Loc.TemplatePicker.Buttons.skip, style: .secondary) { [weak viewModel] in
                viewModel?.onSkipButton()
            }
            StandardButton(text: Loc.TemplatePicker.Buttons.useTemplate, style: .primary) { [weak viewModel] in
                viewModel?.onApplyButton()
            }
            .buttonStyle(ShrinkingButtonStyle())
        }
        .padding([.horizontal], 19)
        .padding([.bottom], 16)
    }
}
