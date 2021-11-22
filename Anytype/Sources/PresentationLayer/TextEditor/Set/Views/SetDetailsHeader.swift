import SwiftUI

struct SetDetailsHeader: View {
    @Binding var yOffset: CGFloat
    @Binding var headerSize: CGRect
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    @State private var headerPosition = CGPoint.zero
    
    private let settingsHeight: CGFloat = 56
    private let minimizedHeaderHeight: CGFloat = 92
    
    var body: some View {
        ZStack {
            details
            minimizedDetails
        }
        .onAppear {
            DispatchQueue.main.async {
                yOffset = 0
            }
        }
    }
    
    private var details: some View {
        VStack {
            VStack {
                header.ignoresSafeArea(edges: .top)
                PositionCatcher { headerPosition = $0 }
                settings
            }
            .background(Color.background)
            .background(FrameCatcher { headerSize = $0 })
            .offset(y: min(yOffset, 0))
            
            Spacer()
        }
    }
    
    private var minimizedDetails: some View {
        Group {
            if headerPosition.y < minimizedHeaderHeight {
                VStack {
                    VStack {
                        CoverConstants.gradients[1].asLinearGradient().frame(height: minimizedHeaderHeight)
                        settings
                    }.background(Color.background)
                    Spacer()
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            CoverConstants.gradients[1].asLinearGradient()
                .frame(height: 240)
            AnytypeText("\(model.document.objectDetails?.title ??  "Untitled")", style: .title, color: .textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
            AnytypeText("Set description", style: .body, color: .textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        }
    }
    
    private var settings: some View {
        HStack {
            AnytypeText("All employees", style: .heading, color: .textPrimary)
                .padding()
            Image.arrow.rotationEffect(.degrees(90))
            Spacer()
            Image.ObjectAction.template.padding()
        }
        .frame(height: settingsHeight)
    }
}

struct SetDetailsHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetDetailsHeader(yOffset: .constant(.zero), headerSize: .constant(.zero))
    }
}
