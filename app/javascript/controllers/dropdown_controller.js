import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  hide() {
    this.menuTarget.classList.add("hidden")
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  connect() {
    this.outsideClickHandler = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }
}
