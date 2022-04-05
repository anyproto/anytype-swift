import SwiftUI
import BlocksModels
import Amplitude
import AnytypeCore

struct SearchNewRelationView: View {
    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel: SearchNewRelationViewModel

    @State private var searchText = ""
    @State private var showCreateNewRelation: Bool = false

    var body: some View {
        VStack() {
            DragIndicator()
            SearchBar(text: $searchText, focused: true, placeholder: "Find a relation")
            content
        }
        .onChange(of: searchText) { search(text: $0) }
        .onAppear { search(text: "") }
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
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
                                    showCreateNewRelation = true
                                }
                            ) {
                                NewRelationCell(cellKind: .createNew(searchText: searchText))
                                    .padding([.leading, .trailing], 20)
                            }
                            .frame(maxWidth: .infinity)
                            .divider(spacing: 0, leadingPadding: 20, trailingPadding: 20, alignment: .leading)
                            .sheet(isPresented: $showCreateNewRelation) {
                                if FeatureFlags.createNewRelationV2 {
                                    NewRelationView(viewModel: viewModel.newRelationViewModel(searchText: searchText))
                                } else {
                                    CreateNewRelationView(relationName: searchText, viewModel: viewModel.createNewRelationViewModel)
                                }
                            }
                        }
                    case let .addFromLibriry(relationsMetaData):
                        Section(content: {
                            ForEach(relationsMetaData.indices, id: \.self) { index in
                                let relationMetadata = relationsMetaData[index]
                                Button(
                                    action: {
                                        viewModel.addRelation(relationMetadata)
                                        presentationMode.wrappedValue.dismiss()

                                        Amplitude.instance().logSearchResult(index: index + 1, length: searchText.count)
                                    }
                                ) {
                                    NewRelationCell(cellKind: .relation(realtionMetadata: relationMetadata))
                                        .padding([.leading, .trailing], 20)
                                }
                                .frame(maxWidth: .infinity)
                                .divider(spacing: 0, leadingPadding: 20, trailingPadding: 20, alignment: .leading)
                            }
                        }, header: {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                AnytypeText(section.headerName, style: .caption1Regular, color: .textSecondary)
                                    .divider(spacing: 7, leadingPadding: 0, trailingPadding: 0   , alignment: .leading)
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
                objectRelations: ParsedRelations(featuredRelations: [], otherRelations: []),
                onSelect: { _ in }
            )
        )
    }
}
