import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.updateState()
  }

  toggle() {
    this.updateState()
    if (this.element.checked) {
      const endDateField = document.querySelector("[data-end-date-field]")
      if (endDateField) endDateField.value = ""
    }
  }

  updateState() {
    const endDateField = document.querySelector("[data-end-date-field]")
    if (endDateField) {
      endDateField.disabled = this.element.checked
    }
  }
}
