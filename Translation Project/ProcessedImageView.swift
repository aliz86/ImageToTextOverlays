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
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green, lineWidth: 2)
                // Original image that users can zoom and pan
                VStack {
                    //Text("Processed Image")
                     //   .font(.title)
                        //.padding()
                      //  .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))

                    Image(uiImage: processedImage) // Your image name in assets
                                    .resizable()
                                    .scaledToFit()
                                    .zoomable(minZoomScale: 1, doubleTapZoomScale: 3) // Add the zoomable modifier
                                    //.frame(width: 300, height: 300) // Customize the frame size
                                    
                                    .aspectRatio(contentMode: .fit)
                                    //.cornerRadius(16)
                        
                    //Spacer()
                }
                
                .background(Color.white.opacity(0.7))
                .cornerRadius(16)
                .padding(2)
                
            }
            .padding(.horizontal)
            //.navigationTitle("Processed Image") // Set navigation title
        } // End of NavigationView
    }
}
