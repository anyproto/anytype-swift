import Foundation
import SwiftUI
import AnytypeCore

struct IconGradient {
    let centerColor: UIColor
    let roundColor: UIColor
    let centerLocation: CGFloat
    let roundLocation: CGFloat
}

protocol IconGradientStorageProtocol {
    func gradient(for gradientId: Int) -> IconGradient
}

final class IconGradientStorage: IconGradientStorageProtocol {
    
    private let fallbackGradient = IconGradient(centerColor: UIColor(hexString: "#F6EB7D"), roundColor: UIColor(hexString: "#CBD2FA"), centerLocation: 0.23, roundLocation: 1)
    
    private let storage = [
        IconGradient(centerColor: UIColor(hexString: "#F6EB7D"), roundColor: UIColor(hexString: "#CBD2FA"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#112156"), roundColor: UIColor(hexString: "#CBD2FA"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#FFA15E"), roundColor: UIColor(hexString: "#CBD2FA"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#BC3A54"), roundColor: UIColor(hexString: "#CBD2FA"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#4D7AFF"), roundColor: UIColor(hexString: "#CBD2FA"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#F6EB7D"), roundColor: UIColor(hexString: "#BC3A54"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#112156"), roundColor: UIColor(hexString: "#BC3A54"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#CBD2FA"), roundColor: UIColor(hexString: "#BC3A54"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#FFA25E"), roundColor: UIColor(hexString: "#BC3A54"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#4D7AFF"), roundColor: UIColor(hexString: "#BC3A54"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#CBD2FA"), roundColor: UIColor(hexString: "#FFA25E"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#4D7AFF"), roundColor: UIColor(hexString: "#FFA25E"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#BC3A54"), roundColor: UIColor(hexString: "#FFA25E"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#F6EB7D"), roundColor: UIColor(hexString: "#FFA25E"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#BC3A54"), roundColor: UIColor(hexString: "#F6EB7D"), centerLocation: 0.23, roundLocation: 1),
        IconGradient(centerColor: UIColor(hexString: "#4D7AFF"), roundColor: UIColor(hexString: "#F6EB7D"), centerLocation: 0.23, roundLocation: 1)
    ]
    
    func gradient(for gradientId: Int) -> IconGradient {
        guard let gradient = storage[safe: gradientId - 1] else {
            anytypeAssertionFailure("Gradient not found", info: ["gradientId": "\(gradientId)"])
            return fallbackGradient
        }
        
        return gradient
    }
    
    static func gradient(for gradientId: Int) -> IconGradient {
        let storage = IconGradientStorage()
        return storage.gradient(for: gradientId)
    }
    
    func allGradients() -> [IconGradient] {
        return storage
    }
}
