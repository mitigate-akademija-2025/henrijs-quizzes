import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textValue)
      const original = this.element.textContent
      this.element.textContent = "Copied"
      setTimeout(() => (this.element.textContent = original), 1200)
    } catch {
      const input = document.getElementById("share-link-input")
      input?.select()
      document.execCommand("copy")
    }
  }
}
