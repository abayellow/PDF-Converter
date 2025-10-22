//
//  PDFRepository.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 23.10.2025.
//

import Foundation
import CoreData
import UIKit

@MainActor
class PDFStorageManager {
    
    static let shared = PDFStorageManager()
    private let context = PersistenceController.shared.context
    
    private init() {}
    
    // MARK: - Load PDFs
    func loadPDFs() -> [PDFDocumentItem] {
        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            var loaded: [PDFDocumentItem] = []
            
            for entity in results {
                guard let id = entity.id,
                      let name = entity.name,
                      let urlString = entity.url else {
                    context.delete(entity)
                    continue
                }
                
                var url = URL(string: urlString)
                var fileExists = false
                if let u = url {
                    fileExists = FileManager.default.fileExists(atPath: u.path)
                }
                
                if !fileExists {
                    let last = URL(string: urlString)?.lastPathComponent ?? "\(name).pdf"
                    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let candidate = docs.appendingPathComponent(last)
                    if FileManager.default.fileExists(atPath: candidate.path) {
                        entity.url = candidate.absoluteString
                        url = candidate
                        try? context.save()
                        fileExists = true
                    }
                }
                
                if !fileExists {
                    context.delete(entity)
                    continue
                }
                
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
            
            if context.hasChanges {
                try? context.save()
            }
            
            return loaded.sorted { $0.date > $1.date }
            
        } catch {
            print("Failed to fetch PDFs: \(error)")
            return []
        }
    }
    
    // MARK: - Save PDF
    func savePDF(_ pdf: PDFDocumentItem) {
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
    
    // MARK: - Delete PDF
    func deletePDF(_ pdf: PDFDocumentItem) {
        let request: NSFetchRequest<PDFEntity> = PDFEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", pdf.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            for entity in results {
                if let urlString = entity.url, let u = URL(string: urlString), FileManager.default.fileExists(atPath: u.path) {
                    try? FileManager.default.removeItem(at: u)
                }
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Failed to delete PDF: \(error)")
        }
    }
}
