//
//  FilesViewModel.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

//
//  FilesViewModel.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import SwiftUI
import Combine
import CoreData

@MainActor
class FilesViewModel: ObservableObject {
    @Published var pdfDocuments: [PDFDocumentItem] = []
    @Published var showSheet: Bool = false
    @Published var showMergeSelector: Bool = false
    @Published var selectedPDFForMerge: PDFDocumentItem? = nil

    private let context = PersistenceController.shared.context

    init() {
        loadPDFs()
        // можно оставить миграцию (но loadPDFs делает проверку/обновление сам)
    }

    // MARK: - Load from Core Data
    func loadPDFs() {
        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            var loaded: [PDFDocumentItem] = []

            for entity in results {
                // safe unwraps
                guard let id = entity.id else {
                    // no id — delete bad entity
                    context.delete(entity)
                    continue
                }

                guard let name = entity.name else {
                    context.delete(entity)
                    continue
                }

                guard let urlString = entity.url else {
                    context.delete(entity)
                    continue
                }

                // Try original url
                var url = URL(string: urlString)

                // If url not valid or file doesn't exist - attempt to find equivalent in Documents
                var fileExists = false
                if let u = url {
                    fileExists = FileManager.default.fileExists(atPath: u.path)
                }

                if !fileExists {
                    // try to find in Documents with same lastPathComponent
                    let last = URL(string: urlString)?.lastPathComponent ?? "\(name).pdf"
                    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let candidate = docs.appendingPathComponent(last)
                    if FileManager.default.fileExists(atPath: candidate.path) {
                        // update entity.url to new location
                        entity.url = candidate.absoluteString
                        url = candidate
                        do { try context.save() } catch { print("Failed to update entity URL: \(error)") }
                        fileExists = true
                    }
                }

                if !fileExists {
                    // file truly doesn't exist anywhere — remove entity to avoid dead links
                    context.delete(entity)
                    continue
                }

                // preview
                var previewImage: UIImage = UIImage(systemName: "doc.richtext.fill") ?? UIImage()
                if let previewData = entity.preview, let img = UIImage(data: previewData) {
                    previewImage = img
                } else if let u = url, FileManager.default.fileExists(atPath: u.path) {
                    previewImage = PDFService.generatePreview(from: u, size: CGSize(width: 100, height: 100))
                }

                let date = entity.date ?? Date()
                guard let finalURL = url else { continue }

                let item = PDFDocumentItem(id: id, name: name, url: finalURL, preview: previewImage, date: date)
                loaded.append(item)
            }

            // Save possible deletions
            if context.hasChanges {
                do { try context.save() } catch { print("Core Data save error after cleaning: \(error)") }
            }

            self.pdfDocuments = loaded.sorted { $0.date > $1.date } // newest first

        } catch {
            print("Failed to fetch PDFs: \(error)")
        }
    }

    // MARK: - Save PDF to Core Data
    private func savePDFToCoreData(_ pdf: PDFDocumentItem) {
        // create entity
        let entity = PDFEntity(context: context)
        entity.id = pdf.id
        entity.name = pdf.name
        entity.url = pdf.url.absoluteString
        entity.date = pdf.date
        entity.preview = pdf.preview.jpegData(compressionQuality: 0.8)

        do {
            try context.save()
        } catch {
            print("Failed to save PDF: \(error)")
        }
    }

    // MARK: - Add PDF
    func addPDF(from images: [UIImage], name: String) {
        if let url = PDFService.createPDF(from: images, name: name) {
            let firstImage = images.first ?? UIImage()
            let newDoc = PDFDocumentItem(name: name, url: url, preview: firstImage, date: Date())
            pdfDocuments.insert(newDoc, at: 0)
            savePDFToCoreData(newDoc)
        }
    }

    func addPDF(from files: [URL], name: String) {
        if let url = PDFService.createPDFFromFiles(urls: files, name: name) {
            let preview = PDFService.generatePreview(from: url, size: CGSize(width: 100, height: 100))
            let newDoc = PDFDocumentItem(name: name, url: url, preview: preview, date: Date())
            pdfDocuments.insert(newDoc, at: 0)
            savePDFToCoreData(newDoc)
        }
    }

    // MARK: - Delete PDF
    func delete(_ doc: PDFDocumentItem) {
        // remove from array
        pdfDocuments.removeAll { $0.id == doc.id }

        // remove from Core Data and optionally delete file on disk
        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", doc.id as CVarArg)

        do {
            let results = try context.fetch(request)
            for entity in results {
                // try to remove file
                if let urlString = entity.url, let u = URL(string: urlString), FileManager.default.fileExists(atPath: u.path) {
                    do {
                        try FileManager.default.removeItem(at: u)
                    } catch {
                        // ignore file deletion errors, still remove entity
                        print("Failed to delete file at \(u): \(error)")
                    }
                }
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Failed to delete PDF: \(error)")
        }
    }

    // MARK: - Merge PDF
    func selectPDFForMerge(_ doc: PDFDocumentItem) {
        selectedPDFForMerge = doc
        showMergeSelector = true
    }

    func mergePDFs(with target: PDFDocumentItem) {
        guard let first = selectedPDFForMerge,
              let mergedURL = PDFService.mergePDFs(first: first.url, second: target.url, outputName: "\(first.name) + \(target.name)")
        else { return }

        let preview = first.preview
        let mergedDoc = PDFDocumentItem(name: "\(first.name) + \(target.name)", url: mergedURL, preview: preview, date: Date())
        pdfDocuments.insert(mergedDoc, at: 0)
        savePDFToCoreData(mergedDoc)

        showMergeSelector = false
        selectedPDFForMerge = nil
    }

    // MARK: - Share PDF
    func share(_ doc: PDFDocumentItem) {
        guard let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        let vc = UIActivityViewController(activityItems: [doc.url], applicationActivities: nil)
        root.present(vc, animated: true)
    }
}







