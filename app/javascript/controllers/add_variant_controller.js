import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "destroyField"]

  add(e) {
    e.preventDefault()

    const timestamp = new Date().getTime()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)

    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(e) {
    e.preventDefault()

    const item = e.target.closest(".variant-item")
    const destroyField = item?.querySelector("[data-add-variant-target='destroyField']")

    if (destroyField) {
      destroyField.value = "1"
      item.classList.add("hidden")
    } else {
      item?.remove()
    }
  }
}