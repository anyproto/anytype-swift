import Foundation
import SwiftUI

struct ObjectSearchWithMetaView: View {
    
    @StateObject private var model: ObjectSearchWithMetaViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: ObjectSearchWithMetaModuleData, output: (any ObjectSearchWithMetaModuleOutput)?) {
        self._model = StateObject(wrappedValue: ObjectSearchWithMetaViewModel(data: data, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: model.moduleData.type.title)
            searchBar
            content
        }
        .background(Color.Background.secondary)
        .task {
            await model.subscribeOnTypes()
        }
        .task(id: model.searchText) {
            await model.search()
        }
        .onChange(of: model.dismiss) { _ in dismiss() }
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
            ForEach(model.objectTypesModelsToCreate) { model in
                createRow(for: model)
            }
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
    
    private func createRow(for rowModel: ObjectSearchCreationModel) -> some View {
        HStack(spacing: 10) {
            IconView(asset: .X24.plus).frame(width: 24, height: 24)
            AnytypeText(rowModel.title, style: .bodyRegular)
                .foregroundColor(.Text.secondary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.vertical, 14)
        .newDivider()
        .padding(.horizontal, 16)
        .fixTappableArea()
        .onTapGesture {
            rowModel.onTap()
        }
    }
}
