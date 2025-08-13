// app/javascript/controllers/image_picker_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "removeField"]

  pick() {
    this.inputTarget.click()
  }

  change() {
    const file = this.inputTarget.files?.[0]
    if (!file) return

    // New image chosen: ensure no purge
    if (this.hasRemoveFieldTarget) this.removeFieldTarget.value = "0"

    const url = URL.createObjectURL(file)

    let img = this.previewTarget.querySelector("img")
    if (!img) {
      img = document.createElement("img")
      img.className = "block w-full max-h-64 object-cover"
      this.previewTarget.prepend(img)
    }
    img.src = url
    this.previewTarget.classList.remove("hidden")
    img.onload = () => URL.revokeObjectURL(url)
  }

  remove() {
    // Clear any pending upload
    if (this.hasInputTarget) this.inputTarget.value = ""

    // Ask server to purge existing attachment on save
    if (this.hasRemoveFieldTarget) this.removeFieldTarget.value = "1"

    // Hide preview immediately
    this.previewTarget.classList.add("hidden")
    const img = this.previewTarget.querySelector("img")
    if (img) img.remove()
  }
}
