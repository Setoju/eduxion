import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  set(event) {
    const days = Number(event.params.days || 0)
    if (!this.hasInputTarget) return

    const date = new Date()
    date.setDate(date.getDate() + days)
    date.setHours(23, 59, 0, 0)

    this.inputTarget.value = this.formatForDateTimeLocal(date)
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  clear() {
    if (!this.hasInputTarget) return

    this.inputTarget.value = ""
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  formatForDateTimeLocal(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    const hours = String(date.getHours()).padStart(2, "0")
    const minutes = String(date.getMinutes()).padStart(2, "0")

    return `${year}-${month}-${day}T${hours}:${minutes}`
  }
}
