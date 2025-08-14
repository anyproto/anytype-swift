import SwiftUI
import AnytypeCore

struct SetSortTypesListView: View {
    @StateObject private var model: SetSortTypesListViewModel
    
    init(data: SetSortTypesData) {
        _model = StateObject(wrappedValue: SetSortTypesListViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: model.title)
            typeSection
            emptyTypeSection
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
    }
    
    private var typeSection: some View {
        ForEach(model.typeItems) { item in
            row(for: item)
        }
    }
    
    private var emptyTypeSection: some View {
        VStack(spacing: 0) {
            ListSectionHeaderView(title: Loc.EditSet.Popup.Sort.EmptyTypes.Section.title)
            ForEach(model.emptyTypeItems) { item in
                row(for: item)
            }
        }
    }
    
    private func row(for item: SetSortTypeItem) -> some View {
        Button {
            item.onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(item.title, style: .uxBodyRegular)
                    .foregroundColor(.Text.primary)
                
                Spacer()

                if item.isSelected {
                    Image(asset: .X24.tick).foregroundColor(.Control.primary)
                }
            }
            .frame(height: 52)
            .newDivider()
        }
    }
}
