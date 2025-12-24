import Foundation
import SwiftUI

struct HomePagePickerView: View {

    @StateObject private var model: HomePagePickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: HomePagePickerModuleData) {
        self._model = StateObject(wrappedValue: HomePagePickerViewModel(data: data))
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.homePage)

            fixedOptions

            SectionHeaderView(title: Loc.HomePage.specificObject)
                .padding(.horizontal, 16)

            SearchBar(text: $model.searchText, focused: false)

            content
        }
        .background(Color.Background.secondary)
        .task(id: model.searchText) {
            await model.search()
        }
        .onChange(of: model.dismiss) { dismiss() }
    }

    private var fixedOptions: some View {
        HomePageOptionRow(
            icon: .X18.list,
            title: Loc.HomePage.widgets,
            isSelected: model.selectedObjectId == nil
        ) {
            model.onWidgetsSelected()
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var content: some View {
        if model.isInitial {
            Spacer()
        } else if model.sections.isEmpty {
            emptyState
        } else {
            searchResults
        }
    }

    private var searchResults: some View {
        PlainList {
            ForEach(model.sections) { section in
                if let title = section.data, title.isNotEmpty {
                    ListSectionHeaderView(title: title)
                        .padding(.horizontal, 20)
                }
                ForEach(section.rows) { rowModel in
                    itemRow(for: rowModel)
                }
            }
        }
        .scrollIndicators(.never)
        .id(model.searchText)
    }

    private func itemRow(for rowModel: SearchWithMetaModel) -> some View {
        HStack {
            SearchWithMetaCell(model: rowModel)
            Spacer()
            if model.selectedObjectId == rowModel.id {
                Image(asset: .X24.tick)
                    .padding(.trailing, 16)
            }
        }
        .fixTappableArea()
        .onTapGesture {
            model.onObjectSelected(searchData: rowModel)
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            title: Loc.nothingFound,
            subtitle: "",
            style: .plain
        )
    }
}

#Preview {
    HomePagePickerView(data: HomePagePickerModuleData(spaceId: "test"))
}
