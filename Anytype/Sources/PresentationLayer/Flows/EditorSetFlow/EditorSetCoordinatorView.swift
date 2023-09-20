import Foundation
import SwiftUI

struct EditorSetCoordinatorView: View {
    
    @StateObject var model: EditorSetCoordinatorViewModel
    
    var body: some View {
        model.setModule()
    }
}
