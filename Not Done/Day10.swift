#!/usr/bin/env xcrun swift

import Foundation

// MARK: Day 10: Monitoring Station - https://adventofcode.com/2019/day/10


//var mapOfAsteroids
// . - Empty
// # - Asteroid
// Asteroid can be (X, Y) (distance from top left corner (0,0)

// MARK: Best Location to detect most asteroids
//3,4
//0,1
//0,5

struct Asteroid: Hashable {
    var x = 0, y = 0
}

extension Asteroid: CustomStringConvertible {
    var description: String {
        return "\(x),\(y)"
    }
}

enum MapLegend: String {
    case asteroid = "#"
    case empty = "."
}

typealias Map = [[String]]

func convertInputToMap(for input: String) ->  Map {
    var map = Map()
    let rows = input.split { $0.isNewline }
    
    for row in rows {
        map.append(row.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } )
    }
    
    return map
}

func locateAsteroidPositions(for map: Map) -> Set<Asteroid> {
    var asteroids = Set<Asteroid>()
    
    for (y, row) in map.enumerated() {
        for (x, col) in row.enumerated() {
            if col == MapLegend.asteroid.rawValue {
                asteroids.insert(Asteroid(x: x, y: y))
            }
        }
    }
    
    return asteroids
}

//func findBestLocation(on map: Map, for asteroids: Set<Asteroid>) -> (Set<Asteroid>, Map) {
//    var markedMap = map
//    var countedAsteroids = Set<Asteroid>()
//
//    for asteroid in asteroids {
//        let (asteroidCounted, map) = determineLineOfSight(for: asteroid, on: markedMap)
//
//        countedAsteroids.insert(asteroidCounted)
//        markedMap = map
//    }
//
//
//    return (asteroids, markedMap)
//}

func doIntersect(a: Asteroid, b:Asteroid, c: Asteroid) -> Bool {
    let deltaX1 = c.x-a.x
    let deltaX2 = b.x-a.x
    if deltaX1 == 0 || deltaX2 == 0 { return true }
    
    let slope1 = (c.y-a.y)/deltaX1
    let slope2 = (b.y-a.y)/deltaX2
    
    return slope1 == slope2
}


func determineLineOfSight(for asteroid: Asteroid, on map: Map, asteroids: Set<Asteroid> ) -> (Int, Map) {
    var markedMap = map
    
    var count = 0
    
    print(asteroid)
    // MARK: West
    for i in stride(from: asteroid.x, through: 0, by: -1) {
        print("Left", i)
        print(map[asteroid.y][i])
        if asteroid.x == i { continue }
        
        
        if map[asteroid.y][i] == MapLegend.asteroid.rawValue {
            count += 1
            break
        }
        markedMap[asteroid.y][i] = "@"
        
    }
    
    // MARK: East
    for i in stride(from: asteroid.x, through: map[0].count-1, by: 1) {
        print("Right", i)
        print(map[asteroid.y][i])
        if asteroid.x == i { continue }
        
        if map[asteroid.y][i] == MapLegend.asteroid.rawValue {
            count += 1
            break
        }
        
        markedMap[asteroid.y][i] = "@"
    }
    
    // MARK: North
    for i in stride(from: asteroid.y, through: 0, by: -1) {
        print("North", i)
        print(map[i][asteroid.x])
        if asteroid.y == i { continue }
        if map[i][asteroid.x] == MapLegend.asteroid.rawValue {
            count += 1
            break
        }
        markedMap[i][asteroid.x] = "@"
    }
    
    // MARK: South
    for i in stride(from: asteroid.y, through: map.count-1, by: 1) {
        if asteroid.y == i { continue }
        if map[i][asteroid.x] == MapLegend.asteroid.rawValue {
            count += 1
            break
        }
        markedMap[i][asteroid.x] = "@"
    }
    
    print(count)
    var k = asteroids
    print(asteroids)
    k.remove(asteroid)
    print("K", k, asteroid)
    for a in k {
        var b = k
        b.remove(a)
        var flag = true
        print("Comparing", a)
        let adfa = asteroid.y - a.y
        let p = asteroid.x - a.x
        if p == 0 { continue }
        if a == Asteroid(x: 4, y: 2) {
            print("------------------",Double(adfa)/Double(p))
        }
        for z in b {
            //            if z == Asteroid(x: 4, y: 3) {
            //                print(asteroid, a, z)
            //            }
            //            flag = doIntersect(a: asteroid, b: z, c: a)
            //            if !flag {
            //                break
            //            }
            
            // 4 - 2 = 2 2/2, 4/4
            // 4
            // 2
            var deltay = (asteroid.y - z.y)
            var deltaz = (asteroid.x - z.x)
            if deltaz == 0 { continue }
            
            let dafadfa = Double(deltay)/Double(deltaz) == Double(adfa)/Double(p)
            if dafadfa {
                print("------------------",deltay/deltaz)
                
                print("------------------",Double(deltay)/Double(deltaz))
                if asteroid.y == z.y { continue}
                print(Double(deltay)/Double(deltaz), "   ",Double(adfa)/Double(p))
                print("ERHER", asteroid, z ,a)
                flag = false
            }
            
            print(adfa, p)
        }
        if flag {
            count += 1
        }
    }
    
    print(count)
    
    
    return (count, markedMap)
}

func prettyPrint(map: Map) {
    for row in map {
        print(row.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.joined())
    }
}



var test1 = """
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
"""

let map = convertInputToMap(for: test1)

let asteroidLocations = locateAsteroidPositions(for: map)

//let (asteroids, mm) = findBestLocation(on: map, for: asteroidLocations)
//
////print(asteroids)
//prettyPrint(map: mm)

//let (asteroid, markedMap) = determineLineOfSight(for: Asteroid(x: 3, y: 4, lineOfSight: 0), on: map)


print(asteroidLocations.count)
var asteroid1 = Asteroid(x: 3, y: 4)
var asteroid2 = Asteroid(x: 2, y: 2)
var asteroid3 = Asteroid(x: 1, y: 0)
var asteroid4 = Asteroid(x: 2, y: 3)

//let slope = (asteroid3.y-asteroid1.y)/(asteroid3.x-asteroid1.x)
//let slope2 = (asteroid2.y-asteroid1.y)/(asteroid2.x-asteroid1.x)
//
//doIntersect(a: asteroid1, b: asteroid2, c: asteroid3)
//doIntersect(a: asteroid1, b: asteroid2, c: asteroid4)

let c = determineLineOfSight(for: Asteroid(x: 5, y: 8), on: map, asteroids: asteroidLocations)
print(c)

print()
print()
print()
print()


