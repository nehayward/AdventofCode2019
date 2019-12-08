import Foundation

let file = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try! String(contentsOf: file!, encoding: .utf8)
let pixels = input.compactMap{ Int(String($0)) }

func decodeLayers(from input: [Int], with width: Int, and height: Int) -> [[Int]] {
    let sizeOfLayer = width * height
    var layers = [[Int]]()
    
    for pixel in stride(from: 0, to: input.count, by: sizeOfLayer) {
        var layer = [Int]()
        for i in 0..<sizeOfLayer {
            print(input[pixel + i])
            layer.append(input[pixel + i])
        }
        layers.append(layer)
    }
    
    return layers
}


//The image you received is 25 pixels wide and 6 pixels tall.
//
//To make sure the image wasn't corrupted during transmission, the Elves would like you to find the layer that contains the fewest 0 digits. On that layer, what is the number of 1 digits multiplied by the number of 2 digits?

let testLayers = decodeLayers(from: [1,2,3,4,5,6,7,8,9,0,1,2], with: 3, and: 2)

print(testLayers)

func findLayer(withFewest digits: Int, from layers: [[Int]]) -> [Int] {
    var fewest = Int.max
    var index = -1
    
    for (i, layer) in layers.enumerated() {
        let zeroCount = layer.filter { $0 == digits}.count
        if zeroCount == 0 {
            continue
        }
        if zeroCount < fewest {
            index = i
            fewest = zeroCount
        }
    }
 
    return layers[index]
}

let layerWithFewest0 = findLayer(withFewest: 0, from: testLayers)

func countFor(digit1: Int, digit2: Int, for layer: [Int]) -> (Int, Int) {
    
    let count1 = layer.filter { $0 == digit1 }.count
    let count2 = layer.filter { $0 == digit2 }.count
    
    print(count1 * count2)
    return (count1, count2)
}

countFor(digit1: 1, digit2: 2, for: layerWithFewest0)

// Number of 1 digits * number of 2 digits


let layer = decodeLayers(from: pixels, with: 25, and: 6)
let layerWithFewest = findLayer(withFewest: 0, from: layer)
countFor(digit1: 1, digit2: 2, for: layerWithFewest)

