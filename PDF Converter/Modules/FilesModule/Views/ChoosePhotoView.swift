//
//  ChoosePhotoView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ChoosePhotoView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var selectedFiles: [URL] = []
    @State private var showPhotoPicker = false
    @State private var showFilePicker = false
    @State private var showNameAlert = false
    @State private var pdfName = ""
    @Environment(\.dismiss) private var dismiss
    
    private var allImages: [UIImage] {
        var images = selectedImages
        for file in selectedFiles {
            if let data = try? Data(contentsOf: file),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        return images
    }
    
    var onConvert: (String, [UIImage], [URL]) -> Void


    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            TitleView()
            HStack(spacing: 40) {
                ChooseCellView(image: .apple, title: "Photos") {
                    showPhotoPicker = true
                }

                ChooseCellView(image: .files, title: "Files") {
                    showFilePicker = true
                }
            }

            if !allImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(allImages.indices, id: \.self) { index in
                            Image(uiImage: allImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }


            if !selectedImages.isEmpty || !selectedFiles.isEmpty {
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

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showPhotoPicker) {
            ImagePickerView(images: $selectedImages)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPickerView(selectedFiles: $selectedFiles)
                .ignoresSafeArea()
        }
        .overlay {
            if showNameAlert {
                CustomAlertView(
                    text: $pdfName,
                    onCancel: { withAnimation(.easeInOut(duration: 0.2)) { showNameAlert = false } },
                    onSave: {
                        guard !pdfName.isEmpty else { return }
                        onConvert(pdfName, selectedImages, selectedFiles)
                        dismiss()
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.5), value: showNameAlert)
                .zIndex(1)
            }
        }
    }
}

// MARK: - Subviews

struct TitleView: View {

    var body: some View {
        VStack(spacing: 6) {
            Text("Choose Source")
                .font(.title2.bold())
                .foregroundColor(.blue)
            Text("You can either choose from Photos or Files.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

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
    ChoosePhotoView { name, images, files in
        print("Convert \(images.count) images and \(files.count) files to \(name).pdf")
    }
}