//import SwiftUI
//import Combine
//import CoreData
//
//@MainActor
//class FilesViewModel: ObservableObject {
//    @Published var pdfDocuments: [PDFDocumentItem] = []
//    @Published var showSheet: Bool = false
//    @Published var showMergeSelector: Bool = false
//    @Published var selectedPDFForMerge: PDFDocumentItem? = nil
//    
//    private let context = PersistenceController.shared.context
//
//    init() {
//        loadPDFs()
//        migrateOldPDFsIfNeeded()
//    }
//
//    // MARK: - Load from Core Data
//    func loadPDFs() {
//        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
//        do {
//            let results = try context.fetch(request)
//            pdfDocuments = results.compactMap { entity in
//                guard let name = entity.name,
//                      let urlString = entity.url,
//                      let url = URL(string: urlString),
//                      let previewData = entity.preview,
//                      let date = entity.date
//                else { return nil }
//                let preview = UIImage(data: previewData) ?? UIImage()
//                return PDFDocumentItem(id: entity.id ?? UUID(), name: name, url: url, preview: preview, date: date)
//            }
//        } catch {
//            print("Failed to fetch PDFs: \(error)")
//        }
//    }
//
//    // MARK: - Save PDF to Core Data
//    private func savePDFToCoreData(_ pdf: PDFDocumentItem) {
//        let entity = PDFEntity(context: context)
//        entity.id = pdf.id
//        entity.name = pdf.name
//        entity.url = pdf.url.absoluteString
//        entity.date = pdf.date
//        entity.preview = pdf.preview.jpegData(compressionQuality: 0.8)
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed to save PDF: \(error)")
//        }
//    }
//
//    // MARK: - Add PDF
//    func addPDF(from images: [UIImage], name: String) {
//        if let url = PDFService.createPDF(from: images, name: name) {
//            let firstImage = images.first ?? UIImage()
//            let newDoc = PDFDocumentItem(name: name, url: url, preview: firstImage, date: Date())
//            pdfDocuments.append(newDoc)
//            savePDFToCoreData(newDoc)
//        }
//    }
//    
//    func addPDF(from files: [URL], name: String) {
//        if let url = PDFService.createPDFFromFiles(urls: files, name: name) {
//            let preview = PDFService.generatePreview(from: url, size: CGSize(width: 100, height: 100))
//            let newDoc = PDFDocumentItem(name: name, url: url, preview: preview, date: Date())
//            pdfDocuments.append(newDoc)
//            savePDFToCoreData(newDoc)
//        }
//    }
//
//    // MARK: - Delete PDF
//    func delete(_ doc: PDFDocumentItem) {
//        pdfDocuments.removeAll { $0.id == doc.id }
//        
//        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", doc.id as CVarArg)
//        
//        do {
//            let results = try context.fetch(request)
//            for entity in results {
//                context.delete(entity)
//            }
//            try context.save()
//        } catch {
//            print("Failed to delete PDF: \(error)")
//        }
//    }
//
//    // MARK: - Merge PDF
//    func selectPDFForMerge(_ doc: PDFDocumentItem) {
//        selectedPDFForMerge = doc
//        showMergeSelector = true
//    }
//
//    func mergePDFs(with target: PDFDocumentItem) {
//        guard let first = selectedPDFForMerge,
//              let mergedURL = PDFService.mergePDFs(first: first.url, second: target.url, outputName: "\(first.name) + \(target.name)")
//        else { return }
//
//        let preview = first.preview
//        let mergedDoc = PDFDocumentItem(name: "\(first.name) + \(target.name)", url: mergedURL, preview: preview, date: Date())
//        pdfDocuments.append(mergedDoc)
//        savePDFToCoreData(mergedDoc)
//        
//        showMergeSelector = false
//        selectedPDFForMerge = nil
//    }
//
//    // MARK: - Share PDF
//    func share(_ doc: PDFDocumentItem) {
//        guard let root = UIApplication.shared.windows.first?.rootViewController else { return }
//        let vc = UIActivityViewController(activityItems: [doc.url], applicationActivities: nil)
//        root.present(vc, animated: true)
//    }
//    
//    // MARK: - Migrate old tmp PDFs to Documents
//    func migrateOldPDFsIfNeeded() {
//        for (index, item) in pdfDocuments.enumerated() {
//            if item.url.path.contains("/tmp/") {
//                let newName = item.name.replacingOccurrences(of: "/", with: "-")
//                let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//                let newURL = docsURL.appendingPathComponent("\(newName).pdf")
//
//                do {
//                    if FileManager.default.fileExists(atPath: item.url.path) {
//                        try FileManager.default.copyItem(at: item.url, to: newURL)
//                        pdfDocuments[index].url = newURL
//
//                        // Обновляем Core Data
//                        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
//                        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
//                        if let entity = try context.fetch(request).first {
//                            entity.url = newURL.absoluteString
//                            try context.save()
//                        }
//                    }
//                } catch {
//                    print("Ошибка миграции PDF: \(error)")
//                }
//            }
//        }
//    }
//}

