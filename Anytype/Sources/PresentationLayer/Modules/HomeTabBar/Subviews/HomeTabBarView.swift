import Foundation
import SwiftUI

struct HomeTabBarView: View {

    let name: String
    let icon: Icon?
    @Binding var state: HomeTabState
    
    var body: some View {
        HStack(spacing: 0) {

            Spacer.fixedWidth(31)

            Group {
                IconView(icon: icon)
                    .frame(width: 48, height: 48)
                    .padding(.vertical, 31)

                Spacer.fixedWidth(26)

                Text(verbatim: name)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(2)

                Spacer.fixedWidth(10)
            }
            .fixTappableArea()
            
            Spacer()

            VStack(spacing: 10) {
                Image(asset: .X32.sendMessage)
                    .frame(width: 36, height: 36)
                    .onTapGesture {
                        withAnimation {
                            state = .chat
                        }
                    }

                Image(asset: .X32.audo)
                    .frame(width: 36, height: 36)

            }
            Spacer.fixedWidth(10)
            VStack(spacing: 10) {
                Image(asset: .X32.actions2)
                    .frame(width: 36, height: 36)
                    .onTapGesture {
                        withAnimation {
                            state = .widgets
                        }
                    }
                Image(asset: .X32.actions)
                    .frame(width: 36, height: 36)
            }

            Spacer.fixedWidth(26)
        }
        .background(Color.Widget.card)
    }
}
