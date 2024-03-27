import Foundation
import SwiftUI

struct SpaceShareCoordinatorView: View {
    
    @StateObject private var model = SpaceShareCoordinatorViewModel()
    
    var body: some View {
        SpaceShareView()
    }
}