//@MainActor
//class FilesViewModel: ObservableObject {
//    @Published var pdfDocuments: [PDFDocumentItem] = []
//    @Published var showSheet: Bool = false
//    @Published var showMergeSelector: Bool = false
//    @Published var selectedPDFForMerge: PDFDocumentItem? = nil
//
//    // MARK: - PDF Creation
//    func addPDF(from images: [UIImage], name: String) {
//        if let url = PDFService.createPDF(from: images, name: name) {
//            let firstImage = images.first ?? UIImage()
//            let newDoc = PDFDocumentItem(name: name, url: url, preview: firstImage, date: Date())
//            pdfDocuments.append(newDoc)
//        }
//    }
//    
//    func addPDF(from files: [URL], name: String) {
//        if let url = PDFService.createPDFFromFiles(urls: files, name: name) {
//            let preview = PDFService.generatePreview(from: url, size: CGSize(width: 100, height: 100))
//            let newDoc = PDFDocumentItem(name: name, url: url, preview: preview, date: Date())
//            pdfDocuments.append(newDoc)
//        }
//    }
//    
//
//
//    // MARK: - Merge
//    func selectPDFForMerge(_ doc: PDFDocumentItem) {
//        selectedPDFForMerge = doc
//        showMergeSelector = true
//    }
//
//    func mergePDFs(with target: PDFDocumentItem) {
//        guard let first = selectedPDFForMerge,
//              let mergedURL = PDFService.mergePDFs(first: first.url, second: target.url, outputName: "\(first.name) + \(target.name)") else { return }
//
//        let preview = first.preview
//        let mergedDoc = PDFDocumentItem(name: "\(first.name) + \(target.name)", url: mergedURL, preview: preview, date: Date())
//        pdfDocuments.append(mergedDoc)
//        showMergeSelector = false
//        selectedPDFForMerge = nil
//    }
//
//    // MARK: - Actions
//    func delete(_ doc: PDFDocumentItem) {
//        pdfDocuments.removeAll { $0.id == doc.id }
//    }
//
//    func share(_ doc: PDFDocumentItem) {
//        guard let root = UIApplication.shared.windows.first?.rootViewController else { return }
//        let vc = UIActivityViewController(activityItems: [doc.url], applicationActivities: nil)
//        root.present(vc, animated: true)
//    }
//}
