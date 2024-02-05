import Foundation
import SwiftUI

struct GalleryInstallationCoordinatorView: View {
    
    @StateObject var model: GalleryInstallationCoordinatorViewModel
    
    var body: some View {
        model.previewModule()
    }
}
