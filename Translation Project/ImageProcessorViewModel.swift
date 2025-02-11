//
//  ImageProcessorViewModel.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import SwiftUI

class ImageProcessorViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing: Bool = false

    private let processor = ImageProcessor()

    func processImage(completion: @escaping (Bool) -> Void) { // Completion handler
        guard let image = selectedImage else {
            completion(false) // Call completion with false if no image
            return
        }
        isProcessing = true

        processor.processImage(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false

                switch result {
                case .success(let processedImage):
                    self?.processedImage = processedImage
                    completion(true) // Call completion with true on success
                case .failure(let error):
                    print("Error processing image: \(error)")
                    completion(false) // Call completion with false on failure
                }
            }
        }
    }
    
    func reset() {  // New function to reset the state
        selectedImage = nil
        processedImage = nil
        isProcessing = false
    }
}
