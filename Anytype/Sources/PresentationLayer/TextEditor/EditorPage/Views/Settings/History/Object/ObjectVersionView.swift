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
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: model.data.title)
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
