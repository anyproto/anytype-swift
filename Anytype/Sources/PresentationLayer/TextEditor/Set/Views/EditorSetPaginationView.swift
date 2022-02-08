import SwiftUI

struct EditorSetPaginationView: View {
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image.set.back
                Spacer()
                HStack(spacing: 24) {
                    AnytypeText("1", style: .body, color: .textPrimary)
                        .frame(width: 24, height: 24)
                    AnytypeText("2", style: .body, color: .textPrimary)
                        .frame(width: 24, height: 24)
                    AnytypeText("3", style: .body, color: .textPrimary)
                        .frame(width: 24, height: 24)
                    AnytypeText("4", style: .body, color: .textPrimary)
                        .frame(width: 24, height: 24)
                    AnytypeText("5", style: .body, color: .textPrimary)
                        .frame(width: 24, height: 24)
                }
                Spacer()
                Image.set.forward
            }
            .padding().frame(height: 60)
            
            Rectangle().frame(height: 40).foregroundColor(.backgroundPrimary) // Navigation view stub
        }
    }
}

struct EditorSetPaginationView_Previews: PreviewProvider {
    static var previews: some View {
        EditorSetPaginationView()
    }
}
