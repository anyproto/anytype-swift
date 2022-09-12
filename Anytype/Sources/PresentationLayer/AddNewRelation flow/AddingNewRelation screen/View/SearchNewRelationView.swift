import SwiftUI
import BlocksModels
import AnytypeCore

struct SearchNewRelationView: View {

    @StateObject var viewModel: SearchNewRelationViewModel

    @State private var searchText = ""
    @State private var showCreateNewRelation: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $searchText, focused: true, placeholder: Loc.findARelation)
            content
        }
        .onChange(of: searchText) { search(text: $0) }
        .onAppear { search(text: "") }
        .onChange(of: showCreateNewRelation) { newValue in
            guard newValue else { return }
            
            viewModel.showAddRelation(searchText: searchText)
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
                        }
                    case let .addFromLibriry(relations):
                        Section(content: {
                            ForEach(Array(relations.enumerated()), id: \.element) { index, relation in
                                Button(
                                    action: {
                                        viewModel.addRelation(relation)

                                        AnytypeAnalytics.instance().logSearchResult(index: index + 1, length: searchText.count)
                                    }
                                ) {
                                    NewRelationCell(cellKind: .relation(realtionMetadata: relation))
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
                Loc.thereIsNoRelationNamed(searchText),
                style: .uxBodyRegular,
                color: .textPrimary
            )
            .multilineTextAlignment(.center)
            AnytypeText(
                Loc.tryToCreateANewOneOrSearchForSomethingElse,
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
