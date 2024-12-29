//
//  ImageProcessor.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import UIKit

class ImageProcessor {
    func processImage(image: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else {
            completion(.failure(NSError(domain: "InvalidImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image"])))
            return
        }
        
        let base64String = imageData.base64EncodedString()
        sendToServer(base64: base64String, completion: completion)
    }

    private func sendToServer(base64: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: "https://your-server.com/api") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["image": base64, "id": UUID().uuidString], options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let processedImageBase64 = jsonResponse["processedImage"] as? String,
                  let imageData = Data(base64Encoded: processedImageBase64),
                  let processedImage = UIImage(data: imageData) else {
                completion(.failure(NSError(domain: "ServerResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                return
            }
            
            completion(.success(processedImage))
        }.resume()
    }
}
