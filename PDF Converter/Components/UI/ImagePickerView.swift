//
//  ImagePickerView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI
import PhotosUI


struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView
        init(_ parent: ImagePickerView) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let group = DispatchGroup()
            var pickedImages: [UIImage] = []

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        pickedImages.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.parent.images.append(contentsOf: pickedImages)
                self.parent.dismiss()
            }
        }
    }
}
