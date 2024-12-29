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
    @Published var showProcessedView: Bool = false

    private let processor = ImageProcessor()

    func processImage() {
        guard let image = selectedImage else { return }
        isProcessing = true

        processor.processImage(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                switch result {
                case .success(let processedImage):
                    self?.processedImage = processedImage
                    self?.showProcessedView = true
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
