//
//  ContentView.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImageProcessorViewModel()
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
            ZStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 2)

                        if let selectedImage = viewModel.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                
                                .aspectRatio(contentMode: .fit)
                                //.scaledToFit()
                                //.frame(width: 300, height: 300)
                                .padding(1)
                                .cornerRadius(16)
                        } else {
                            VStack {
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 50, height: 50)
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
                    .onAppear {
                        NetworkMonitor.shared.startMonitoring()
                    }

                    if let processedImage = viewModel.processedImage {
                        NavigationLink(
                            destination: ProcessedImageView(
                                originalImage: viewModel.selectedImage,
                                processedImage: processedImage
                            ),
                            isActive: $viewModel.showProcessedView
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    }

                    if viewModel.selectedImage != nil {
                        Button("Process Image") {
                            viewModel.processImage()
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)) .cornerRadius(15) .shadow(radius: 10)
                    
                        .disabled(viewModel.isProcessing)
                        
                    }
                }

                // Loading Indicator Overlay
                if viewModel.isProcessing {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView("Processing...")
                        .foregroundColor(.white)
                        .scaleEffect(1.5)
                        .padding()
                        
                }
            }
            .padding()
            .navigationTitle("Image Processor")
        }
}
