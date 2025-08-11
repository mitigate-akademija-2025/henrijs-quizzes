import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }
  static targets = ["progress"]

  connect() {
    this.duration = this.hasTimeoutValue ? this.timeoutValue : 4500
    this.startAt = performance.now()
    this.remaining = this.duration

    // progress bar animation
    this._animateProgress(this.remaining)
    // auto-dismiss timer
    this._startTimer(this.remaining)
  }

  disconnect() { this._clearTimer() }

  pause() {
    // stop timer + freeze progress
    this._clearTimer()
    this.remaining -= performance.now() - this.startAt
    this._freezeProgress()
  }

  resume() {
    this.startAt = performance.now()
    this._animateProgress(this.remaining)
    this._startTimer(this.remaining)
  }

  dismiss() {
    // graceful exit
    this.element.classList.add("opacity-0", "translate-y-2", "scale-95")
    setTimeout(() => this.element.remove(), 160)
  }

  // ---- helpers ----
  _startTimer(ms) {
    this._clearTimer()
    this.timer = setTimeout(() => this.dismiss(), ms)
  }

  _clearTimer() {
    if (this.timer) clearTimeout(this.timer)
    this.timer = null
  }

  _animateProgress(ms) {
    if (!this.hasProgressTarget) return
    // reset to current width then animate to 0
    const bar = this.progressTarget
    // compute current width percentage if resuming
    const pct = (this.remaining / this.duration) * 100
    bar.style.transition = "none"
    bar.style.width = pct + "%"
    // next frame: animate to 0 in remaining time
    requestAnimationFrame(() => {
      bar.style.transition = `width ${ms}ms linear`
      bar.style.width = "0%"
    })
  }

  _freezeProgress() {
    if (!this.hasProgressTarget) return
    const bar = this.progressTarget
    const computed = getComputedStyle(bar)
    // force current width so it stays put when we remove transition
    const width = computed.width
    bar.style.transition = "none"
    bar.style.width = width
  }
}
