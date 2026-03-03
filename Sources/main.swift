import Foundation

enum Faction: String, CaseIterable {
    case british = "British"
    case german = "German"

    var dot: String {
        switch self {
        case .british: return "🔵"
        case .german: return "🔴"
        }
    }

    var enemy: Faction {
        switch self {
        case .british: return .german
        case .german: return .british
        }
    }
}

enum MapTheme: String, CaseIterable {
    case green = "Green"
    case snow = "Snow"
    case rainy = "Rainy"

    var baseTile: Character {
        switch self {
        case .green: return "."
        case .snow: return "*"
        case .rainy: return ","
        }
    }
}

struct Enemy {
    var x: Int
    var y: Int
    var isAlive: Bool = true
}

struct ArtillerySetup {
    var aimX: Int
    var spread: Int
    var salvoSize: Int
}

struct Game {
    let width = 40
    let height = 18
    let trenchY = 2
    let playerLineY = 16
    let breachY = 14

    let faction: Faction
    let map: MapTheme

    var rng = SystemRandomNumberGenerator()

    mutating func run() {
        print("\nQuantum Entertainment - WW1 Artillery Demo")
        print("You are commanding the \(faction.rawValue) artillery line (\(faction.dot)) on a \(map.rawValue.lowercased()) map.")
        print("Color key: British=🔵, German=🔴")
        print("Stop enemy units crossing deep into No Man's Land.\n")

        var totalScore = 0
        var totalBreaches = 0

        for wave in 1...5 {
            let enemiesThisWave = wave * 5
            print("\n=== Wave \(wave) / 5 ===")
            print("Enemy strength: \(enemiesThisWave)")

            let setup = configureArtillery(forWave: wave)
            _ = prompt("Type READY and press Enter to begin Wave \(wave): ").uppercased()

            let result = simulateWave(wave: wave, enemyCount: enemiesThisWave, setup: setup)
            totalScore += result.kills
            totalBreaches += result.breaches

            print("Wave \(wave) complete. Kills: \(result.kills), Breaches: \(result.breaches)")

            if result.breaches >= 8 {
                print("Your line has been overwhelmed. Demo ended early.")
                break
            }
        }

        print("\n=== Final Report ===")
        print("Total enemy units destroyed: \(totalScore)")
        print("Total enemy breaches: \(totalBreaches)")
        if totalBreaches <= 8 {
            print("Result: Tactical success for Quantum Entertainment demo build.")
        } else {
            print("Result: Needs balancing - enemy pressure is too high.")
        }
    }

    mutating func configureArtillery(forWave wave: Int) -> ArtillerySetup {
        print("\nObserve and prepare your guns:")
        let aim = promptInt("Aim X coordinate (0-\(width - 1)): ", min: 0, max: width - 1)
        let spread = promptInt("Gun spread (0-5, lower is accurate): ", min: 0, max: 5)
        let salvo = promptInt("Shells per tick (1-5): ", min: 1, max: 5)

        print("Guns prepared for wave \(wave): aim=\(aim), spread=\(spread), salvo=\(salvo)")
        return ArtillerySetup(aimX: aim, spread: spread, salvoSize: salvo)
    }

    mutating func simulateWave(wave: Int, enemyCount: Int, setup: ArtillerySetup) -> (kills: Int, breaches: Int) {
        var enemies: [Enemy] = []
        var spawned = 0
        var tick = 0
        var kills = 0
        var breaches = 0

        while kills + breaches < enemyCount {
            tick += 1

            if spawned < enemyCount && tick % 2 == 0 {
                let x = Int.random(in: 1..<(width - 1), using: &rng)
                enemies.append(Enemy(x: x, y: trenchY + 1))
                spawned += 1
            }

            for i in enemies.indices where enemies[i].isAlive {
                enemies[i].y += 1
                if enemies[i].y >= breachY {
                    enemies[i].isAlive = false
                    breaches += 1
                }
            }

            for _ in 0..<setup.salvoSize {
                let shellX = max(0, min(width - 1, setup.aimX + Int.random(in: -setup.spread...setup.spread, using: &rng)))
                if let targetIndex = enemies.indices.first(where: { idx in
                    enemies[idx].isAlive && abs(enemies[idx].x - shellX) <= 1
                }) {
                    enemies[targetIndex].isAlive = false
                    kills += 1
                }
            }

            renderFrame(tick: tick, wave: wave, enemies: enemies, kills: kills, breaches: breaches)
            usleep(130_000)
        }

        return (kills, breaches)
    }

    mutating func renderFrame(tick: Int, wave: Int, enemies: [Enemy], kills: Int, breaches: Int) {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
        print("Quantum Entertainment :: Wave \(wave)  Tick \(tick)  Kills \(kills)  Breaches \(breaches)")

        var grid = Array(repeating: Array(repeating: map.baseTile, count: width), count: height)

        for x in 0..<width {
            grid[trenchY][x] = "="
            grid[playerLineY][x] = "_"
        }

        if map == .rainy {
            for _ in 0..<(width / 2) {
                let rx = Int.random(in: 0..<width, using: &rng)
                let ry = Int.random(in: 0..<height, using: &rng)
                grid[ry][rx] = "|"
            }
        }

        grid[playerLineY - 1][width / 2] = "A"

        for enemy in enemies where enemy.isAlive {
            if enemy.y >= 0 && enemy.y < height && enemy.x >= 0 && enemy.x < width {
                grid[enemy.y][enemy.x] = "•"
            }
        }

        for row in 0..<height {
            var line = ""
            for col in 0..<width {
                if grid[row][col] == "•" {
                    line += faction.enemy.dot
                } else {
                    line.append(grid[row][col])
                }
            }
            print(line)
        }

        print("Legend: A=your artillery (\(faction.dot) \(faction.rawValue)), enemy=\(faction.enemy.dot) \(faction.enemy.rawValue), === enemy trench")
    }
}

func prompt(_ text: String) -> String {
    let data = Data(text.utf8)
    FileHandle.standardOutput.write(data)
    return readLine() ?? ""
}

func promptInt(_ text: String, min: Int, max: Int) -> Int {
    while true {
        let raw = prompt(text)
        if let value = Int(raw), value >= min, value <= max {
            return value
        }
        print("Enter a number from \(min) to \(max).")
    }
}

func chooseOption<T: CaseIterable & RawRepresentable>(_ title: String, type: T.Type) -> T where T.RawValue == String {
    let options = Array(T.allCases)
    print(title)
    for (index, option) in options.enumerated() {
        print("  [\(index + 1)] \(option.rawValue)")
    }

    let choice = promptInt("Select option: ", min: 1, max: options.count)
    return options[choice - 1]
}

let faction = chooseOption("Choose your side:", type: Faction.self)
let map = chooseOption("Choose battlefield map:", type: MapTheme.self)

var game = Game(faction: faction, map: map)
game.run()
