//
//  GameTimer.swift
//  Sudoku
//
//  Created by Everett Matthew Pohl on 10/20/26.
//

final class GameTimer: Codable {
    private let clock = SuspendingClock()
    private var segmentStart: SuspendingClock.Instant?
    private(set) var totalTime: Duration = .zero
    var isRunning: Bool { segmentStart != nil}
    var elapsedTime: Duration {
        guard let start = segmentStart else { return totalTime}
        return totalTime + (clock.now - start)
    }
    
    func start() {
        guard segmentStart == nil else { return }
        segmentStart = clock.now
    }
    
    func pause() {
        guard let start = segmentStart else { return }
        totalTime += clock.now - start
        segmentStart = nil
    }
    
    func reset() {
        totalTime = .zero
        segmentStart = nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case accumulated
    }

    init() {}

    // Only the accumulated duration is persisted; clock instants are meaningless
    // across launches, so a decoded timer always starts out paused.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalTime = try container.decode(Duration.self, forKey: .accumulated)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(elapsedTime, forKey: .accumulated)
    }
}
