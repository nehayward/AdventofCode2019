import Foundation
import UIKit
import XCPlayground

// MARK: Space Police - Day 11

enum Color: Int {
    case black = 0
    case white = 1
}

extension Color: CustomStringConvertible {
    var description: String {
        return "\(self == .white ? "White" : "Black")"
    }
}

enum Position: Int {
    case up = 0
    case right = 1
    case down = 2
    case left = 3
}


enum Rotate: Int {
    case left90 = 0
    case right90 = 1
}


struct Coordinate: Hashable {
    var x = 0, y = 0
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
}

extension Coordinate: Equatable {}

extension Coordinate: Comparable {
    static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        lhs.y < rhs.y
    }
}


struct Panel {
    var color: Color = .black
    var coordinate: Coordinate = Coordinate()
}

extension Panel: CustomStringConvertible {
    var description: String {
        return "\(coordinate) is \(color == .white ? "White" : "Black")"
    }
}

typealias Panels = [Coordinate: Color]

func rotate(by rotation: Rotate, from position: Position) -> Position {
    var rotateBy = rotation == .left90 ? -1 : 1
    rotateBy = rotateBy + position.rawValue
    
    switch rotateBy {
    case 0...3:
        return Position(rawValue: rotateBy)!
    case -1:
        return Position.left
    case 4:
        return Position.up
    default:
        return Position.up
    }
}

func move(from current: Coordinate, in direction: Position) -> Coordinate {
    var newCoordinate = current
    switch direction {
    case .up:
        newCoordinate.y += 1
    case .down:
        newCoordinate.y -= 1
    case .right:
        newCoordinate.x += 1
    case .left:
        newCoordinate.x -= 1
    }
    
    return newCoordinate
}

// MARK: Test Rotate
//rotate(by: .right90, from: .up)
//rotate(by: .right90, from: .right)
//rotate(by: .right90, from: .down)
//rotate(by: .right90, from: .left)
//
//rotate(by: .left90, from: .up)
//rotate(by: .left90, from: .right)
//rotate(by: .left90, from: .down)
//rotate(by: .left90, from: .left)

// MARK: Test Move
//var current = Coordinate()
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .up)
//current = move(from: current, in: .left)
//current = move(from: current, in: .left)
//current = move(from: current, in: .left)

//
var panels = Panels()

panels[Coordinate()] = .black
print(panels.count)
print(panels)


panels[Coordinate()] = .white
print(panels.count)
print(panels)


@discardableResult func Intcode(getInput: () -> (Int) = {return 0}, output: (Int, Bool) -> () = { _,_ in }) -> (Int, Int) {
    
    print(getInput())
    return (9,9)
}

var current = Coordinate()
var position = Position.up

Intcode(getInput: {
    let color = panels[current]
    return color?.rawValue ?? 0
}, output: { outputted, shouldColor in
    if shouldColor {
        panels[current] = Color(rawValue: outputted)
    } else {
        let rotation = Rotate(rawValue: outputted)!
        position = rotate(by: rotation, from: .up)
        move(from: current, in: position)
    }
})


var points = [CGPoint]()
for panel in panels {
    let point = CGPoint(x: panel.key.x, y: panel.key.y)
    points.append(point)
}

print(points)

let p = Array(panels.keys).sorted(by: >)
p.filter { panels[$0]! == .white }


let graphView = UIView(frame: CGRect(x: 0, y: 0, width: 800, height: 800))


