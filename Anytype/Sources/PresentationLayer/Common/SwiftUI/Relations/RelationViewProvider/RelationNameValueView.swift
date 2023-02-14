import SwiftUI

class RelationNameValueViewModel: ObservableObject {
    @Published var relation: RelationItemModel
    @Published var isHighlighted: Bool = false

    var action: (() -> Void)?

    init(relation: RelationItemModel, action: @escaping () -> Void) {
        self.relation = relation
        self.action = action
    }
}

struct RelationNameValueView: View {
    @ObservedObject var viewModel: RelationNameValueViewModel
    var isEditable: Bool = false
    var onEditTap: ((String) -> ())? = nil
    var showDivider: Bool = true

    @State private var width: CGFloat = .zero
    @State private var height: CGFloat = .zero

    var body: some View {
        HStack(spacing: 8) {
            name
                .frame(width: nameWidth, alignment: .topLeading)
            Spacer.fixedWidth(8)

            Group {
                if isEditable, viewModel.relation.isEditable {
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
        AnytypeText(viewModel.relation.name, style: .relation1Regular, color: .Text.secondary).lineLimit(1)
    }

    private var valueViewButton: some View {
        Button {
            onEditTap?(viewModel.relation.key)
        } label: {
            valueView
        }
    }

    private var valueView: some View {
        RelationValueView(relation: viewModel.relation, style: .regular(allowMultiLine: false), action: viewModel.action)
    }
}
