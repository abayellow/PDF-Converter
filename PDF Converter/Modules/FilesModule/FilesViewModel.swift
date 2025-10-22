//
//  FilesViewModel.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import SwiftUI
import Combine

@MainActor
class FilesViewModel: ObservableObject {
    @Published var pdfDocuments: [PDFDocumentItem] = []
    @Published var showSheet: Bool = false
    @Published var showMergeSelector: Bool = false
    @Published var selectedPDFForMerge: PDFDocumentItem? = nil

    // MARK: - PDF Creation
    func addPDF(from images: [UIImage], name: String) {
        if let url = PDFService.createPDF(from: images, name: name) {
            let firstImage = images.first ?? UIImage()
            let newDoc = PDFDocumentItem(name: name, url: url, preview: firstImage, date: Date())
            pdfDocuments.append(newDoc)
        }
    }
    
    func addPDF(from files: [URL], name: String) {
        if let url = PDFService.createPDFFromFiles(urls: files, name: name) {
            let preview = PDFService.generatePreview(from: url, size: CGSize(width: 100, height: 100))
            let newDoc = PDFDocumentItem(name: name, url: url, preview: preview, date: Date())
            pdfDocuments.append(newDoc)
        }
    }
    


    // MARK: - Merge
    func selectPDFForMerge(_ doc: PDFDocumentItem) {
        selectedPDFForMerge = doc
        showMergeSelector = true
    }

    func mergePDFs(with target: PDFDocumentItem) {
        guard let first = selectedPDFForMerge,
              let mergedURL = PDFService.mergePDFs(first: first.url, second: target.url, outputName: "\(first.name) + \(target.name)") else { return }

        let preview = first.preview
        let mergedDoc = PDFDocumentItem(name: "\(first.name) + \(target.name)", url: mergedURL, preview: preview, date: Date())
        pdfDocuments.append(mergedDoc)
        showMergeSelector = false
        selectedPDFForMerge = nil
    }

    // MARK: - Actions
    func delete(_ doc: PDFDocumentItem) {
        pdfDocuments.removeAll { $0.id == doc.id }
    }

    func share(_ doc: PDFDocumentItem) {
        guard let root = UIApplication.shared.windows.first?.rootViewController else { return }
        let vc = UIActivityViewController(activityItems: [doc.url], applicationActivities: nil)
        root.present(vc, animated: true)
    }
}
