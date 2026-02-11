import { Application } from "@hotwired/stimulus"
import DynamicOptionsController from "./dynamic_options_controller"
import BookController from "./book_controller"

const application = Application.start()
application.register("dynamic-options", DynamicOptionsController)
application.register("book", BookController)