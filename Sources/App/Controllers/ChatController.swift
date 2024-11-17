import Fluent
import Vapor

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chats = routes.grouped("chats")

        chats.get(use: self.index)
        chats.post(use: self.create)
        
        chats.group(":chatID") { chat in
            //get all messages
            //chat.get(use: self.showMessages)
            //add message
            //chat.post(use: self.addMessage)
            //delete chat with messages
            chat.delete(use: self.delete)            
        }
    }

    @Sendable
    func index(req: Request) async throws -> [ChatDTO] {
        try await Chat.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> ChatDTO {
        let chat = try req.content.decode(ChatDTO.self).toModel()

        try await chat.save(on: req.db)
        return chat.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let chat = try await Chat.find(req.parameters.get("chatID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await chat.delete(on: req.db)
        return .noContent
    }   
}
