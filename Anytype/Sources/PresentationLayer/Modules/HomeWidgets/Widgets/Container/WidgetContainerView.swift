import Foundation
import SwiftUI

@MainActor
protocol WidgetContainerContentViewModelProtocol: AnyObject, ObservableObject {
    var name: String { get }
    
    func onAppear()
    func onDisappear()
}

struct WidgetContainerView<Content: View, ContentVM: WidgetContainerContentViewModelProtocol>: View {
    
    @ObservedObject var model: WidgetContainerViewModel
    @ObservedObject var contentModel: ContentVM
    var content: Content
        
    var body: some View {
        LinkWidgetViewContainer(title: contentModel.name, isExpanded: $model.isExpanded, isEditalbeMode: model.isEditState) {
            content
        }
        .onAppear {
            contentModel.onAppear()
        }
        .onDisappear {
            contentModel.onDisappear()
        }
    }
}
