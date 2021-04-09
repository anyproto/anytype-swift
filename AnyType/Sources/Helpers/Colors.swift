import SwiftUI

extension Color {
    public static let anytypeOrange = Color(red: 255, green: 181, blue: 34)
    public static let anytypeGray = Color(red: 224, green: 222, blue: 210)
    
    private init(red: Int, green: Int, blue: Int) {
        self.init(red: Double(red)/255, green: Double(green)/255, blue: Double(blue)/255)
    }
}
