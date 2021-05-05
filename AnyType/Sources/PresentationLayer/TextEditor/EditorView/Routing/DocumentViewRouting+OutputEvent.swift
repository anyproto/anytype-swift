import Foundation
import UIKit
extension DocumentViewRouting {
    /// Segue, yes, kind of.
    /// For now we can pass controllers without additional dismissal actions and they will be dismissed by theirselves
    enum OutputEvent {
        case general(General)
        case document(Document)
    }
}

extension DocumentViewRouting.OutputEvent {
    /// These events manipuate general `UIViewController`
    enum General {
        typealias ViewController = UIViewController
        
        /// Show or Present ViewController.
        case show(ViewController)
        
        /// Add a child ( or push in navigationController ).
        case child(ViewController)
    }
}

extension DocumentViewRouting.OutputEvent {
    /// These events manipulate custom `Document.Request` as DataSource. (a.k.a. `EditorModule.ContentViewBuilder.Request` )
    enum Document {
        /// Show or Present a View that will be build by request.
        case show(String)
        
        /// Add a child ( or push in navigationController ) a View that will be build by request.
        case child(String)
    }
}
