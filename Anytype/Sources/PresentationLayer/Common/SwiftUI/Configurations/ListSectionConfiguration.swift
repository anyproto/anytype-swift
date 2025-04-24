import Foundation
import SwiftUI

struct ListSectionConfiguration: Hashable, Identifiable, @unchecked Sendable {
    
    let id: String
    let rows: [ListRowConfiguration]
    @EquatableNoop var viewBuilder: @MainActor () -> AnyView
    
    init(id: String, rows: [ListRowConfiguration], @ViewBuilder viewBuilder: @escaping @MainActor () -> AnyView) {
        self.id = id
        self.rows = rows
        self.viewBuilder = viewBuilder
    }
    
    @MainActor
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
}
