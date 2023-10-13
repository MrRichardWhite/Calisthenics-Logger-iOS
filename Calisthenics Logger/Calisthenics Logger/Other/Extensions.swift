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
    func sum() -> Double {
        var s = 0.0
        for x in self { s += x }
        return s
    }
    
    func mean() -> Double {
        if self.count == 0 {
            return 0.0
        } else {
            return self.sum() / Double(self.count)
        }
    }
    
    func variance() -> Double {
        if self.count <= 1 {
            return 0.0
        } else {
            return self.map { x in pow(x - self.mean(), 2) } .sum() / Double(self.count - 1)
        }
    }
    
    func std() -> Double { return sqrt(self.variance()) }
}
