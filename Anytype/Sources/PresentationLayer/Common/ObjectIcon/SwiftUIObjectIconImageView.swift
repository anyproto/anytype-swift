import Foundation
import SwiftUI
import AnytypeCore

// Needs refactoring - https://linear.app/anytype/issue/IOS-978
struct SwiftUIObjectIconImageView: View {
    
    @ObservedObject private var model = SwiftUIObjectIconImageViewModel()
    
    let iconImage: ObjectIconImage
    let usecase: ObjectIconImageUsecase
    
    init(iconImage: ObjectIconImage, usecase: ObjectIconImageUsecase) {
        self.iconImage = iconImage
        self.usecase = usecase
        
        model.update(iconImage: iconImage, usecase: usecase)
    }
    
    var body: some View {
        Image(uiImage: model.image)
    }
}

final class SwiftUIObjectIconImageViewModel: ObservableObject {
    
    @Published var image = UIImage()

    private let uiView = ObjectIconImageView()
    private var observation: NSKeyValueObservation?
    
    init() {
        observation = uiView.imageView.observe(\.image, changeHandler: { [weak self] view, _ in
            self?.image = view.image ?? UIImage()
        })
    }
    
    func update(iconImage: ObjectIconImage, usecase: ObjectIconImageUsecase) {
        uiView.configure(
            model: ObjectIconImageView.Model(
                iconImage: iconImage,
                usecase: usecase
            )
        )
    }
}
