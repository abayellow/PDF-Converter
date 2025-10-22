////
////  PDFReaderView.swift
////  PDF Converter
////
////  Created by Alexander Abanshin on 22.10.2025.
////
//


import SwiftUI
import PDFKit

struct PDFReaderView: View {
    @State var pdfURL: URL
    @State private var document: PDFDocument
    @State private var selectedPageIndex: Int?
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss

    init(pdfURL: URL) {
        self._pdfURL = State(initialValue: pdfURL)
        if let doc = PDFDocument(url: pdfURL) {
            self._document = State(initialValue: doc)
        } else {
            fatalError("Не удалось загрузить PDF по пути \(pdfURL)")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
//            navigationBar
            CustomNavigationBar(title: "PDF Reader")

            PDFKitView(document: $document, selectedPageIndex: $selectedPageIndex)
                .edgesIgnoringSafeArea(.bottom)

            // Кнопка удаления выбранной страницы
            if let index = selectedPageIndex {
                deleteButton(for: index)
            }
        }
        .alert("Delete page?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteSelectedPage()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subviews
private extension PDFReaderView {
    var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(pdfURL.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Spacer().frame(width: 30)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    func deleteButton(for index: Int) -> some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            Text("Delete Page \(index + 1)")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
        }
    }

    func deleteSelectedPage() {
        if let index = selectedPageIndex {
            document.removePage(at: index)
            document.write(to: pdfURL)
            selectedPageIndex = nil
        }
    }
}

// MARK: - Preview
#Preview {
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("TestPreview.pdf")
    if !FileManager.default.fileExists(atPath: tempURL.path) {
        let pdfDoc = PDFDocument()
        if let page = PDFPage(image: UIImage(systemName: "doc.text.image")!) {
            pdfDoc.insert(page, at: 0)
        }
        pdfDoc.write(to: tempURL)
    }
    return PDFReaderView(pdfURL: tempURL)
}


