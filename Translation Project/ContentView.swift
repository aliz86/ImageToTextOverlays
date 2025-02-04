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
    @State private var navigateToPage2 = false
    @State private var isSheetExpanded = true  // State variable to control sheet expansion
    @State private var sheetDetent: PresentationDetent = .fraction(0.14) // Start with the small detent

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
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

                    // Processed Image NavigationLink using NavigationLink(value: processedImage)
                    if let processedImage = viewModel.processedImage {
                        VStack {}
                            .sheet(isPresented: $navigateToPage2) {
                                ProcessedImageView(processedImage: processedImage, originalImage: viewModel.selectedImage!)
                                    .presentationDetents((isSheetExpanded || navigateToPage2) ? [.large] : [.fraction(0.14), .large])  // Control detent based on state
                                    .presentationDragIndicator(.visible)
                                    .interactiveDismissDisabled(false)
                                    .onAppear {
                                                                        // Expand to large detent when the sheet appears
                                                                        sheetDetent = .large
                                                                    }
                            }
                            .onAppear {
                                DispatchQueue.global().asyncAfter(deadline: .now()) {
                                    DispatchQueue.main.async {
                                        navigateToPage2.toggle()
                                    }
                                }
                            }
                            
                    }

                    // Process Image Button
                    if viewModel.selectedImage != nil {
                        Button("Process Image") {
                            viewModel.processImage()
                            isSheetExpanded = false  // Make the sheet contract after the image is processed
                        }
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
            .navigationDestination(for: UIImage.self) { processedImage in
                ImageComparisonView(
                    originalImage: viewModel.selectedImage!,
                    processedImage: processedImage
                )
            }
            .padding()
            .navigationTitle("Image Processor")
        }
    }
}
