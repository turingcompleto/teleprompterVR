//
//  CoreDataDocumentRepository.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import Foundation
import Combine
import CoreData

final class CoreDataDocumentRepository: DocumentRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() -> AnyPublisher<[Document], Error> {
        Future { promise in
            self.context.perform {
                let request: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
                do {
                    let entities = try self.context.fetch(request)
                    let docs = entities.map { $0.toDomain() }
                    promise(.success(docs))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func save(_ document: Document) -> AnyPublisher<Void, Error> {
        Future { promise in
            self.context.perform {
                let request: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
                do {
                    let results = try self.context.fetch(request)
                    let entity: DocumentEntity
                    if let existing = results.first {
                        entity = existing
                    } else {
                        entity = DocumentEntity(context: self.context)
                        entity.id = document.id
                        entity.createdAt = document.createdAt
                    }
                    entity.title     = document.title
                    entity.content   = document.content
                    entity.updatedAt = document.updatedAt

                    try self.context.save()
                    promise(.success(()))
                } catch {
                    self.context.rollback()
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(_ document: Document) -> AnyPublisher<Void, Error> {
        Future { promise in
            self.context.perform {
                let request: NSFetchRequest<DocumentEntity> = DocumentEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", document.id as CVarArg)
                do {
                    if let existing = try self.context.fetch(request).first {
                        self.context.delete(existing)
                        try self.context.save()
                    }
                    promise(.success(()))
                } catch {
                    self.context.rollback()
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: –– Helper para mapear la entidad a tu modelo de dominio

private extension DocumentEntity {
    func toDomain() -> Document {
        Document(
            id:          self.id!,
            title:       self.title ?? "",
            content:     self.content ?? "",
            createdAt:   self.createdAt ?? Date(),
            updatedAt:   self.updatedAt ?? Date()
        )
    }
}
