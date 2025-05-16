//
//  DocumentRepository.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import Combine

protocol DocumentRepository {
    func fetchAll() -> AnyPublisher<[Document], Error>
    func save(_ document: Document) -> AnyPublisher<Void, Error>
    func delete(_ document: Document) -> AnyPublisher<Void, Error>
}
