import { Application } from "@hotwired/stimulus"
import DynamicOptionsController from "./dynamic_options_controller"
import BookController from "./book_controller"
import NoEndDateController from "./no_end_date_controller"

const application = Application.start()
application.register("dynamic-options", DynamicOptionsController)
application.register("book", BookController)
application.register("no-end-date", NoEndDateController)