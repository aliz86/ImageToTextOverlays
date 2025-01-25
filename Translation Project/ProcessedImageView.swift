//
//  ProcessedImageView.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import SwiftUI

struct ProcessedImageView: View {
    let processedImage: UIImage
    let originalImage: UIImage
    @State private var showOriginalImage = false

    var body: some View {
        ZStack {
            // Processed Image (fills the screen)
            Image(uiImage: processedImage)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)

            // Bottom Sheet for Original Image
            GeometryReader { geometry in
                VStack {
                    if showOriginalImage {
                        Image(uiImage: originalImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.7) // Adjust as needed
                    } else {
                        Text("Original Image")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .cornerRadius(16)
                .padding(.horizontal)
                .offset(y: showOriginalImage ? geometry.size.height * 0.1 : geometry.size.height * 0.7)
                .animation(.spring(), value: showOriginalImage)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < 0 {
                        showOriginalImage = true
                    } else if value.translation.height > 0 {
                        showOriginalImage = false
                    }
                }
        )
    }
}
