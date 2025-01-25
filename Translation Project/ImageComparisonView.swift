//
//  ImageComparisonView.swift
//  Translation Project
//
//  Created by Ali on 1/25/25.
//


import SwiftUI

struct ImageComparisonView: View {
    let originalImage: UIImage
    let processedImage: UIImage

    @State private var isDetentExpanded: Bool = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)

                    BottomSheetView(
                        isExpanded: $isDetentExpanded,
                        originalImage: originalImage
                    )
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct BottomSheetView: View {
    @Binding var isExpanded: Bool
    let originalImage: UIImage

    var body: some View {
        VStack {
            if isExpanded {
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("Original Image")
                    .font(.headline)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0 {
                        isExpanded = true
                    } else if value.translation.height > 0 {
                        isExpanded = false
                    }
                }
        )
    }
}