var array = [CGRect(x: 51, y: 45, width: 2, height: 2), CGRect(x: 89, y: 45, width: 2, height: 2), CGRect(x: 69, y: 45, width: 2, height: 2), CGRect(x: 73, y: 45, width: 2, height: 2), CGRect(x: 66, y: 45, width: 2, height: 2), CGRect(x: 64, y: 45, width: 2, height: 2), CGRect(x: 63, y: 45, width: 2, height: 2), CGRect(x: 58, y: 45, width: 2, height: 2), CGRect(x: 82, y: 45, width: 2, height: 2), CGRect(x: 83, y: 45, width: 2, height: 2), CGRect(x: 54, y: 45, width: 2, height: 2), CGRect(x: 57, y: 45, width: 2, height: 2), CGRect(x: 79, y: 45, width: 2, height: 2), CGRect(x: 72, y: 45, width: 2, height: 2), CGRect(x: 86, y: 45, width: 2, height: 2), CGRect(x: 88, y: 45, width: 2, height: 2), CGRect(x: 76, y: 45, width: 2, height: 2), CGRect(x: 59, y: 45, width: 2, height: 2), CGRect(x: 62, y: 45, width: 2, height: 2), CGRect(x: 87, y: 45, width: 2, height: 2), CGRect(x: 61, y: 45, width: 2, height: 2), CGRect(x: 51, y: 46, width: 2, height: 2), CGRect(x: 86, y: 46, width: 2, height: 2), CGRect(x: 81, y: 46, width: 2, height: 2), CGRect(x: 84, y: 46, width: 2, height: 2), CGRect(x: 59, y: 46, width: 2, height: 2), CGRect(x: 74, y: 46, width: 2, height: 2), CGRect(x: 76, y: 46, width: 2, height: 2), CGRect(x: 66, y: 46, width: 2, height: 2), CGRect(x: 56, y: 46, width: 2, height: 2), CGRect(x: 54, y: 46, width: 2, height: 2), CGRect(x: 69, y: 46, width: 2, height: 2), CGRect(x: 79, y: 46, width: 2, height: 2), CGRect(x: 61, y: 46, width: 2, height: 2), CGRect(x: 71, y: 46, width: 2, height: 2), CGRect(x: 76, y: 47, width: 2, height: 2), CGRect(x: 61, y: 47, width: 2, height: 2), CGRect(x: 54, y: 47, width: 2, height: 2), CGRect(x: 81, y: 47, width: 2, height: 2), CGRect(x: 79, y: 47, width: 2, height: 2), CGRect(x: 84, y: 47, width: 2, height: 2), CGRect(x: 51, y: 47, width: 2, height: 2), CGRect(x: 56, y: 47, width: 2, height: 2), CGRect(x: 58, y: 47, width: 2, height: 2), CGRect(x: 69, y: 47, width: 2, height: 2), CGRect(x: 87, y: 47, width: 2, height: 2), CGRect(x: 74, y: 47, width: 2, height: 2), CGRect(x: 66, y: 47, width: 2, height: 2), CGRect(x: 59, y: 47, width: 2, height: 2), CGRect(x: 66, y: 48, width: 2, height: 2), CGRect(x: 51, y: 48, width: 2, height: 2), CGRect(x: 54, y: 48, width: 2, height: 2), CGRect(x: 52, y: 48, width: 2, height: 2), CGRect(x: 62, y: 48, width: 2, height: 2), CGRect(x: 78, y: 48, width: 2, height: 2), CGRect(x: 76, y: 48, width: 2, height: 2), CGRect(x: 69, y: 48, width: 2, height: 2), CGRect(x: 79, y: 48, width: 2, height: 2), CGRect(x: 56, y: 48, width: 2, height: 2), CGRect(x: 53, y: 48, width: 2, height: 2), CGRect(x: 77, y: 48, width: 2, height: 2), CGRect(x: 84, y: 48, width: 2, height: 2), CGRect(x: 81, y: 48, width: 2, height: 2), CGRect(x: 67, y: 48, width: 2, height: 2), CGRect(x: 61, y: 48, width: 2, height: 2), CGRect(x: 74, y: 48, width: 2, height: 2), CGRect(x: 88, y: 48, width: 2, height: 2), CGRect(x: 68, y: 48, width: 2, height: 2), CGRect(x: 63, y: 48, width: 2, height: 2), CGRect(x: 81, y: 49, width: 2, height: 2), CGRect(x: 69, y: 49, width: 2, height: 2), CGRect(x: 51, y: 49, width: 2, height: 2), CGRect(x: 74, y: 49, width: 2, height: 2), CGRect(x: 54, y: 49, width: 2, height: 2), CGRect(x: 84, y: 49, width: 2, height: 2), CGRect(x: 56, y: 49, width: 2, height: 2), CGRect(x: 89, y: 49, width: 2, height: 2), CGRect(x: 76, y: 49, width: 2, height: 2), CGRect(x: 61, y: 49, width: 2, height: 2), CGRect(x: 79, y: 49, width: 2, height: 2), CGRect(x: 59, y: 49, width: 2, height: 2), CGRect(x: 66, y: 49, width: 2, height: 2), CGRect(x: 69, y: 50, width: 2, height: 2), CGRect(x: 81, y: 50, width: 2, height: 2), CGRect(x: 62, y: 50, width: 2, height: 2), CGRect(x: 73, y: 50, width: 2, height: 2), CGRect(x: 84, y: 50, width: 2, height: 2), CGRect(x: 74, y: 50, width: 2, height: 2), CGRect(x: 54, y: 50, width: 2, height: 2), CGRect(x: 66, y: 50, width: 2, height: 2), CGRect(x: 57, y: 50, width: 2, height: 2), CGRect(x: 89, y: 50, width: 2, height: 2), CGRect(x: 79, y: 50, width: 2, height: 2), CGRect(x: 76, y: 50, width: 2, height: 2), CGRect(x: 51, y: 50, width: 2, height: 2), CGRect(x: 64, y: 50, width: 2, height: 2), CGRect(x: 63, y: 50, width: 2, height: 2), CGRect(x: 88, y: 50, width: 2, height: 2), CGRect(x: 61, y: 50, width: 2, height: 2), CGRect(x: 86, y: 50, width: 2, height: 2), CGRect(x: 58, y: 50, width: 2, height: 2), CGRect(x: 87, y: 50, width: 2, height: 2)]


class DrawTrace: UIView
{
    var points = [CGPoint]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        UIColor.white.set()
        for point in array {
            let dot = UIBezierPath(ovalIn: point)
            // this just draws the circle by filling it.
            // Update any properties of the path as needed.
            // Use dot.stroke() if you need an outline around the circle.
            dot.fill()
        }
    }
}

let trace = DrawTrace(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
trace.backgroundColor = .black

XCPlaygroundPage.currentPage.liveView = trace
