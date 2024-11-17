import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }


    // app.group("chats") { chats in
    // // GET /chats
    //   chats.get { req async -> String in
    //     "Chats"
    //   }
    // POST /chats
      // chats.post(PathComponent) { Request in
      //   ResponseEncodable
      // } { req in
      
      // }
      // chats.delete { req in
      
      // }

      // chats.group(":id") { chat in
      //     // GET /chats/:id
      //     chat.get { req-> String in
      //       guard let id = req.parameters.get("id", as: Int.self) else {
      //         throw Abort(.badRequest)
      //       }
      //     return "Chats, \(id)!" }
          // // POST /chats/:id
          // chat.post { ... }
          // // DELETE /chats/:id
          // user.delete { ... }
     // }
  //}

  try app.register(collection: ChatController())
}
