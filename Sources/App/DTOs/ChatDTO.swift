import Fluent
import Vapor

struct ChatDTO: Content {
    var id: UUID?
    var title: String?
    
    func toModel() -> Chat {
        let model = Chat()
        
        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        return model
    }
}
