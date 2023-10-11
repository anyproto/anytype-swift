import SwiftUI

struct TemplatePickerView: View {
    let viewModel: TemplatePickerViewModel

    @State private var index: Int = 0

    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(.stack)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(6)
            
            HStack(spacing: 4) {
                ForEach(viewModel.items) {
                    storyIndicatorView(isSelected: $0.id == viewModel.items[index].id)
                }
            }
            .padding([.horizontal], 16)
            
            Spacer.fixedHeight(6)
            
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
        }
    }

    func storyIndicatorView(isSelected: Bool) -> some View {
        Spacer
            .fixedHeight(4)
            .background(isSelected ? Color.Text.primary : Color.Stroke.primary)
            .cornerRadius(2)
            .frame(maxWidth: 20)
    }

    private var button: some View {
        StandardButton(Loc.TemplateEditing.selectButtonTitle, style: .primaryLarge) { [weak viewModel] in
            viewModel?.onApplyButton()
        }
        .padding([.horizontal], 20)
        .padding([.bottom], 10)
    }
    
    private var closeButton: some View {
        Button {
            viewModel.onCloseButton()
        } label: {
            Image(asset: .X24.close)
                .foregroundColor(.Button.active)
        }
    }
}
