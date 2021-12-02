import SwiftUI

class RelationNameValueViewModel: ObservableObject {
    @Published var relation: Relation

    init(relation: Relation) {
        self.relation = relation
    }
}

struct RelationNameValueView: View {
    @ObservedObject var viewModel: RelationNameValueViewModel
    var isEditable: Bool = false
    var onEditTap: ((String) -> ())? = nil

    @State private var width: CGFloat = .zero
    @State private var height: CGFloat = .zero


    var body: some View {
        HStack(spacing: 8) {
            name
                .frame(width: width * 0.4, alignment: .leading)
            Spacer.fixedWidth(8)

            Group {
                if isEditable, viewModel.relation.isEditable {
                    valueViewButton
                } else {
                    valueView
                }
            }
            .background(FrameCatcher { height = $0.size.height })

//            Spacer(minLength: 8)
        }
        //                .modifier(DividerModifier(spacing:0))
        .background(FrameCatcher { width = $0.size.width })
        .frame(height: 48)
    }

    private var name: some View {
        AnytypeText(viewModel.relation.name, style: .relation1Regular, color: .textSecondary).lineLimit(1)
    }

    private var valueViewButton: some View {
        Button {
            onEditTap?(viewModel.relation.id)
        } label: {
            valueView
        }
    }

    private var valueView: some View {
        HStack(spacing: 0) {
            RelationValueView(relation: viewModel.relation, style: .regular(allowMultiLine: false))
            Spacer()
        }
    }
}

struct RelationNameValueView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation(
                    id: "1", name: "Relation name",
                    value: .tag([
                        TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                        TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                        TagRelationValue(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                        TagRelationValue(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
                    ]),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: true
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation(
                    id: "1", name: "Relation name",
                    value: .text("hello"),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: false
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
        }
    }
}
