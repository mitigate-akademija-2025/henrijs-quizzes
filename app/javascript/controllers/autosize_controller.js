import { Controller } from "@hotwired/stimulus"

// <textarea data-controller="autosize" data-action="input->autosize#resize"
//           data-autosize-min-rows-value="3" data-autosize-max-rows-value="12">
export default class extends Controller {
  static values = {
    minRows: { type: Number, default: 3 },
    maxRows: { type: Number, default: 14 }
  }

  connect() {
    // prevent scrollbars, allow smooth growth
    this.element.style.overflow = "hidden"
    // ensure a sane starting height
    this._applyHeight()
  }

  resize() {
    this._applyHeight()
  }

  _applyHeight() {
    const el = this.element
    // reset to auto to measure natural content height
    el.style.height = "auto"

    // compute clamp in px using line-height
    const cs = getComputedStyle(el)
    let lineHeight = parseFloat(cs.lineHeight)
    if (Number.isNaN(lineHeight) || cs.lineHeight === "normal") {
      // fallback ~ 1.2 * font-size
      lineHeight = parseFloat(cs.fontSize) * 1.2
    }
    const minPx = this.minRowsValue * lineHeight
    const maxPx = this.maxRowsValue * lineHeight

    const target = Math.min(maxPx, Math.max(minPx, el.scrollHeight))
    el.style.height = `${target}px`
  }
}
