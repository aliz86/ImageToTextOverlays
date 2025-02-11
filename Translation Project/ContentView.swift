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
    // Remove unused state variables
    // @State private var isSheetExpanded = true
    // @State private var sheetDetent: PresentationDetent = .fraction(0.14)
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    imageSelectionView
                    processedImageLink
                    processButton
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
                        Text("Select the Image")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
            }
        }
        .onTapGesture {
            isImagePickerPresented.toggle()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $viewModel.selectedImage)
        }
    }
    
    private var processedImageLink: some View {
        Group {
            if let processedImage = viewModel.processedImage {
                NavigationLink(
                    destination: ProcessedImageView(
                        processedImage: processedImage,
                        originalImage: viewModel.selectedImage!
                    )
                ) {
                    Text("View Processed Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var processButton: some View {
        Group {
            if viewModel.selectedImage != nil {
                Button("Process Image") {
                    viewModel.processImage()
                }
                .buttonStyle(GradientButtonStyle())
                .disabled(viewModel.isProcessing)
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
