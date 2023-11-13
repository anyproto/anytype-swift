import Foundation
import SwiftUI
import AnytypeCore

struct AnytypeNavigationViewBridge: View {
    
    let content: AnyView
    let data: AnyHashable
    
    var body: some View {
        content
    }
}


struct AnytypeNavigationView: UIViewControllerRepresentable {
    
    @Binding var path: [AnyHashable]
    let moduleSetup: (_ builder: AnytypeDestinationBuilderHolder) -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller =  UINavigationController()
        controller.delegate = context.coordinator
        moduleSetup(context.coordinator.builder)
        return controller
    }
    
    func updateUIViewController(_ controller: UINavigationController, context: Context) {
        
        let builder = context.coordinator.builder
        let currentViewControllers = context.coordinator.currentViewControllers
        var viewControllers = [UIHostingController<AnytypeNavigationViewBridge>]()
        
        path.enumerated().forEach { index, pathItem in
            if let vc = currentViewControllers[safe: index], vc.rootView.data.hashValue == pathItem.hashValue {
                viewControllers.append(vc)
            } else {
                let view = builder.build(pathItem.base)
                let vc = UIHostingController(rootView: AnytypeNavigationViewBridge(content: view, data: pathItem))
                viewControllers.append(vc)
            }
        }
        if viewControllers.isEmpty {
            return
        }
        if currentViewControllers != viewControllers {
            context.coordinator.currentViewControllers = viewControllers
            controller.setViewControllers(viewControllers, animated: currentViewControllers.isNotEmpty)
        }
    }
    
    func makeCoordinator() -> AnytypeNavigationCoordinator {
        return AnytypeNavigationCoordinator()
    }
}

final class AnytypeNavigationCoordinator: NSObject, UINavigationControllerDelegate {
    
    var builder = AnytypeDestinationBuilderHolder()
    var currentViewControllers = [UIHostingController<AnytypeNavigationViewBridge>]()
    
    // MARK: - UINavigationControllerDelegate
    
}

final class AnytypeDestinationBuilderHolder {

    private var builders: [String: (Any) -> AnyView?] = [:]
    
    static func identifier(for type: Any.Type) -> String {
        String(reflecting: type)
    }

    func appendBuilder<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) {
      return appendBuilder({ AnyView(builder($0)) })
    }
    
    func appendBuilder<T>(_ builder: @escaping (T) -> AnyView) {
        let key = Self.identifier(for: T.self)
        builders[key] = { data in
            if let typedData = data as? T {
                return builder(typedData)
            } else {
                return nil
            }
        }
    }

    func build(_ typedData: Any) -> AnyView {
        let key = Self.identifier(for: type(of: typedData))
        if let builder = builders[key], let view = builder(typedData) {
            return view
        }
        assertionFailure("No view builder found for type \(key)")
        return EmptyView().eraseToAnyView()
    }
    
//    func build<T>(key: String, typedData: T) -> AnyView {
//        if let builder = builders[key], let view = builder(typedData) {
//            return view
//        }
//        assertionFailure("No view builder found for type \(key)")
//        return EmptyView().eraseToAnyView()
//    }
}

//struct NavigationCreator {
//    var
//}
//
//struct PageNavigationEnvironmentKey: EnvironmentKey {
//    static let defaultValue: PageNavigation = PageNavigation(push: { _ in }, pop: { }, replace: { _ in })
//}
//
//extension EnvironmentValues {
//    var pageNavigation: PageNavigation {
//        get { self[PageNavigationEnvironmentKey.self] }
//        set { self[PageNavigationEnvironmentKey.self] = newValue }
//    }
//}

//
//struct AnytypeDestinationBuilderHolderEnvironmentKey: EnvironmentKey {
//    static let defaultValue: AnytypeDestinationBuilderHolder = AnytypeDestinationBuilderHolder()
//}
//
//extension EnvironmentValues {
//    var anytypeDestinationBuilderHolder: AnytypeDestinationBuilderHolder {
//        get { self[AnytypeDestinationBuilderHolderEnvironmentKey.self] }
//        set { self[AnytypeDestinationBuilderHolderEnvironmentKey.self] = newValue }
//    }
//}
//
//extension View {
//    func anytypeNavigationDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) -> some View {
//      return modifier(AnytypeDestinationBuilderModifier(builder: { AnyView(builder($0)) }))
//    }
//}
//
//struct AnytypeDestinationBuilderModifier<D: Hashable>: ViewModifier {
//    
//    let builder: (D) -> AnyView
//    
//    @Environment(\.anytypeDestinationBuilderHolder) var holder: AnytypeDestinationBuilderHolder
//    
//    func body(content: Content) -> some View {
//        content
//            .onAppear {
//                holder.appendBuilder(builder)
//            }
//    }
//}
