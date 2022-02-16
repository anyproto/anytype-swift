import SwiftUI
import BlocksModels


struct CreateNewRelationView: View {
    @State private var relationName = ""
    @StateObject var viewModel: CreateNewRelationViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator(bottomPadding: 0)
            AnytypeText("New relation".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .padding([.top, .bottom], 12)
            content
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText("Name".localized, style: .caption1Regular, color: .textSecondary)
                    Spacer.fixedWidth(4)
                    TextField("New relation".localized, text: $relationName)
                        .font(AnytypeFontBuilder.font(anytypeFont: .heading))
                }
                .padding([.top, .bottom], 10)
                .padding([.leading, .trailing], 20)
                .divider(spacing: 0, leadingPadding: 20, trailingPadding: 20, alignment: .leading)
                .frame(maxWidth: .infinity, minHeight: 68, maxHeight: 68)

                Section(content: {
                    ForEach(viewModel.relationTypes) { relationType in
                        Button(
                            action: {
                                viewModel.selectedType = relationType
                            }
                        ) {
                            CreateNewRelationCell(format: relationType, isSelected: viewModel.selectedType == relationType)
                                .padding([.leading, .trailing], 20)
                        }
                        .frame(maxWidth: .infinity)
                        .divider(spacing: 0, leadingPadding: 20, trailingPadding: 20, alignment: .leading)
                    }
                }, header: {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        AnytypeText("Connect with".localized, style: .caption1Regular, color: .textSecondary)
                            .divider(spacing: 7, leadingPadding: 0, trailingPadding: 0, alignment: .leading)
                    }
                    .frame(height: 52, alignment: .bottomLeading)
                    .padding(.horizontal, 20)
                })
                Color.clear.padding(.bottom, 48) // bottom content inset with overlay button height
            }
        }
        .overlay(overlay, alignment: .bottom)
    }

    private var overlay: some View {
        StandardButton(disabled: false, text: "Create".localized, style: .primary, action: {
            viewModel.createRelation(relationName)
        })
            .padding([.leading, .trailing], 20)
    }

}

struct CreateNewRelationView_Previews: PreviewProvider {

    static var previews: some View {
        SearchNewRelationView(
            viewModel: SearchNewRelationViewModel(
                relationService: RelationsService(objectId: ""),
                objectRelations: ParsedRelations(featuredRelations: [], otherRelations: []),
                onSelect: { _ in
                }
            )
        )
    }
}
