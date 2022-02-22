import SwiftUI
import BlocksModels
import Amplitude

struct SearchView<SearchViewModel: SearchViewModelProtocol>: View {
    @Environment(\.presentationMode) var presentationMode

    let title: String?
    let context: AmplitudeEventsSearchContext

    @State private var searchText = ""
    @StateObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack() {
            DragIndicator()
            titleView
            SearchBar(text: $searchText, focused: true)
            content
        }
        .background(Color.backgroundSecondary)
        .onChange(of: searchText) {
            search(text: $0)

            Amplitude.instance().logSearchQuery(context, length: searchText.count)
        }
        .onAppear { search(text: searchText) }
    }
    
    private var titleView: some View {
        Group {
            if let title = title {
                Spacer.fixedHeight(6)
                AnytypeText(title, style: .uxTitle1Semibold, color: .textPrimary)
                Spacer.fixedHeight(12)
            } else {
                EmptyView()
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
                    Section(content: {
                        ForEach(section.searchData.indices) { index in
                            let searchData = section.searchData[index]
                            
                            Button(
                                action: {
                                    presentationMode.wrappedValue.dismiss()
                                    viewModel.onDismiss()
                                    viewModel.onSelect(searchData)

                                    Amplitude.instance().logSearchResult(index: index + 1, length: searchText.count)
                                }
                            ) {
                                SearchCell(
                                    data: searchData,
                                    descriptionTextColor: searchData.descriptionTextColor,
                                    shouldShowCallout: searchData.shouldShowCallout,
                                    shouldShowDescription: searchData.shouldShowDescription
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .divider(spacing: 0, leadingPadding: 72, trailingPadding: 12, alignment: .leading)
                        }
                    }, header: {
                        if section.sectionName.isNotEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                AnytypeText(section.sectionName, style: .caption1Regular, color: .textSecondary)
                                    .divider(spacing: 7, leadingPadding: 0, trailingPadding: 0, alignment: .leading)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 52)
                        } else {
                            EmptyView()
                        }
                    })
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .center) {
            Spacer()
            AnytypeText(
                "\("There is no object named".localized) \"\(searchText)\"",
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

struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(
            title: "FOoo",
            context: .general, viewModel: ObjectSearchViewModel(searchKind: .objects, onSelect: { _ in
            })
        )
    }
}
