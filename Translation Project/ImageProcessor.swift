//
//  ImageProcessor.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import Foundation
import UIKit

class ImageProcessor {
    private let apiKey = "AIzaSyCj6EZSWC77BzACS0WpH5djMwaAXc_tsCw"
    
    func processImage(image: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else {
            completion(.failure(NSError(domain: "InvalidImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image"])))
            return
        }
        
        let base64String = imageData.base64EncodedString()
        sendToServer(base64: base64String, completion: completion)
    }
    
    func sendToServer(base64: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let requestPayload: [String: Any] = [
            "requests": [
                [
                    "image": [
                        "content": base64
                    ],
                    "features": [
                        [
                            "type": "TEXT_DETECTION",
                            "maxResults": 10
                        ]
                    ]
                ]
            ]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestPayload) else {
            completion(.failure(NSError(domain: "Invalid Payload", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }

            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard
                    let responses = responseJSON?["responses"] as? [[String: Any]],
                    let annotations = responses.first?["textAnnotations"] as? [[String: Any]]
                else {
                    completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                    return
                }

                if let processedImage = self.processAnnotations(annotations: annotations, base64: base64) {
                    completion(.success(processedImage))
                } else {
                    completion(.failure(NSError(domain: "Image Processing Failed", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    private func processAnnotations(annotations: [[String: Any]], base64: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64),
              let selectedImage = UIImage(data: imageData) else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(selectedImage.size, false, 0.0)
        selectedImage.draw(at: .zero) // Draw the original image first

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Skip the first annotation as it represents the entire detected text block
        for annotation in annotations.dropFirst() {
            if let boundingPoly = annotation["boundingPoly"] as? [String: Any],
               let vertices = boundingPoly["vertices"] as? [[String: Any]] {
                
                // Calculate the bounding box coordinates
                let points = vertices.compactMap { vertex in
                    CGPoint(
                        x: (vertex["x"] as? CGFloat) ?? 0,
                        y: (vertex["y"] as? CGFloat) ?? 0
                    )
                }

                if points.count == 4 {
                    // Bounding box for the detected word
                    let rect = CGRect(
                        x: points[0].x,
                        y: points[0].y,
                        width: points[2].x - points[0].x,
                        height: points[2].y - points[0].y
                    )

                    // Only draw a background for detected words (no global fill)
                    context.setFillColor(UIColor(white: 1.0, alpha: 0.7).cgColor)
                    context.fill(rect) // Fill only the word bounding box

                    // Draw the bounding box outline (black color) around the word
                    context.setStrokeColor(UIColor.black.cgColor)
                    context.setLineWidth(2.0)
                    context.stroke(rect)

                    // Draw the detected text inside the bounding box
                    if let description = annotation["description"] as? String {
                        // Adjust font size to fit the bounding box height, but ensure it scales correctly with width too
                        let maxFontSize = rect.height // Max possible font size based on the height
                        var fontSize = maxFontSize
                        var textSize: CGSize = .zero

                        // Adjust font size to ensure the text fits inside the bounding box
                        repeat {
                            let font = UIFont.systemFont(ofSize: fontSize)
                            let attributes: [NSAttributedString.Key: Any] = [
                                .font: font,
                                .foregroundColor: UIColor.black
                            ]
                            textSize = description.size(withAttributes: attributes)
                            fontSize -= 1
                        } while (textSize.width > rect.width || textSize.height > rect.height) && fontSize > 5 // Ensure text fits both width and height

                        // Draw the text inside the bounding box, centered
                        let font = UIFont.systemFont(ofSize: fontSize)
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: font,
                            .foregroundColor: UIColor.black
                        ]
                        let attributedString = NSAttributedString(string: description, attributes: attributes)
                        let textRect = CGRect(
                            x: rect.origin.x + (rect.width - textSize.width) / 2,
                            y: rect.origin.y + (rect.height - textSize.height) / 2,
                            width: textSize.width,
                            height: textSize.height
                        )
                        attributedString.draw(in: textRect)
                    }
                }
            }
        }

        // Get the final processed image
        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return processedImage
    }

}
