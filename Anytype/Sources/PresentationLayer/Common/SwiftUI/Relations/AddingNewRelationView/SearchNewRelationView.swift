import SwiftUI
import BlocksModels


struct SearchNewRelationView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""
    @StateObject var viewModel: SearchNewRelationViewModel

    var body: some View {
        VStack() {
            DragIndicator(bottomPadding: 0)
            SearchBar(text: $searchText, focused: true, placeholder: "Find a relation")
            content
        }
        .onChange(of: searchText) { search(text: $0) }
        .onAppear { search(text: "") }
    }

    private var content: some View {
        Group {
            if viewModel.searchData.isEmpty {
                emptyState
            } else {
                searchResults
            }
        }
    }

    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchData) { section in
                    switch section {
                    case .createNewRelation:
                        Section {
                            Button(
                                action: {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            ) {
                                NewRelationCell(cellKind: .createNew)
                                    .padding([.leading, .trailing], 20)
                            }
                            .frame(maxWidth: .infinity)
                            .modifier(DividerModifier(spacing: 0, leadingPadding: 20, trailingPadding: 20, alignment: .leading))
                        }
                    case let .addFromLibriry(relationsMetaData):
                        Section(content: {
                            ForEach(relationsMetaData) { relationMetadata in
                                Button(
                                    action: {
                                        presentationMode.wrappedValue.dismiss()
                                        viewModel.onSelect(relationMetadata)
                                    }
                                ) {
                                    NewRelationCell(cellKind: .relation(realtionMetadata: relationMetadata))
                                        .padding([.leading, .trailing], 20)
                                }
                                .frame(maxWidth: .infinity)
                                .modifier(DividerModifier(spacing: 0, leadingPadding: 20, trailingPadding: 20, alignment: .leading))
                            }
                        }, header: {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                AnytypeText(section.headerName, style: .caption1Regular, color: .textSecondary)
                                    .modifier(DividerModifier(spacing: 7, leadingPadding: 0, trailingPadding: 0   , alignment: .leading))
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 52)
                        })

                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .center) {
            Spacer()
            AnytypeText(
                "\("There is no relation named".localized) \"\(searchText)\"",
                style: .uxBodyRegular,
                color: .textPrimary
            )
            .multilineTextAlignment(.center)
            AnytypeText(
                "Try to create a new one or search for something else".localized,
                style: .uxBodyRegular,
                color: .textSecondary
            )
            .multilineTextAlignment(.center)
            Spacer()
        }.padding(.horizontal)
    }

    private func search(text: String) {
        viewModel.search(text: text)
    }
}

struct SearchNewRelationView_Previews: PreviewProvider {

    static var previews: some View {
        SearchNewRelationView(
            viewModel: SearchNewRelationViewModel(
                relationService: RelationsService(objectId: ""),
                onSelect: { _ in
            })
        )
    }
}
