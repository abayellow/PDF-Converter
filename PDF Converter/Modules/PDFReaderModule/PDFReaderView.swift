//
//  PDFReaderView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//


import SwiftUI
import PDFKit

struct PDFReaderView: View {
    @State private var document: PDFDocument
    @State private var selectedPageIndex: Int?
    @State private var showDeleteAlert = false
    @State private var pdfURL: URL
    @Environment(\.dismiss) private var dismiss

    init(pdfURL: URL) {
        self._pdfURL = State(initialValue: pdfURL)
        self._document = State(initialValue: PDFReaderView.loadDocument(from: pdfURL))
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "PDF Reader", subtitile: "Read your PDF files")

            PDFKitView(document: $document, selectedPageIndex: $selectedPageIndex)
                .edgesIgnoringSafeArea(.bottom)

            if let index = selectedPageIndex {
                DeletePageButton(index: index) {
                    showDeleteAlert = true
                }
            }
        }
        .alert("Delete page?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive, action: deleteSelectedPage)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .navigationBarHidden(true)
    }

    private func deleteSelectedPage() {
        guard let index = selectedPageIndex else { return }
        document.removePage(at: index)
        if FileManager.default.fileExists(atPath: pdfURL.path) {
            document.write(to: pdfURL)
        } else {
            print("Не удалось сохранить: файл отсутствует по пути \(pdfURL.path)")
        }
        selectedPageIndex = nil
    }

    // MARK: - Document Loading
    private static func loadDocument(from url: URL) -> PDFDocument {
        if FileManager.default.fileExists(atPath: url.path),
           let doc = PDFDocument(url: url) {
            return doc
        } else {
            let empty = PDFDocument()
            if let img = UIImage(systemName: "xmark.octagon"),
               let page = PDFPage(image: img) {
                empty.insert(page, at: 0)
            }
            print("PDF-файл не найден по пути: \(url.path)")
            return empty
        }
    }
}

// MARK: - Delete Button Component
struct DeletePageButton: View {
    let index: Int
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Text("Delete Page \(index + 1)")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
        }
    }
}

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


