import SwiftUI

struct LinkWidgetViewContainer<Content>: View where Content: View {
    
    var title: String
    @Binding var isExpanded: Bool
    var content: () -> Content
    
    init(title: String, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._isExpanded = isExpanded
        self.content = content
    }
    
    var body: some View {
        VStack {
            Spacer.fixedHeight(6)
            header
            if !isExpanded {
                Spacer.fixedHeight(6)
            } else {
                content()
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    alignment: .topLeading
                )
                Spacer.fixedHeight(16)
            }
        }
        .background(Color.Dashboard.card)
        .cornerRadius(16, style: .continuous)
    }
    
    // MARK: - Private
    
    private var header: some View {
        HStack {
            Spacer.fixedWidth(16)
            AnytypeText(title, style: .subheading, color: .Text.primary)
            Spacer()
            Button(action: {
                withAnimation {
                    print("on tap")
                    isExpanded = !isExpanded
                }
            }, label: {
                Image(asset: .Widget.collapse)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            })
            Spacer.fixedWidth(12)
        }
        .frame(height: 40)
    }
}

struct LinkWidgetViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.black)
            VStack {
                LinkWidgetViewContainer(
                    title: "Name",
                    isExpanded: .constant(true)
                ) {
                    Text("1")
                }
                Spacer.fixedHeight(10)
                LinkWidgetViewContainer(
                    title: "Name",
                    isExpanded: .constant(false)
                ) {
                    Text("1")
                }
            }
        }
    }
}
