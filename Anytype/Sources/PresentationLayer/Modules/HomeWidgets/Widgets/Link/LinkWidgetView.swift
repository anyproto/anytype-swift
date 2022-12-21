import SwiftUI

struct LinkWidgetView: View {
    
    var title: String
    var image: ImageAsset?
    var collapseContent: Bool
    
    var body: some View {
        VStack {
            Spacer.fixedHeight(6)
            header
            if collapseContent {
                Spacer.fixedHeight(6)
            } else {
                content
                Spacer.fixedHeight(16)
            }
        }
        .background(Color.backgroundDashboard)
    }
    
    private var header: some View {
        HStack {
            Spacer.fixedWidth(16)
            AnytypeText(title, style: .subheading, color: .textPrimary)
            Spacer()
        }
        .frame(height: 40)
    }
    
    private var content: some View {
        EmptyView()
            .foregroundColor(.red)
            .frame(height: 100)
    }
}

struct LinkWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.black)
            LinkWidgetView(
                title: "Name",
                image: nil,
                collapseContent: true
            )
        }
    }
}
