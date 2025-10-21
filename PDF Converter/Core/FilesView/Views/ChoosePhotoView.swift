//
//  ChoosePhotoView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI
import PhotosUI

struct ChoosePhotoView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var showPhotoPicker = false
    @State private var showNameAlert = false
    @State private var pdfName = ""
    
    var onConvert: (String, [UIImage]) -> Void // передаем имя и изображения
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Photo")
                .font(.title2.bold())
                .foregroundColor(.blue)

            Text("You can either choose from Photos or Files.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 40) {
                ChooseCellView(image: .apple, title: "Photos") {
                    showPhotoPicker = true
                }

                ChooseCellView(image: .files, title: "Files") {
                    print("Files tapped")
                }
            }

            // Показ выбранных фото
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)

                // Кнопка Convert
                Button("Convert") {
                    showNameAlert = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding()
        .sheet(isPresented: $showPhotoPicker) {
            ImagePickerView(images: $selectedImages)
        }
        .alert("Save PDF", isPresented: $showNameAlert, actions: {
            TextField("PDF Name", text: $pdfName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !pdfName.isEmpty {
                    onConvert(pdfName, selectedImages)
                    dismiss() // закрываем ChoosePhotoView sheet
                }
            }
        })
    }
}

//struct ChoosePhotoView: View {
//    @State private var selectedImages: [UIImage] = []
//    @State private var showPhotoPicker = false
//    var onConvert: ([UIImage]) -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Choose Photo")
//                .font(.title2.bold())
//                .foregroundColor(.blue)
//
//            Text("You can either choose from Photos or Files.")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            HStack(spacing: 40) {
//                ChooseCellView(image: .apple, title: "Photos") {
//                    showPhotoPicker = true
//                }
//
//                ChooseCellView(image: .files, title: "Files") {
//                    print("Files tapped")
//                }
//            }
//
//            // Показ выбранных фото
//            if !selectedImages.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        ForEach(selectedImages.indices, id: \.self) { index in
//                            Image(uiImage: selectedImages[index])
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 100, height: 100)
//                                .cornerRadius(12)
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .frame(height: 120)
//
//                // Кнопка Convert
//                Button(action: {
//                    onConvert(selectedImages) // 🔑 передаем изображения наружу
//                }) {
//                    Text("Convert")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(12)
//                        .padding(.horizontal)
//                }
//            }
//        }
//        .padding()
//        .sheet(isPresented: $showPhotoPicker) {
//            ImagePickerView(images: $selectedImages)
//        }
//    }
//}


// MARK: - Cell View
struct ChooseCellView: View {
    var image: ImageResource
    var title: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                ZStack {
                    Color.white
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        .frame(width: 100, height: 100)
                    
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.accentColor)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}



// MARK: - Preview
#Preview {
//    ChoosePhotoView()
}
