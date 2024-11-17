import Fluent

struct CreateChat: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chats")
            .id()
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chats").delete()
    }
}
