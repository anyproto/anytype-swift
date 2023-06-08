import Foundation
import SwiftUI
import AnytypeCore

// Needs refactoring - https://linear.app/anytype/issue/IOS-978
struct SwiftUIObjectIconImageView: View {
    
    let iconImage: ObjectIconImage
    let usecase: ObjectIconImageUsecase
    
    var body: some View {
        if FeatureFlags.homeWidgets {
            NewSwiftUIObjectIconImageView(iconImage: iconImage, usecase: usecase)
        } else {
            LegacySwiftUIObjectIconImageView(iconImage: iconImage, usecase: usecase)
        }
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

struct NewSwiftUIObjectIconImageView: View {
    
    @ObservedObject private var model = SwiftUIObjectIconImageViewModel()
    
    init(iconImage: ObjectIconImage, usecase: ObjectIconImageUsecase) {
        model.update(iconImage: iconImage, usecase: usecase)
    }
    
    var body: some View {
        Image(uiImage: model.image)
    }
}

struct LegacySwiftUIObjectIconImageView: UIViewRepresentable {
    let iconImage: ObjectIconImage
    let usecase: ObjectIconImageUsecase
    
    func makeUIView(context: Context) -> ObjectIconImageView {
        ObjectIconImageView()
    }

    func updateUIView(_ uiView: ObjectIconImageView, context: Context) {
        uiView.configure(
            model: ObjectIconImageView.Model(
                iconImage: iconImage,
                usecase: usecase
            )
        )
    }
}
