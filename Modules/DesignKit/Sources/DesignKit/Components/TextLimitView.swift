import SwiftUI

public struct TextLimitView: View {
    
    let text: String
    let limitReached: Bool
    
    public init(text: String, limitReached: Bool) {
        self.text = text
        self.limitReached = limitReached
    }
    
    public var body: some View {
        Text(text)
            .foregroundStyle(limitReached ? Color.Dark.red : Color.Text.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.Background.secondary)
            .cornerRadius(12)
            .border(12, color: .Shape.tertiary)
            .shadow(color: .black.opacity(0.15), radius: 12)
    }
}
