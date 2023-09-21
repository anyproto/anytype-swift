import Foundation
import SwiftUI

struct EditorPageView: View {
    
    let editorPageController: EditorPageController
    @ObservedObject var environmentBridge: EditorPageViewEnvironmentBridge
    
    var body: some View {
        GenericUIKitToSwiftUIView(viewController: editorPageController)
            .navigationBarHidden(true)
            .homeBottomPanelHidden(environmentBridge.homeBottomPanelHidden)
    }
}

//final class EditorPageViewModelAdapter: ObservableObject {
//
//    let editorPageAssembly: EditorAssembly
//    let data: EditorPageObject
//
//    lazy var editorPageController = editorPageAssembly.buildEditorModule(browser: nil, data: data).vc
//
//}

final class EditorPageViewEnvironmentBridge: ObservableObject {
    @Published var homeBottomPanelHidden = false
    
    func setHomeBottomPanelHidden(_ hidden: Bool, animated: Bool = false) {
        if animated {
            withAnimation {
                homeBottomPanelHidden = hidden
            }
        } else {
            homeBottomPanelHidden = hidden
        }
    }
}

//private struct EditorPageViewContainer: UIViewControllerRepresentable {
//
//    let editorPageController: EditorPageController
//    @StateObject private var environmentBridge = EditorPageViewEnvironmentBridge()
//
//    func makeUIViewController(context: Context) -> EditorPageController {
//        editorPageController.environmentBridge = environmentBridge
//        return editorPageController
//    }
//
//    func updateUIViewController(_ uiViewController: EditorPageController, context: Context) {
//
//    }
//}


struct ViewMakeAdapter: View {
    
    @StateObject var model: ViewModelMakeAdapter
    
    var body: some View {
        model.view()
    }
}

final class ViewModelMakeAdapter: ObservableObject {
    
    private var cachedView: AnyView?
    private let viewMake: () -> AnyView
    
    init(viewMake: @autoclosure @escaping () -> AnyView) {
        self.viewMake = viewMake
    }
    
    func view() -> AnyView {
        if let cachedView {
            return cachedView
        }
        
        let newView = viewMake()
        cachedView = newView
        return newView
    }
}

