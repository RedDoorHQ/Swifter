//
//  ArrayExtensions.swift
//
//  Created by Rok Gregorič
//  Copyright © 2018 Rok Gregorič. All rights reserved.
//

import Foundation

func rnd(_ max: Int? = nil) -> Int {
  if let max = max {
    return Int(arc4random_uniform(UInt32(max)))
  }
  return Int(arc4random())
}

extension Array {
  func object(at index: Int) -> Element? {
    if index >= 0 && index < self.count {
      return self[index] as Element
    }
    return nil
  }
  
  var randomIndex: Int {
    return rnd(count)
  }
  
  var random: Element? {
    return object(at: randomIndex)
  }
  
  mutating func removeRandom() -> Element? {
    if count == 0 { return nil }
    return remove(at: randomIndex)
  }
  
  mutating func insert(random object: Element) {
    let index = isEmpty ? 0 : rnd(count+1)
    insert(object, at: index)
  }
  
  mutating func insertAppend(_ element: Element, at index: Int) {
    if count > index {
      insert(element, at: index)
    } else {
      append(element)
    }
  }
  
  func limit(to limit: Int) -> [Element] {
    return Array(self[0..<Swift.min(count, limit)])
  }
  
  var indexed: [String: Element] {
    var result = [String: Element]()
    enumerated().forEach { result["\($0.0)"] = $0.1 }
    return result
  }
  
  func shuffled() -> [Element] {
    var result = [Element]()
    forEach { result.insert(random: $0) }
    return result
  }
}

extension Collection {
  var nilIfEmpty: Self? {
    return isEmpty ? nil : self
  }

  var hasOne: Bool {
    return count == 1
  }

  var firstIfAlone: Element? {
    return hasOne ? first : nil
  }

  var notEmpty: Bool {
    return !isEmpty
  }
}

extension Optional where Wrapped: Collection {
  var nilIfEmpty: Wrapped? {
    return self?.nilIfEmpty
  }
}

extension Array where Iterator.Element: Equatable {
  @discardableResult
  mutating func remove(_ element: Element) -> Int? {
    let idx = firstIndex(of: element)
    _ = idx.map { remove(at: $0 ) }
    return idx
  }

  func removing(_ element: Element) -> [Element] {
    var copy = self
    copy.remove(element)
    return copy
  }

  mutating func toggle(_ element: Element) {
    if self.contains(element) {
      remove(element)
    } else {
      append(element)
    }
  }
}

extension Sequence where Iterator.Element: Equatable {
  public func containsNil(_ element: Iterator.Element?) -> Bool {
    return element.map(contains) ?? false
  }

  public func excludes(_ element: Iterator.Element) -> Bool {
    return !contains(element)
  }

  public func excludesNil(_ element: Iterator.Element?) -> Bool {
    return element.map(excludes) ?? true
  }
}

extension Sequence where Iterator.Element: Hashable {
  func unique() -> [Iterator.Element] {
    return Array(Set<Iterator.Element>(self))
  }

  func uniqueOrdered() -> [Iterator.Element] {
    return reduce([Iterator.Element]()) { $0.contains($1) ? $0 : $0 + [$1] }
  }
}

protocol OptionalProtocol {
  associatedtype Wrapped
  var val: Wrapped? { get }
}

extension Optional: OptionalProtocol {
  public var val: Wrapped? { return self }
}

extension Sequence where Iterator.Element: OptionalProtocol {
  var flat: [Iterator.Element.Wrapped] {
    return compactMap {
      if let str = ($0.val as? String)?.nilIfEmpty {
        return str as? Iterator.Element.Wrapped
      }
      return $0.val
    }
  }
}

extension Sequence where Iterator.Element == Optional<String> {
  func flatJoined(_ separator: String) -> String {
    return flat.joined(separator: separator)
  }

  func nilFlatJoined(_ separator: String) -> String? {
    return map { $0?.nilIfEmpty }.nilIfEmpty?.flatJoined(separator)
  }
}
