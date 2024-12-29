import SwiftUI

struct ProcessedImageView: View {
    let processedImage: UIImage
    let originalImage: UIImage?

    @State private var showOriginal = false

    var body: some View {
        VStack {
            Image(uiImage: processedImage)
                .resizable()
                .scaledToFit()
                .padding()

            Button("Show Original Image") {
                showOriginal.toggle()
            }
            .sheet(isPresented: $showOriginal) {
                if let originalImage = originalImage {
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Text("Original image not available.")
                }
            }
        }
    }
}
