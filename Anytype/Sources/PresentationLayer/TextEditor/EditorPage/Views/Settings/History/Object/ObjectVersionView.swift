import Foundation
import SwiftUI

struct ObjectVersionView: View {
    
    @StateObject private var model: ObjectVersionViewModel
    
    init(data: ObjectVersionData) {
        _model = StateObject(wrappedValue: ObjectVersionViewModel(data: data))
    }
    
    var body: some View {
        content
            .overlay(alignment: .topLeading) {
                header
            }
            .task {
                await model.setupObject()
            }
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title:  model.data.title) {
                ObjectIconView(icon: model.data.icon)
                    .frame(width: 24, height: 24)
            }
        }
        .background(Color.Background.primary)
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.screenData {
        case .page(let data):
            EditorPageCoordinatorView(data: data, showHeader: false, setupEditorInput: {_,_ in })
        case .set(let data):
            EditorSetCoordinatorView(data: data, showHeader: false)
        default:
            EmptyView()
        }
    }
}
