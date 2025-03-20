import SwiftUI

struct CounterView: View {
    
    let count: Int
  
    var body: some View {
        Text("\(count)")
            .anytypeFontStyle(.caption1Regular) // Without line height multiple
            .foregroundStyle(Color.Control.white)
            .frame(height: 20)
            .padding(.horizontal, 6)
            .frame(minWidth: 20)
            .background(
                Capsule()
                    .fill(Color.Control.transparentActive)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule()) // From iOS 17: Delete clip and use .fill for material
            )
    }
}
