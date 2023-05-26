import Foundation
import SwiftUI

struct ListSectionConfiguration: Hashable, Identifiable {
    
    let id: String
    let rows: [ListRowConfiguration]
    @EquatableNoop var viewBuilder: () -> AnyView
    
    init(id: String, rows: [ListRowConfiguration], @ViewBuilder viewBuilder: @escaping () -> AnyView) {
        self.id = id
        self.rows = rows
        self.viewBuilder = viewBuilder
    }
    
    func makeView() -> some View {
        viewBuilder()
    }
}

extension ListSectionConfiguration {
    
    static func smallHeader(id: String, title: String, rows: [ListRowConfiguration]) -> Self {
        ListSectionConfiguration(id: id, rows: rows, viewBuilder: {
            ListSectionHeaderView(title: title)
                .padding(.horizontal, 20)
                .eraseToAnyView()
        })
    }
    
    static func bigHeader(id: String, title: String?, rows: [ListRowConfiguration]) -> Self {
        ListSectionConfiguration(id: id, rows: rows, viewBuilder: {
            if let title, title.isNotEmpty {
                return ListSectionBigHeaderView(title: title).eraseToAnyView()
            } else {
                return EmptyView().eraseToAnyView()
            }
        })
    }
}
