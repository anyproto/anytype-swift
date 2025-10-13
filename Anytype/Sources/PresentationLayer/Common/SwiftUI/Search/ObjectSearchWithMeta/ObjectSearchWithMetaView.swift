import Foundation
import SwiftUI

struct ObjectSearchWithMetaView: View {
    
    @StateObject private var model: ObjectSearchWithMetaViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: ObjectSearchWithMetaModuleData) {
        self._model = StateObject(wrappedValue: ObjectSearchWithMetaViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.attachObject)
            searchBar
            content
        }
        .background(Color.Background.secondary)
        .task(id: model.searchText) {
            await model.search()
        }
        .onChange(of: model.dismiss) { dismiss() }
    }
    
    private var searchBar: some View {
        SearchBar(text: $model.searchText, focused: true)
    }
    
    @ViewBuilder
    private var content: some View {
        if model.isInitial {
            Spacer()
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
        SearchWithMetaCell(model: rowModel)
            .fixTappableArea()
            .onTapGesture {
                model.onSelect(searchData: rowModel)
            }
    }
}
