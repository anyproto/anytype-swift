import Foundation
import SwiftUI

protocol NewSearchInteractorProtocol {

    func makeSearch(text: String, onCompletion: () -> ())
    
}
