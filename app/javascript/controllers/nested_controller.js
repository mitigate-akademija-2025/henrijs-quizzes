// controllers/nested_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]
  static values = { index: Number }

  connect() {
    this.renumber()
  }

  addQuestion() {
    const key = this.indexValue
    const html = this.templateTarget.innerHTML.replaceAll(/NEW_Q/g, String(key))
    this.listTarget.insertAdjacentHTML("beforeend", html)
    this.indexValue = key + 1
    this.renumber()
  }

  addOption(e) {
    const host = e.currentTarget.closest("[data-question]")
    if (!host) return
    const template = host.querySelector("[data-option-template]")
    const list = host.querySelector("[data-options-list]")
    const qIndex = host.dataset.questionIndex
    const optIndex = Number(host.dataset.optionIndex || 0)

    const html = template.innerHTML
      .replaceAll(/NEW_Q/g, String(qIndex))
      .replaceAll(/NEW_OPT/g, String(optIndex))

    list.insertAdjacentHTML("beforeend", html)
    host.dataset.optionIndex = String(optIndex + 1)
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
      setTimeout(() => {
        host.style.display = "none"
        this.renumber()
      }, 150)
    } else {
      host.classList.add("opacity-0", "scale-95")
      setTimeout(() => {
        host.remove()
        this.renumber()
      }, 150)
    }
  }

  renumber() {
    const items = Array.from(this.listTarget.querySelectorAll(':scope > [data-question]'))
      .filter(el => {
        // skip ones marked for destroy or hidden
        const destroyed = el.querySelector('input[data-role="destroy-flag"][value="1"]')
        const hidden = getComputedStyle(el).display === "none"
        return !destroyed && !hidden
      })

    items.forEach((el, i) => {
      const badge = el.querySelector('[data-role="q-number"]')
      if (badge) badge.textContent = `${i + 1}.`
    })
  }
}
