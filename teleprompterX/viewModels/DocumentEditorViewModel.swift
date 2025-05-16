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
    
    init(repository: DocumentRepository) {
        self.repository = repository
    }
    
    /// Valida y guarda un nuevo documento
    func saveDocument() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Título y contenido no pueden estar vacíos."
            return
        }
        
        let now = Date()
        let doc = Document(
            id: UUID(),
            title: title,
            content: content,
            createdAt: now,
            updatedAt: now
        )
        
        repository.save(doc)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: {
                self.didSave = true
            }
            .store(in: &cancellables)
    }
}

