//
//  ProcessedImageView.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import SwiftUI

struct ProcessedImageView: View {
    let originalImage: UIImage?
    let processedImage: UIImage?

    var body: some View {
        VStack {
            if let processedImage = processedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            
            Text("Original Image")
                .font(.headline)
                .padding(.top)
            
            if let originalImage = originalImage {
                Image(uiImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
        }
        .navigationTitle("Processed Image")
    }
}
