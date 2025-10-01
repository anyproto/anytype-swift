import Foundation
import SwiftUI

struct AnytypeNavigationView: View {
    
    @Binding var path: [AnyHashable]
    @Binding var pathChanging: Bool
    
    let moduleSetup: (_ builder: AnytypeDestinationBuilderHolder) -> Void

    var body: some View {
        AnytypeNavigationViewRepresentable(path: $path, pathChanging: $pathChanging, moduleSetup: moduleSetup)
            .ignoresSafeArea()
    }
}

struct AnytypeNavigationViewRepresentable: UIViewControllerRepresentable {
    
    @Binding var path: [AnyHashable]
    @Binding var pathChanging: Bool
    let moduleSetup: (_ builder: AnytypeDestinationBuilderHolder) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller =  FullScreenSwipeNavigationController()
        controller.setNavigationBarHidden(true, animated: false)
        controller.delegate = context.coordinator
        
        moduleSetup(context.coordinator.builder)
        return controller
    }
    
    func updateUIViewController(_ controller: UINavigationController, context: Context) {
        let builder = context.coordinator.builder
        var freeViewControllers = context.coordinator.currentViewControllers
        var viewControllers = [UIHostingController<AnytypeNavigationViewBridge>]()
        
        path.enumerated().forEach { index, pathItem in
            if let index = freeViewControllers.firstIndex(where: { $0.rootView.data == pathItem }) {
                let vc = freeViewControllers.remove(at: index)
                viewControllers.append(vc)
            } else {
                let view = builder
                    .build(pathItem.base)
                    .anytypeNavigationItemData(pathItem)
                    .eraseToAnyView()
                let vc = UIHostingController(rootView: AnytypeNavigationViewBridge(content: view, data: pathItem))
                viewControllers.append(vc)
            }
        }
        if viewControllers.isEmpty {
            return
        }
        
        let currentViewControllers = context.coordinator.currentViewControllers
        if currentViewControllers != viewControllers {
            context.coordinator.currentViewControllers = viewControllers
            context.coordinator.numberOfTransactions += 1
            if currentViewControllers.last == viewControllers.last {
                controller.setViewControllers(viewControllers, animated: false)
            } else {
                controller.setViewControllers(viewControllers, animated: currentViewControllers.isNotEmpty)
            }
        }
    }
    
    func makeCoordinator() -> AnytypeNavigationCoordinator {
        return AnytypeNavigationCoordinator(path: _path, pathChanging: _pathChanging)
    }
}
