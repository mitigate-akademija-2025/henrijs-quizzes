import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "choiceTemplate", "textTemplate"]
  static values = { index: Number }

  connect() {
    this.renumber()
  }

  addChoiceQuestion() { this._appendFromTemplate(this.choiceTemplateTarget) }
  addTextQuestion()   { this._appendFromTemplate(this.textTemplateTarget) }

  _appendFromTemplate(template) {
    const key  = this.indexValue++
    const html = template.innerHTML.replaceAll(/NEW_Q/g, String(key))
    this.listTarget.insertAdjacentHTML("beforeend", html)
    this.renumber()
  }

  addOption(e) {
    const host = e.currentTarget.closest("[data-question]")
    if (host) this._appendOption(host)
  }

  _appendOption(host) {
    const tpl  = host.querySelector("[data-option-template]")
    const list = host.querySelector("[data-options-list]")
    if (!tpl || !list) return

    const qIndex = host.dataset.questionIndex
    const optIdx = Number(host.dataset.optionIndex || 0)

    const html = tpl.innerHTML
      .replaceAll(/NEW_Q/g, String(qIndex))
      .replaceAll(/NEW_OPT/g, String(optIdx))

    list.insertAdjacentHTML("beforeend", html)
    host.dataset.optionIndex = String(optIdx + 1)
  }

  removeQuestion(e) { this._removeOrMark(e.currentTarget.closest("[data-question]")) }
  removeOption(e)   { this._removeOrMark(e.currentTarget.closest("[data-option]")) }

  _removeOrMark(node) {
    if (!node) return
    const id = node.querySelector('input[name$="[id]"], input[name*="[id]"]')
    if (id) {
      const destroy = node.querySelector('input[data-role="destroy-flag"]')
      if (destroy) destroy.value = "1"
      node.style.display = "none"
    } else {
      node.remove()
    }
    this.renumber()
  }

  renumber() {
    let n = 1
    this.listTarget.querySelectorAll(':scope > [data-question]').forEach(el => {
      if (getComputedStyle(el).display === "none") return
      const badge = el.querySelector('[data-role="q-number"]')
      if (badge) badge.textContent = `${n++}.`
    })
  }
}