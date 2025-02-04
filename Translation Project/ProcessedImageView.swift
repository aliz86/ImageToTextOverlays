import SwiftUI

struct ProcessedImageView: View {
    var processedImage: UIImage
    var originalImage: UIImage

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero



    var body: some View {
        NavigationView { // Use NavigationView for top bar
            ZStack {
                // Original image that users can zoom and pan
                VStack {
                    Text("Original Image")
                        .font(.title)
                        .padding()
                        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))

                    Image(uiImage: processedImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .clipped() // Important: Clips the image to its frame to prevent it from going off-screen
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    scale = scale * delta // Smooth scaling
                                    lastScale = value
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    scale = min(max(scale, 1), 3) // Limit zoom
                                }
                        )
                        .simultaneousGesture( // Combine with drag gesture
                            DragGesture()
                                .onChanged { value in
                                    let deltaX = value.translation.width - lastOffset.width
                                    let deltaY = value.translation.height - lastOffset.height
                                    offset = CGSize(width: offset.width + deltaX, height: offset.height + deltaY)
                                    lastOffset = value.translation
                                }
                                .onEnded { _ in
                                    lastOffset = .zero
                                }
                        )
                        
                    Spacer()
                }
                .background(Color.white.opacity(0.7))
                .cornerRadius(16)
                .padding()
            }
            .navigationTitle("Processed Image") // Set navigation title
        } // End of NavigationView
    }
}
