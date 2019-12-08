import UIKit

let input = """
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN
"""

class Planet {
    let name: String
    var orbitedBy: [Planet] = []
    var depth = 0
    init(name: String, depth: Int = 0) {
        self.name = name
        self.depth = depth
    }
}

class LinkedPlanet {
    var head: Planet?
}

extension Planet: CustomStringConvertible {
    var description: String {
        return "\(self.name) \(orbitedBy) depth: \(depth)"
//        var planets = ""/
//        while orbitedBy != nil {
//            planets += orbitedBy!.name
//            orbitedBy = orbitedBy?.orbitedBy
//        }
        
//        return a + planets
    }
}

func findTotalNumberOfOrbits(for map: [String]) -> Int {
    var planet: Planet?
    
    var b: [String: String] = [:]
    
    for orbit in map {
        let planetOrbits = orbit.split(separator: ")").compactMap{ String($0) }
        let planet1 = planetOrbits[0]
        let planet2 = planetOrbits[1]
        
        b[planet2] = planet1
        // First Planet
//        if planet == nil {
//            let p1 = Planet(name: planet1)
//            p1.orbitedBy.append(Planet(name: planet2, depth: 1))
//            planet = p1
//            continue
//        }
        
        
//        // Find Planet
//        findPlanet(planet: &planet!, searchFor: planet1, planet2: planet2)
    }
    
    var sum = 0
    var secret = [String: Int]()
    var total = -1
    
    var start = "YOU"
    var start2 = "SAN"
    while true {
        print(start, start2)
        if let newStart = b[start] {
            secret[start] = total
            start = newStart
        }
        if let newStart2 = b[start2] {
            secret[start2] = total
            start2 = newStart2
        }
        
        if let value = secret[start2] {
            total += 1
            print(value + total)
            break
        }
        
        if let value = secret[start] {
            total += 1
            print(value + total)
            break
        }
        total += 1
    }
    
    
//    print(planet)
    
//    printPlanet(planet: planet!)
    
    return 0
}

func findDepth(dict: [String: String], for find: String) -> Int {
    var total = 1
    var value = dict[find]
    while value != "COM" {
        total += 1
        value = dict[value!]
    }
    
    print(value, total)
    return total
}

func findPlanet( planet: inout Planet, searchFor name: String, planet2: String) {
    print(planet.name, name, planet2)
    if planet.name == name {
        print(name)
        planet.orbitedBy.append(Planet(name: planet2, depth: planet.depth + 1))
        return
    }
    
    print(planet.orbitedBy)
    for planet in planet.orbitedBy {
        print(planet.name)
        var planet = planet
        findPlanet(planet: &planet, searchFor: name, planet2: planet2)
    }
}
var sum = 0

func printPlanet(planet: Planet) {
    for p in planet.orbitedBy {
        print(p.name, p.depth)
        sum += p.depth
        printPlanet(planet: p)
        if planet.orbitedBy.isEmpty {
            return
        }
    }
}
//
let inputFileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")!
let map = try String(contentsOf: inputFileURL).split { $0.isNewline }.compactMap { String($0) }

//let map = input.split{ $0.isNewline }.compactMap { String($0) }
findTotalNumberOfOrbits(for: map)

//print(sum)
