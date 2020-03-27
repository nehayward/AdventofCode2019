import Foundation

// MARK: Day 12 - The N-Body Problem


struct Position: Hashable {
    var x = 0, y = 0, z = 0
}

extension Position: Equatable {
    
}

extension Position: CustomStringConvertible {
    var description: String {
        return "<x= \(x), y= \(y), z= \(z)>"
    }
}

typealias Velocity = Position


struct Moon: Hashable {
    var name: String
    var position = Position()
    var velocity = Velocity()
}

extension Moon: CustomStringConvertible {
    var description: String {
        return "pos=\(position),\t vel=\(velocity) \t \(name)"
    }
}

func updatePosition(for moon: Moon, by moons: [Moon]) -> Moon {
    var newMoon = moon
    var moons = moons
    
    if let index = moons.firstIndex(where: { moon.position == $0.position }) {
        moons.remove(at: index)
    }
    
    var vx = newMoon.velocity.x, vy = newMoon.velocity.y, vz = newMoon.velocity.z
    for otherMoon in moons {
        if moon.position.x == otherMoon.position.x {
            
        }
        else if moon.position.x < otherMoon.position.x {
            vx += 1
        } else {
            vx -= 1
        }
        
        if moon.position.y == otherMoon.position.y {
            
        }
        else if moon.position.y < otherMoon.position.y {
            vy += 1
        } else {
            vy -= 1
        }
        
        if moon.position.z == otherMoon.position.z {
            
        }
        else if moon.position.z < otherMoon.position.z {
            vz += 1
        } else {
            vz -= 1
        }
    }
    
    newMoon.velocity.x = vx
    newMoon.velocity.y = vy
    newMoon.velocity.z = vz

    newMoon.position.x += vx
    newMoon.position.y += vy
    newMoon.position.z += vz
    
    return newMoon
}

func energy(for moon: Moon) -> Int {
    let potentialEnergy = abs(moon.position.x) + abs(moon.position.y) + abs(moon.position.z)
    let kineticEnergy = abs(moon.velocity.x) + abs(moon.velocity.y) + abs(moon.velocity.z)

    return potentialEnergy * kineticEnergy
}



//var moons = [Moon(name: "Io", position: Position(x: -1, y: 0, z: 2)),
//             Moon(name: "Europa", position: Position(x: 2, y: -10, z: -7)),
//             Moon(name: "Ganymede", position: Position(x: 4, y: -8, z: 8)),
//             Moon(name: "Callisto", position: Position(x: 3, y: 5, z: -1))]

//var moons = [Moon(name: "Io", position: Position(x: -8, y: -10, z: 0)),
//             Moon(name: "Europa", position: Position(x: 5, y: 5, z: 10)),
//             Moon(name: "Ganymede", position: Position(x: 2, y: -7, z: 3)),
//             Moon(name: "Callisto", position: Position(x: 9, y: -8, z: -3))]

let input = """
<x=17, y=-7, z=-11>
<x=1, y=4, z=-1>
<x=6, y=-2, z=-6>
<x=19, y=11, z=9>
"""

var moons = [Moon(name: "Io", position: Position(x: 17, y: -7, z: -11)),
             Moon(name: "Europa", position: Position(x: 1, y: 4, z: -1)),
             Moon(name: "Ganymede", position: Position(x: 6, y: -2, z: -6)),
             Moon(name: "Callisto", position: Position(x: 19, y: 11, z: 9))]

for m in moons {
    print(m)
}


var states = [[Moon]:Bool]()

for i in 1...10 {
    var newMoons = [Moon]()
    for moon in moons {
        let newMoon = updatePosition(for: moon, by: moons)
        newMoons.append(newMoon)
    }
    print("After \(i) steps:")
    for m in newMoons {
        print(m)
    }
    
    moons = newMoons
    if let message = states[moons] {
        print("Steps", i)
    } else {
        states[moons] = true
    }
}

for m in moons {
    print(energy(for: m))
}

var total = moons.reduce(0, { $0 + energy(for: $1) })
print("Total: ", total)
