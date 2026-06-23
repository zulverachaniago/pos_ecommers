import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  connect() {
    this.instances = new Map()
    this.scheduleInit()

    this.onTurboRender = () => this.scheduleInit()
    document.addEventListener("turbo:render", this.onTurboRender)
    document.addEventListener("turbo:frame-load", this.onTurboRender)

    this.observer = new MutationObserver(() => this.scheduleInit())
    this.observer.observe(this.element, { childList: true, subtree: true })
  }

  disconnect() {
    document.removeEventListener("turbo:render", this.onTurboRender)
    document.removeEventListener("turbo:frame-load", this.onTurboRender)
    this.observer?.disconnect()
    this.destroyAll()
  }

  scheduleInit() {
    clearTimeout(this.initTimer)
    this.initTimer = setTimeout(() => this.initSelects(), 0)
  }

  initSelects() {
    this.selectElements().forEach((select) => this.initSelect(select))
  }

  selectElements() {
    if (this.element.tagName === "SELECT") {
      return this.shouldEnhance(this.element) ? [this.element] : []
    }

    return Array.from(this.element.querySelectorAll("select")).filter((select) => this.shouldEnhance(select))
  }

  shouldEnhance(select) {
    return !select.disabled &&
      !select.dataset.tomSelectSkip &&
      !select.closest("[data-tom-select-skip]")
  }

  initSelect(select) {
    if (select.tomselect) return

    const instance = new TomSelect(select, this.optionsFor(select))
    this.instances.set(select, instance)
  }

  optionsFor(select) {
    const placeholderOption = select.querySelector('option[value=""]')
    const placeholder = select.dataset.tomSelectPlaceholder ||
      placeholderOption?.textContent?.trim() ||
      "Pilih..."

    const plugins = select.multiple ? ["remove_button"] : ["dropdown_input"]
    const settings = {
      create: false,
      allowEmptyOption: true,
      maxOptions: 500,
      placeholder,
      plugins,
      onChange: () => {
        select.dispatchEvent(new Event("change", { bubbles: true }))
        select.dispatchEvent(new Event("input", { bubbles: true }))
      }
    }

    if (select.dataset.tomSelectSearch === "false") {
      settings.plugins = select.multiple ? ["remove_button"] : []
    }

    return settings
  }

  destroyAll() {
    this.instances.forEach((instance) => {
      try {
        instance.destroy()
      } catch (_error) {
        // already destroyed
      }
    })
    this.instances.clear()
  }
}
