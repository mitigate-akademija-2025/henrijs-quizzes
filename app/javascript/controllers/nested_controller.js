  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    static targets = ["list", "template"]
    static values = { index: Number }

    addQuestion() {
      const html = this.templateTarget.innerHTML.replace(/NEW_Q/g, this.indexValue)
      this.listTarget.insertAdjacentHTML("beforeend", html)
      this.indexValue++
    }

    addOption(e) {
      const host = e.currentTarget.closest("[data-question]")
      const template = host.querySelector("[data-option-template]")
      const list = host.querySelector("[data-options-list]")

      const qIndex = host.dataset.questionIndex
      let optIndex = parseInt(host.dataset.optionIndex || "0", 10)

      const html = template.innerHTML
        .replace(/NEW_Q/g, qIndex)
        .replace(/NEW_OPT/g, optIndex)

      list.insertAdjacentHTML("beforeend", html)
      host.dataset.optionIndex = optIndex + 1
    }

  removeQuestion(e) {
    const host = e.currentTarget.closest("[data-question]")
    this._removeOrMark(host)
  }

  removeOption(e) {
    const host = e.currentTarget.closest("[data-option]")
    this._removeOrMark(host)
  }

  _removeOrMark(host) {
    if (!host) return
    const idInput = host.querySelector('input[name$="[id]"], input[name*="[id]"]')
    if (idInput) {
        const destroy = host.querySelector('input[data-role="destroy-flag"], input[name$="[_destroy]"], input[name*="[_destroy]"]')
        if (destroy) destroy.value = "1"
        host.classList.add("opacity-0", "scale-95", "pointer-events-none")
        setTimeout(() => (host.style.display = "none"), 150)
      } else {
        host.classList.add("opacity-0", "scale-95")
        setTimeout(() => host.remove(), 150)
      }
    }
  }
  