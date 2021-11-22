import SwiftUI

struct FlowRelationsView: View {
    @StateObject var viewModel: FlowRelationsViewModel

    var body: some View {
        FlowLayout(
            items: viewModel.relations,
            alignment: viewModel.alignment,
            cell: { item, index in
                Button {
                    viewModel.onRelationTap(item)
                } label: {
                    HStack(spacing: 6) {
                        valueView(item)

                        if viewModel.relations.count - 1 > index {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .foregroundColor(.textSecondary)
                                .frame(width: 3, height: 3)
                        }
                    }
                }
            }
        )
    }

    private func valueView(_ relation: Relation) -> some View {
        Group {
            let value = relation.value
            let hint = relation.hint

            switch value {
            case .text(let string):
                FlowTextRelationView(value: string, hint: hint)
            case .number(let string):
                FlowTextRelationView(value: string, hint: hint)
            case .status(let statusRelation):
                FlowStatusRelationView(value: statusRelation, hint: hint)
            case .date(let string):
                FlowTextRelationView(value: string, hint: hint)
            case .object(let objectsRelation):
                FlowObjectRelationView(value: objectsRelation, hint: hint)
            case .checkbox(let bool):
                FlowCheckboxRelationView(isChecked: bool)
            case .url(let string):
                FlowTextRelationView(value: string, hint: hint)
            case .email(let string):
                FlowTextRelationView(value: string, hint: hint)
            case .phone(let string):
                FlowTextRelationView(value: string, hint: hint)
            case .tag(let tags):
                FlowTagRelationView(maxTags: 3, value: tags, hint: hint)
            case .unknown(let string):
                RelationsListRowHintView(hint: string)
            }
        }
    }
}
