import Foundation
import SwiftUI

struct ListWidgetView<Model: ListWidgetViewModelProtocol>: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
    }
    
    private var header: some View {
        Group {
            if model.headerItems.isNotEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(model.headerItems, id: \.dataviewId) {
                            ListWidgetHeaderItem(model: $0)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 40)
            }
        }
    }
    
    private var content: some View {
        ZStack {
            if let rows = model.rows {
                VStack(spacing: 0) {
                    WidgetEmptyView(title: model.emptyTitle)
                        .frame(height: 72)
                    Spacer.fixedHeight(8)
                }
                .opacity(rows.isEmpty ? 1 : 0)
                VStack(spacing: 0) {
                    ForEach(rows) {
                        ListWidgetRow(model: $0)
                    }
                    Spacer.fixedHeight(16)
                }
                .opacity(rows.isEmpty ? 0 : 1)
            }
        }
    }
}
