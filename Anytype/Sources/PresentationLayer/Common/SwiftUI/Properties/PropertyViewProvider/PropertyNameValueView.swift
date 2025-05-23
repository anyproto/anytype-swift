import SwiftUI

final class PropertyNameValueViewModel: ObservableObject {
    @Published var property: PropertyItemModel
    @Published var isHighlighted: Bool = false

    var action: (() -> Void)?

    init(property: PropertyItemModel, action: @escaping () -> Void) {
        self.property = property
        self.action = action
    }
}

struct PropertyNameValueView: View {
    @ObservedObject var viewModel: PropertyNameValueViewModel
    var isEditable: Bool = false
    var onEditTap: ((String) -> ())? = nil

    @State private var width: CGFloat = .zero
    @State private var height: CGFloat = .zero

    var body: some View {
        HStack(spacing: 8) {
            name
                .frame(width: nameWidth, alignment: .topLeading)
            Spacer.fixedWidth(8)

            Group {
                if isEditable, viewModel.property.isEditable {
                    valueViewButton
                } else {
                    valueView
                }
            }
            .frame(maxWidth: .infinity, minHeight: 34, alignment: .center)
            .readSize { height = $0.height }
        }
        .readSize { width = $0.width }
    }
    
    private var nameWidth: CGFloat { width * 0.4 }

    private var name: some View {
        AnytypeText(viewModel.property.name, style: .relation1Regular)
                .foregroundColor(.Text.secondary).lineLimit(1)
    }

    private var valueViewButton: some View {
        Button {
            onEditTap?(viewModel.property.key)
        } label: {
            valueView
        }
    }

    private var valueView: some View {
        PropertyValueView(
            model: PropertyValueViewModel(
                property: viewModel.property,
                style: .regular(allowMultiLine: false),
                mode: .button(action: viewModel.action)
            )
        )
    }
}
