@testable import App
import XCTVapor
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct AppTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()   
            try await test(app)
            try await app.autoRevert()   
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp { app in
            try await app.test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }
    
    @Test("Getting all the Chats")
    func getAllChats() async throws {
        try await withApp { app in
            let sampleChats = [Chat(title: "sample1"), Chat(title: "sample2")]
            try await sampleChats.create(on: app.db)
            
            try await app.test(.GET, "chats", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try res.content.decode([ChatDTO].self) == sampleChats.map { $0.toDTO()} )
            })
        }
    }
    
    @Test("Creating a Chat")
    func createChat() async throws {
        let newDTO = ChatDTO(id: nil, title: "test")
        
        try await withApp { app in
            try await app.test(.POST, "chats", beforeRequest: { req in
                try req.content.encode(newDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let models = try await Chat.query(on: app.db).all()
                #expect(models.map({ $0.toDTO().title }) == [newDTO.title])
                XCTAssertEqual(models.map { $0.toDTO() }, [newDTO])
            })
        }
    }
    
    @Test("Deleting a Chat")
    func deleteChat() async throws {
        let testChats = [Chat(title: "test1"), Chat(title: "test2")]
        
        try await withApp { app in
            try await testChats.create(on: app.db)
            
            try await app.test(.DELETE, "chats/\(testChats[0].requireID())", afterResponse: { res async throws in
                #expect(res.status == .noContent)
                let model = try await Chat.find(testChats[0].id, on: app.db)
                #expect(model == nil)
            })
        }
    }
}

extension ChatDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}
