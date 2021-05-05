import Foundation
import SwiftUI
import Combine


extension EditorModule.Document {
    enum ViewBuilder {
        struct Request {
            let id: String
        }

        private enum Constants {
            static let selectedViewCornerRadius: CGFloat = 8
        }
        /// We define relationship between `Child` and `Self` components.
        /// Child component has a builder.
        ///
        /// In our case, we don't have builders and child components.
        /// This builder is a `leaf` of builders.
        ///
        /// For that, we define `ChildViewModel`, `ChildViewController`, `ChildViewBuilder` as `Void`.
        ///
        /// We don't have direct access to them, but we should an ability to add them to `SelfComponent` as `ChildComponent`.
        typealias ChildViewModel = Void
        typealias ChildViewController = Void
        typealias ChildViewBuilder = Void

        typealias ChildComponent = (viewController: ChildViewController, viewModel: ChildViewModel)
        typealias SelfComponent = (viewController: DocumentEditorViewController, viewModel: DocumentEditorViewModel, childComponent: ChildComponent)
        
        static func childComponent(by request: Request) -> ChildComponent {
            ((), ())
        }
        
        static func selfComponent(by request: Request) -> SelfComponent {
            let viewModel = DocumentEditorViewModel(documentId: request.id,
                                                    options: .init(shouldCreateEmptyBlockOnTapIfListIsEmpty: true))
            let viewCellFactory = DocumentViewCellFactory(selectedViewColor: .selectedItemColor,
                                                          selectedViewCornerRadius: Constants.selectedViewCornerRadius)
            let view: DocumentEditorViewController = .init(viewModel: viewModel, viewCellFactory: viewCellFactory)
            viewModel.viewInput = view
            
            return (view, viewModel, self.childComponent(by: request))
        }
        
        static func view(by request: Request) -> DocumentEditorViewController {
            self.selfComponent(by: request).0
        }
    }
}
