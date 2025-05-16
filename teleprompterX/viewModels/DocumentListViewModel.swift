//
//  DocumentListViewModel.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//
import Combine
import Foundation

final class DocumentListViewModel: ObservableObject {
    @Published private(set) var documents: [Document] = []
    @Published var errorMessage: String?

    private let repository: DocumentRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: DocumentRepository) {
        self.repository = repository
        loadDocuments()
    }

    func loadDocuments() {
        repository.fetchAll()
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
                receiveValue: { docs in
                    // Ordenamos por fecha de creación
                    self.documents = docs.sorted { $0.createdAt < $1.createdAt }
                }
            )
            .store(in: &cancellables)
    }

    func delete(_ doc: Document) {
        repository.delete(doc)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        // Después de borrar, recargamos la lista
                        self.loadDocuments()
                    case .failure(let err):
                        self.errorMessage = err.localizedDescription
                    }
                },
                receiveValue: { /* No necesitamos el valor de salida aquí */ }
            )
            .store(in: &cancellables)
    }
}
