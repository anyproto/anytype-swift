//import Foundation
//import SwiftUI
//
//struct AnytypeNavigationPath<Data: Hashable> {
//    private let path: [Data]
//}
//
//
//
//struct AnytypeNavigationView<Data: Hashable>: UIViewControllerRepresentable {
//    
//    @Binding var path: AnytypeNavigationPath<Data>
//    
//    func makeUIViewController(context: Context) -> UINavigationController {
//        let controller =  UINavigationController()
//        controller.delegate = context.coordinator
//        return controller
//    }
//    
//    func updateUIViewController(_ controller: UINavigationController, context: Context) {
//        controller.viewControllers =
//        
//        let a = UIHostingController(rootView: EmptyView())
//    }
//    
//    func makeCoordinator() -> AnytypeNavigationCoordinator {
//        return AnytypeNavigationCoordinator()
//    }
//}
//
//final class AnytypeNavigationCoordinator: NSObject, UINavigationControllerDelegate {
//    
//    // MARK: - UINavigationControllerDelegate
//    
//}
