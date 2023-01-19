import Foundation
import SwiftUI

struct SetWidgetView<Model: ListWidgetViewModelProtocol>: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        LinkWidgetViewContainer(title: model.name, isExpanded: $model.isExpanded) {
            VStack(spacing: 0) {
                header
                content
            }
        }
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
    
    private var header: some View {
        Group {
            if model.headerItems.isEmpty {
                Spacer.fixedHeight(6)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(model.headerItems, id: \.dataviewId) {
                            SetWidgetHeaderItem(model: $0)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 40)
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            ForEach(model.rows, id: \.objectId) {
                SetWidgetRow(model: $0)
            }
        }
    }
}
