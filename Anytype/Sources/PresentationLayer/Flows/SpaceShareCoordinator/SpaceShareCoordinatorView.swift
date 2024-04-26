import Foundation
import SwiftUI

struct SpaceShareCoordinatorView: View {
    
    @StateObject var model: SpaceShareCoordinatorViewModel
    
    var body: some View {
        model.shareModule()
    }
}
