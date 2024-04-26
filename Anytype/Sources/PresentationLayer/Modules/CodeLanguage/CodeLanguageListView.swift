import Foundation
import SwiftUI

struct CodeLanguageListView: View {
    
    @ObservedObject var model: CodeLanguageListViewModel
    
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $searchText, focused: false, placeholder: Loc.searchForLanguage)
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(model.rows) { row in
                        Button {
                            row.onTap()
                        } label: {
                            HStack(spacing: 0) {
                                AnytypeText(row.title, style: .bodyRegular, color: .Text.primary)
                                    .lineLimit(1)
                                Spacer()
                                if row.isSelected {
                                    Image(asset: .X24.tick)
                                        .foregroundColor(Color.Text.primary)
                                }
                            }
                            .frame(height: 52)
                            .newDivider()
                            .padding(.horizontal, 20)
                            .fixTappableArea()
                        }
                    }
                }
            }
        }
        .onChange(of: searchText) { text in
            model.onChangeSearch(text: text)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
