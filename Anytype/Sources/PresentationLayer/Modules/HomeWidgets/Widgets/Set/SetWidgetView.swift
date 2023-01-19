import Foundation
import SwiftUI

struct SetWidgetView: View {
    
    @ObservedObject var model: SetWidgetViewModel
    
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
    
    private var content: some View {
        VStack(spacing: 0) {
            ForEach(model.rows, id: \.objectId) {
                SetWidgetRow(model: $0)
            }
        }
    }
}
