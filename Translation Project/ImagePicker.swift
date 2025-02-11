//
//  ImagePicker.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @ObservedObject var viewModel: ImageProcessorViewModel // Inject the ViewModel

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, viewModel: viewModel)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        var viewModel: ImageProcessorViewModel

        init(parent: ImagePicker, viewModel: ImageProcessorViewModel) {
                    self.viewModel = viewModel
            self.parent = parent
                }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                viewModel.reset() // Call reset here when new image is picked
                parent.image = uiImage
                //
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
