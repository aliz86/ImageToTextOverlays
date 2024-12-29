import UIKit

func drawTextOnImage(image: UIImage, blocks: [Block]) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    guard let context = UIGraphicsGetCurrentContext(), let cgImage = image.cgImage else { return nil }

    let imageRect = CGRect(origin: .zero, size: image.size)
    context.draw(cgImage, in: imageRect)

    for block in blocks {
        let rect = CGRect(x: block.x, y: block.y, width: block.width, height: block.height)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let text = NSString(string: block.text)
        text.draw(in: rect, withAttributes: attributes)
    }

    let processedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return processedImage
}
