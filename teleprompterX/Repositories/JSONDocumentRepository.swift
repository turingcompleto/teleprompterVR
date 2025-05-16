//
//  JSONDocumentRepository.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import Foundation
import Combine

final class JSONDocumentRepository: DocumentRepository {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "repo.queue")

    init(filename: String = "documents.json") {
        let docs = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent(filename)
    }

    func fetchAll() -> AnyPublisher<[Document], Error> {
        Future { promise in
            self.queue.async {
                do {
                    let data = try Data(contentsOf: self.fileURL)
                    let docs = try JSONDecoder().decode([Document].self, from: data)
                    promise(.success(docs))
                } catch {
                    promise(.success([])) // si no existe, devolvemos vacío
                }
            }
        }.eraseToAnyPublisher()
    }

    func save(_ document: Document) -> AnyPublisher<Void, Error> {
        fetchAll()
            .map { docs in
                var list = docs.filter { $0.id != document.id }
                list.append(document)
                return list
            }
            .flatMap { list in
                Future { promise in
                    self.queue.async {
                        do {
                            let data = try JSONEncoder().encode(list)
                            try data.write(to: self.fileURL)
                            promise(.success(()))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func delete(_ document: Document) -> AnyPublisher<Void, Error> {
        fetchAll()
            .map { docs in docs.filter { $0.id != document.id } }
            .flatMap { list in
                Future { promise in
                    self.queue.async {
                        do {
                            let data = try JSONEncoder().encode(list)
                            try data.write(to: self.fileURL)
                            promise(.success(()))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}
