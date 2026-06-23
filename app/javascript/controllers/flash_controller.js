import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]
  static values = { delay: { type: Number, default: 3000 } }

  connect() {
    this.timeouts = []
    this.messageTargets.forEach((message) => {
      this.timeouts.push(setTimeout(() => this.dismiss(message), this.delayValue))
    })
  }

  disconnect() {
    this.timeouts.forEach(clearTimeout)
  }

  dismiss(message) {
    message.classList.add("opacity-0", "-translate-y-1", "pointer-events-none")
    setTimeout(() => {
      message.remove()
      if (this.element.children.length === 0) this.element.remove()
    }, 300)
  }
}
