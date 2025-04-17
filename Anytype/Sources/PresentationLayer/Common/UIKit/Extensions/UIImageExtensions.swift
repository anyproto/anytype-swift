import CoreGraphics
import UIKit
import AnytypeCore

extension UIImage {
    
    static func dynamicImage(light: UIImage, dark: UIImage) -> UIImage {
        let config = UITraitCollection(traitsFrom: [.current, .init(userInterfaceStyle: .dark)])
        light.imageAsset?.register(dark, with: config)
        return light
   }
    
    static func generateDynamicImage(builder: () -> UIImage) -> UIImage {
        
        let lightTC = UITraitCollection(traitsFrom: [.current, .init(userInterfaceStyle: .light)])
        let darkTC = UITraitCollection(traitsFrom: [.current, .init(userInterfaceStyle: .dark)])
        
        var lightImage = UIImage()
        var darkImage = UIImage()
        
        lightTC.performAsCurrent {
            lightImage = builder()
        }
        darkTC.performAsCurrent {
            darkImage = builder()
        }
        
        return UIImage.dynamicImage(light: lightImage, dark: darkImage)
    }
    
    @MainActor
    func circleImage(width: CGFloat, opaque: Bool = false, backgroundColor: CGColor? = nil) -> UIImage {
        cropToSquare()
        .scaled(to: CGSize(width: width, height: width))
        .rounded(radius: width / 2, opaque: opaque, backgroundColor: backgroundColor)
    }
    
    
    /// Makes rounded image with given corner radius.
    ///
    /// - Parameter radius: The corner radius.
    /// - Parameter opaque: A Boolean flag indicating whether the bitmap is opaque.
    /// If you know the bitmap is fully opaque, specify YES to ignore the alpha channel and optimize
    /// the bitmap’s storage.
    /// Specifying NO means that the bitmap must include an alpha channel to handle any partially
    /// transparent pixels
    /// - Returns: Rounded image.
    @MainActor
    func rounded(radius: CGFloat, opaque: Bool = false, backgroundColor: CGColor? = nil) -> UIImage {
        guard radius > 0 else { return self }
        
        let rect = CGRect(origin: .zero, size: self.size)

        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, UIScreen.main.scale)

        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }

        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor)
            context.fill(rect)
        }

        context.beginPath()
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: radius, y: radius)

        let rectWidth = rect.width / radius
        let rectHeight = rect.height / radius

        let path = CGMutablePath()
        path.move(to: CGPoint(x: rectWidth, y: rectHeight / 2))
        path.addArc(tangent1End: CGPoint(x: rectWidth, y: rectHeight), tangent2End: CGPoint(x: rectWidth / 2, y: rectHeight), radius: 1)
        path.addArc(tangent1End: CGPoint(x: 0, y: rectHeight), tangent2End: CGPoint(x: 0, y: rectHeight / 2), radius: 1)
        path.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: rectWidth / 2, y: 0), radius: 1)
        path.addArc(tangent1End: CGPoint(x: rectWidth, y: 0), tangent2End: CGPoint(x: rectWidth, y: rectHeight / 2), radius: 1)
        context.addPath(path)
        context.restoreGState()
        context.closePath()
        context.clip()

        draw(in: rect)

        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()

        return roundedImage ?? self
    }
    
    @MainActor
    static func linearGradient(size: CGSize,
                         startColor: UIColor,
                         endColor: UIColor,
                         startPoint: CGPoint,
                         endPoint: CGPoint) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
                
        return renderer.image { ctx in
            let gradient = CAGradientLayer()
            gradient.bounds = ctx.format.bounds
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.locations = [0, 1]

            gradient.render(in: ctx.cgContext)
        }
    }
    
    /// Use this method when you want to crop image of create new one with paddings
    ///
    /// - Parameters:
    ///   - size: Size of new image
    ///   - offset: Origin of where to start drawing current image
    /// - Returns: New image
    func imageDrawn(on size: CGSize, offset: CGPoint) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: size))
        return renderer.image { context in
            draw(in: CGRect(origin: offset, size: self.size))
        }
    }
    
    /// Create new image with desired size
    ///
    /// - Parameters:
    ///   - scaledSize: Size of new image
    /// - Returns: New image
    func scaled(to scaledSize: CGSize, cropToBounds: Bool = false) -> UIImage {
        let rect = CGRect(origin: .zero, size: scaledSize)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { _ in draw(in: rect)}
    }
    
    func cropToSquare() -> UIImage {
            let cgimage = cgImage!
            let contextImage: UIImage = UIImage(cgImage: cgimage)
            let contextSize: CGSize = contextImage.size
        
            let posX: CGFloat
            let posY: CGFloat
            let cgwidth: CGFloat
            let cgheight: CGFloat

            // See what size is longer and create the center off of that
            if contextSize.width > contextSize.height {
                posX = ((contextSize.width - contextSize.height) / 2)
                posY = 0
                cgwidth = contextSize.height
                cgheight = contextSize.height
            } else {
                posX = 0
                posY = ((contextSize.height - contextSize.width) / 2)
                cgwidth = contextSize.width
                cgheight = contextSize.width
            }

            let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

            // Create bitmap image from context using the rect
            let imageRef: CGImage = cgimage.cropping(to: rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            let image: UIImage = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)

            return image
        }

    static func image(
        imageSize: CGSize,
        cornerRadius: CGFloat,
        side: CGFloat,
        foregroundColor: UIColor?,
        backgroundColor: UIColor?
    ) -> UIImage {
        .generateDynamicImage {
            let size = CGSize(width: side, height: side)
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { actions in
                let context = actions.cgContext
                
                let rect = CGRect(origin: .zero, size: size)
                let rectPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
                context.addPath(rectPath.cgPath)
                backgroundColor.map { context.setFillColor($0.cgColor) }
                context.fillPath()
            }
            
            
            let x = (size.width - imageSize.width) / 2
            let y = (size.height - imageSize.height) / 2
            
            return renderer.image { _ in 
                image.applyTint(color: foregroundColor)
                    .scaled(to: imageSize)
                    .draw(
                        at: .init(x: x, y: y),
                        blendMode: .normal,
                        alpha: 1.0
                    )
            }
        }
    }

    func rotate(radians: Float) -> UIImage {
        var newSize = CGRect(origin: CGPoint.zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size

        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!


        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))

        draw(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }

    
    @MainActor
    static func imageWithText(
        _ text: String,
        textColor: UIColor,
        backgroundColor: UIColor,
        font: AnytypeFont,
        size: CGSize,
        cornerRadius: CGFloat
    ) -> UIImage? {

        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.textColor = textColor
        nameLabel.font = font.uiKitFont
        nameLabel.text = text

        let backgroundView = UIView(frame: frame)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.addSubview(nameLabel) {
            $0.centerX.equal(to: backgroundView.centerXAnchor)
            $0.centerY.equal(to: backgroundView.centerYAnchor)
        }

        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.layer.masksToBounds = true
        
        return backgroundView.drawToImage()
    }

    @MainActor
    static func circleImage(
        size: CGSize,
        fillColor: UIColor,
        borderColor: UIColor,
        borderWidth: CGFloat
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()

        format.scale = UIApplication.shared.keyWindow?.screen.scale ?? 0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(fillColor.cgColor)
            ctx.cgContext.setStrokeColor(borderColor.cgColor)
            ctx.cgContext.setLineWidth(borderWidth)

            let delta = borderWidth/2
            let rectangle = CGRect(
                x: 0, y: 0,
                width: size.width,
                height: size.height
            ).insetBy(dx: delta, dy: delta)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }

        return img
    }

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 50, height: 50)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    // MARK: - Private
    
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func averageColor() throws -> UIColor {
        guard let inputImage = CIImage(image: self) else { throw CommonError.undefined }
        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )

        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]
        ) else { throw CommonError.undefined }
        
        guard let outputImage = filter.outputImage else { throw CommonError.undefined }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    func centeredSquareImage() -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        let sideLenght = min(width, height)

        let xOffset = (width - sideLenght) / 2
        let yOffset = (height - sideLenght) / 2

        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLenght,
            height: sideLenght
        )

        if let imageRef = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: imageOrientation)
        }

        return nil
    }
    
    func applyTint(color: UIColor?) -> UIImage {
        if let color, renderingMode == .alwaysTemplate {
            return self.withTintColor(color).withRenderingMode(.alwaysOriginal)
        }
        return self
    }
}
