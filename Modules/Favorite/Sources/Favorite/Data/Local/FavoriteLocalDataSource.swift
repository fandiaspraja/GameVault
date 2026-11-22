//
//  FavoriteLocalDataSource.swift
//  Favorite
//

import Combine
import CoreData
import Foundation
import GameVaultCore

/// Entity Data Layer (struct biasa, aman dipakai lintas thread).
public struct FavoriteGameEntity: Equatable {
  public let id: Int
  public let name: String
  public let imageURL: String?
  public let rating: Double
  public let released: String?
  public let genre: String?
  public let addedAt: Date

}

/// Implementasi `LocalDataSource` (GameVaultCore) dengan Core Data + Combine.
public final class FavoriteLocalDataSource: LocalDataSource {
  public typealias Request = Void
  public typealias Response = FavoriteGameEntity

  private let store: FavoriteStore

  public init(store: FavoriteStore) {
    self.store = store
  }

  public func list(request: Void?) -> AnyPublisher<[FavoriteGameEntity], Error> {
    perform { context in
      let fetchRequest = NSFetchRequest<FavoriteGameObject>(entityName: FavoriteStore.entityName)
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
      return try context.fetch(fetchRequest).map(Self.toEntity)
    }
  }

  public func get(id: Int) -> AnyPublisher<FavoriteGameEntity?, Error> {
    perform { context in
      try context.fetch(Self.fetchRequest(id: id)).first.map(Self.toEntity)
    }
  }

  public func add(entity: FavoriteGameEntity) -> AnyPublisher<Bool, Error> {
    perform { [store] context in
      let object: FavoriteGameObject
      if let existing = try context.fetch(Self.fetchRequest(id: entity.id)).first {
        object = existing
      } else {
        guard let description = store.entityDescription(in: context) else {
          throw CoreError.database("Entity tidak ditemukan")
        }
        object = FavoriteGameObject(entity: description, insertInto: context)
      }
      object.id = Int64(entity.id)
      object.name = entity.name
      object.imageURL = entity.imageURL
      object.rating = entity.rating
      object.released = entity.released
      object.genre = entity.genre
      object.addedAt = entity.addedAt
      try context.save()
      return true
    }
  }

  public func delete(id: Int) -> AnyPublisher<Bool, Error> {
    perform { context in
      let objects = try context.fetch(Self.fetchRequest(id: id))
      objects.forEach { context.delete($0) }
      if context.hasChanges {
        try context.save()
      }
      return !objects.isEmpty
    }
  }

  // MARK: - Private

  /// Menjalankan operasi di background context lalu membungkusnya sebagai publisher.
  private func perform<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
    Deferred { [store] in
      Future<T, Error> { promise in
        let context = store.newBackgroundContext()
        context.perform {
          do {
            promise(.success(try block(context)))
          } catch let error as CoreError {
            promise(.failure(error))
          } catch {
            promise(.failure(CoreError.database(error.localizedDescription)))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }

  private static func fetchRequest(id: Int) -> NSFetchRequest<FavoriteGameObject> {
    let request = NSFetchRequest<FavoriteGameObject>(entityName: FavoriteStore.entityName)
    request.predicate = NSPredicate(format: "id == %lld", Int64(id))
    return request
  }

  private static func toEntity(_ object: FavoriteGameObject) -> FavoriteGameEntity {
    FavoriteGameEntity(
      id: Int(object.id),
      name: object.name ?? "",
      imageURL: object.imageURL,
      rating: object.rating,
      released: object.released,
      genre: object.genre,
      addedAt: object.addedAt ?? Date()
    )
  }
}
