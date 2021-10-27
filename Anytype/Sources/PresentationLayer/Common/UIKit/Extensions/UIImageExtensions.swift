import CoreGraphics
import UIKit

extension UIImage {
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
    func rounded(radius: CGFloat, opaque: Bool = false, backgroundColor: CGColor? = nil) -> UIImage {
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
    
    static func gradient(size: CGSize,
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

    func image(
        imageSize: CGSize,
        cornerRadius: CGFloat,
        side: CGFloat,
        backgroundColor: UIColor?
    ) -> UIImage {
        let size = CGSize(width: side, height: side)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { actions in
            let context = actions.cgContext

            let rect = CGRect(origin: .zero, size: size)
            let rectPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            context.addPath(rectPath.cgPath)
            backgroundColor.map { context.setFillColor($0.cgColor) }
            context.fillPath()

            let x = (size.width - imageSize.width) / 2
            let y = (size.height - imageSize.height) / 2

            draw(
                at: .init(x: x, y: y),
                blendMode: .normal,
                alpha: 1.0
            )
        }
    }
}
