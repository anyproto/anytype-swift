import SwiftUI

struct FileStorageProgress: View {
    
    let percent: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            ZStack(alignment: .leading) {
                Rectangle().foregroundColor(.Stroke.tertiary)
                Rectangle().foregroundColor(.Button.button)
                    .frame(width: frame.width * percent)
            }
            .cornerRadius(frame.height * 0.5, style: .continuous)
        }
        .frame(height: 6) // Default frame
    }
}

struct FileStorageProgress_Previews: PreviewProvider {
    static var previews: some View {
        FileStorageProgress(percent: 0.2)
            .frame(width: 300)
    }
}
