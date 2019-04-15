//
//  Future+Extension.swift
//  App
//
//  Created by Clément NONN on 09/03/2019.
//

import Async

extension Future {
    func `guard`(throwing error: Error, condition: @escaping (T) throws -> Bool) -> Future<T> {
        return self.map {
            guard try condition($0) else {
                throw error
            }
            return $0
        }
    }

    func with<U>(_ mapping: @escaping (T) throws -> U) -> Future<(T, U)> {
        return self.map { ($0, try mapping($0)) }
    }

    func with<U>(_ mapping: @escaping (T) throws -> Future<U>) -> Future<(T, U)> {
        return self.flatMap { first in try mapping(first).map { (first, $0) } }
    }

    func verifyMapping<U>(_ mapping: @escaping (T) -> U, throwing error: Error, condition: @escaping (U) -> Bool) -> Future<T> {
        let cond: (T, U) -> Bool = { condition($1) }
        return self.with(mapping).guard(throwing: error, condition: cond).map { $0.0 }
    }

    func verifyMapping<U>(_ mapping: @escaping (T) -> Future<U>, throwing error: Error, condition: @escaping (U) -> Bool) -> Future<T> {
        let cond: (T, U) -> Bool = { condition($1) }
        return self.with(mapping).guard(throwing: error, condition: cond).map { $0.0 }
    }
}

extension Future {
    func ifNotAlreadyExist<A>(container: Worker, createHandler: @escaping () -> Future<A>) -> Future<A> where T == Optional<A> {
        return self.flatMap(to: A.self) {
            if let res = $0 {
                return container.future(res)
            } else {
                return createHandler()
            }
        }
    }

    func ifNotAlreadyExist<A>(createHandler: @escaping () -> A) -> Future<A> where T == Optional<A> {
        return self.map(to: A.self) {
            if let res = $0 {
                return res
            } else {
                return createHandler()
            }
        }
    }
}
