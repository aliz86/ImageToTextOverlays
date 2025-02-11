//
//  ContentView.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//
//
//  ContentView.swift
//  Translation Project
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImageProcessorViewModel()
    @State private var isImagePickerPresented = false
    @State private var navigationLinkActive = false // For activating NavigationLink

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    imageSelectionView
                    processAndViewButton
                }

                if viewModel.isProcessing {
                    loadingOverlay
                }
            }
            .padding()
        }
    }
    
    // Break down into smaller views for better readability
    private var imageSelectionView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 2)
            
            if let selectedImage = viewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(1)
                    .cornerRadius(16)
            } else {
                VStack {
                        Image("background1") // Ensure background1 exists in Assets
                            .resizable()
                            .padding(4)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                        Text("Select the Image to translate")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
            }
        }
        .onTapGesture {
            isImagePickerPresented.toggle()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $viewModel.selectedImage, viewModel: viewModel)
        }
    }
    
    private var processAndViewButton: some View {
        Group { // Wrap in a Group to provide a consistent return type
            if viewModel.selectedImage != nil {
                NavigationLink(isActive: $navigationLinkActive) {
                    if let processedImage = viewModel.processedImage,
                       let originalImage = viewModel.selectedImage {  // Make sure both images are available
                        ProcessedImageView(processedImage: processedImage, originalImage: originalImage)
                    } else {
                        // Show a placeholder or progress view while processing
                        ProgressView("Processing...")  // Or Text("Processing...")
                    }
                } label: {
                    Button(viewModel.processedImage == nil ? "Process Image" : "View Processed Image") {
                        if viewModel.processedImage == nil {
                            viewModel.processImage { success in // Completion handler to ensure processing finished
                                if success { // if processed image available
                                    navigationLinkActive = true
                                }
                            }


                        } else {
                            navigationLinkActive = true
                        }
                    }
                    .buttonStyle(GradientButtonStyle())
                    .disabled(viewModel.isProcessing)
                }
            } else {
                 // Placeholder for when no image is selected
                //Text("Select an image to begin.") // or another view
            }
        }
    }
    
 
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView("Processing...")
                .foregroundColor(.white)
                .scaleEffect(1.5)
                .padding()
        }
    }
}

// 2. Custom Button Style
struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(radius: 10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
