//
//  Extensions.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import Foundation

extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}

extension String {
    func withoutEmoji() -> String {
        filter { $0.isASCII }
    }
}

extension [Double] {
    func sum() -> Double? {
        if self.count > 0 {
            var s = 0.0
            for x in self { s += x }
            return s
        } else {
            return nil
        }
    }
    
    func mean() -> Double? {
        if let sum = self.sum() {
            return sum / Double(self.count)
        } else {
            return nil
        }
    }
    
    func variance() -> Double? {
        if self.count > 0 {
            if self.count == 1 {
                return 0.0
            } else {
                if let mean = self.mean() {
                    if let sum = self.map({ x in pow(x - mean, 2) }).sum() {
                        return sum / Double(self.count - 1)
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }
    
    func std() -> Double? {
        if let variance = self.variance() {
            return sqrt(variance)
        } else {
            return nil
        }
    }
}

extension Array {
    var last: Element? {
        if self.count > 0 {
            return self[self.endIndex - 1]
        } else {
            return nil
        }
    }
}
