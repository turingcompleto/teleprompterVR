//
//  DocumentEditorViewModel.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import Combine
import Foundation

final class DocumentEditorViewModel: ObservableObject {
    // MARK: - Inputs del usuario
    @Published var title: String = ""
    @Published var content: String = ""
    
    // MARK: - Salidas
    @Published var errorMessage: String?
    @Published var didSave: Bool = false
    
    private let repository: DocumentRepository
    private var cancellables = Set<AnyCancellable>()
    
    // Esta propiedad guarda el documento original si venimos a editar
     let originalDocument: Document?
    
    init(repository: DocumentRepository, document: Document? = nil) {
        self.repository = repository
        self.originalDocument = document
        
        // Si nos pasaron un document, precargamos campos
        if let doc = document {
            self.title = doc.title
            self.content = doc.content
        }
    }
    
    /// Valida y guarda (o actualiza) un documento
    func saveDocument() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
            errorMessage = "Título y contenido no pueden estar vacíos."
            return
        }
        
        let now = Date()
        // Si originalDocument existe, mantenemos su id y createdAt; solo actualizamos contenido y updatedAt
        let docToSave: Document
        if var editing = originalDocument {
            editing.title = trimmedTitle
            editing.content = trimmedContent
            editing.updatedAt = now
            docToSave = editing
        } else {
            // Nuevo documento
            docToSave = Document(
                id: UUID(),
                title: trimmedTitle,
                content: trimmedContent,
                createdAt: now,
                updatedAt: now
            )
        }
        
        repository.save(docToSave)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let err):
                        self.errorMessage = err.localizedDescription
                    }
                },
                receiveValue: {
                    // Avisamos que ya guardamos para que la vista se cierre
                    self.didSave = true
                }
            )
            .store(in: &cancellables)
    }
}

