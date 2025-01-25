//
//  ImageProcessor.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import Foundation
import UIKit

class ImageProcessor {
    
    /// API Key for Google Cloud Vision API
    private let apiKey = "AIzaSyCj6EZSWC77BzACS0WpH5djMwaAXc_tsCw"
    
    func processImage(image: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else {
            completion(.failure(NSError(domain: "InvalidImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image"])))
            return
        }
        
        let base64String = imageData.base64EncodedString()
        sendToServer(base64: base64String, completion: completion)
    }

    /// Send Base64 image to Google Cloud Vision API and get the processed response
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
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                    }
                    if let data = data {
                        print("Response Data: \(String(data: data, encoding: .utf8) ?? "Invalid Response")")
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

                // Process annotations and draw bounding boxes
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

    /// Process annotations and draw bounding boxes on the original image
    private func processAnnotations(annotations: [[String: Any]], base64: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64),
              let selectedImage = UIImage(data: imageData) else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(selectedImage.size, false, 0.0)
        selectedImage.draw(at: .zero)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        for annotation in annotations {
            if
                let boundingPoly = annotation["boundingPoly"] as? [String: Any],
                let vertices = boundingPoly["vertices"] as? [[String: Any]]
            {
                let points = vertices.compactMap { vertex in
                    CGPoint(
                        x: (vertex["x"] as? CGFloat) ?? 0,
                        y: (vertex["y"] as? CGFloat) ?? 0
                    )
                }

                if points.count == 4 {
                    context.setStrokeColor(UIColor.white.cgColor)
                    context.setLineWidth(2.0)
                    context.stroke(CGRect(x: points[0].x, y: points[0].y, width: points[2].x - points[0].x, height: points[2].y - points[0].y))

                    // Draw text inside bounding box
                    if let description = annotation["description"] as? String {
                        let font = UIFont.systemFont(ofSize: 12)
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: font,
                            .foregroundColor: UIColor.black
                        ]
                        description.draw(in: CGRect(x: points[0].x, y: points[0].y, width: points[2].x - points[0].x, height: points[2].y - points[0].y), withAttributes: attributes)
                    }
                }
            }
        }

        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return processedImage
    }
}
