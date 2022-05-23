import SwiftUI
import BlocksModels

final class TemplatePickerViewModel {
    struct Item: Identifiable {
        let id: Int
        let viewController: GenericUIKitToSwiftUIView
        let object: ObjectDetails
    }

    let items: [Item]
    private var selectedTab = 0
    private let document: BaseDocumentProtocol
    private let objectService: ObjectActionsServiceProtocol
    private let onSkip: () -> Void

    init(
        items: [Item],
        document: BaseDocumentProtocol,
        objectService: ObjectActionsServiceProtocol,
        onSkip: @escaping () -> Void
    ) {
        self.items = items
        self.document = document
        self.objectService = objectService
        self.onSkip = onSkip
    }

    func onTabChange(selectedTab: Int) {
        self.selectedTab = selectedTab
    }

    func onApplyButton() {
        let objectId = items[selectedTab].object.id
        objectService.applyTemplate(objectId: document.objectId, templateId: objectId)
        onSkip()
    }

    func onSkipButton() {
        onSkip()
    }
}

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
        AnytypeText("TemplatePicker.ChooseTemplate".localized, style: .caption1Medium, color: .primary)
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
            StandardButton(text: "TemplatePicker.Buttons.Skip".localized, style: .secondary) { [weak viewModel] in
                viewModel?.onSkipButton()
            }
            StandardButton(text: "TemplatePicker.Buttons.UseTemplate".localized, style: .primary) { [weak viewModel] in
                viewModel?.onApplyButton()
            }
            .buttonStyle(ShrinkingButtonStyle())
        }
        .padding([.horizontal], 19)
        .padding([.bottom], 16)
    }
}
