import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "search", "results", "resultsHint", "customerId", "pickerPanel", "selectedPanel",
    "selectedName", "selectedMeta", "productArea", "stepHint", "customerBar", "pickerCard"
  ]
  static values = { customers: Array }

  static MAX_RESULTS = 8
  static MIN_QUERY = 2

  connect() {
    this.lockProducts()
    this.showEmptyResults()
    this.searchTarget.focus()
  }

  filterCustomers() {
    clearTimeout(this._debounce)
    this._debounce = setTimeout(() => this.applyFilter(), 150)
  }

  applyFilter() {
    const query = this.searchTarget.value.toLowerCase().trim()

    if (query.length < this.constructor.MIN_QUERY) {
      this.showEmptyResults()
      return
    }

    const filtered = this.customersValue.filter((c) =>
      c.name.toLowerCase().includes(query) ||
      (c.phone && c.phone.includes(query)) ||
      (c.address && c.address.toLowerCase().includes(query))
    )

    this.renderResults(filtered, query)
  }

  showEmptyResults() {
    if (this.hasResultsHintTarget) {
      this.resultsHintTarget.textContent = `${this.customersValue.length} pelanggan — ketik min. ${this.constructor.MIN_QUERY} karakter`
    }
    this.resultsTarget.innerHTML = `
      <div class="text-center py-10 px-4">
        <div class="text-3xl mb-2">🔍</div>
        <p class="text-sm text-slate-500">Ketik nama, telepon, atau alamat pelanggan</p>
      </div>
    `
  }

  renderResults(customers, query) {
    const limited = customers.slice(0, this.constructor.MAX_RESULTS)
    const remaining = customers.length - limited.length

    if (this.hasResultsHintTarget) {
      this.resultsHintTarget.textContent = customers.length === 0
        ? "Tidak ada hasil"
        : `Menampilkan ${limited.length} dari ${customers.length} hasil`
    }

    if (customers.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="text-center py-8 text-slate-400 text-sm">
          Pelanggan "<strong>${this.escapeHtml(query)}</strong>" tidak ditemukan
        </div>
      `
      return
    }

    this.resultsTarget.innerHTML = `
      ${limited.map((c) => `
        <button type="button"
                data-action="click->pos-customer#selectCustomer"
                data-customer-id="${c.id}"
                data-customer-name="${this.escapeAttr(c.name)}"
                data-customer-meta="${this.escapeAttr(this.customerMeta(c))}"
                class="w-full flex items-center justify-between gap-3 p-3 rounded-xl border border-slate-100 hover:border-sky-300 hover:bg-sky-50/50 transition text-left">
          <div class="flex items-center gap-3 min-w-0">
            <div class="w-9 h-9 bg-sky-100 rounded-lg flex items-center justify-center text-sm flex-shrink-0">👤</div>
            <div class="min-w-0">
              <p class="font-medium text-slate-900 truncate text-sm">${this.escapeHtml(c.name)}</p>
              <p class="text-xs text-slate-500 truncate">${this.escapeHtml(this.customerMeta(c))}</p>
            </div>
          </div>
          <span class="text-[10px] font-medium px-2 py-0.5 rounded-full flex-shrink-0 ${c.type === "business" ? "bg-violet-100 text-violet-700" : "bg-emerald-100 text-emerald-700"}">
            ${c.type === "business" ? "Biz" : "Retail"}
          </span>
        </button>
      `).join("")}
      ${remaining > 0 ? `
        <p class="text-center text-xs text-slate-400 py-2">+${remaining} pelanggan lain — perjelas pencarian</p>
      ` : ""}
    `
  }

  selectCustomer(event) {
    const btn = event.currentTarget
    this.applySelection(btn.dataset.customerId, btn.dataset.customerName, btn.dataset.customerMeta)
  }

  skipCustomer() {
    this.applySelection("", "Pelanggan Umum (Walk-in)", "Transaksi tanpa pelanggan terdaftar")
  }

  applySelection(id, name, meta) {
    if (this.hasCustomerIdTarget) {
      this.customerIdTarget.value = id
    }

    this.selectedNameTarget.textContent = name
    this.selectedMetaTarget.textContent = meta

    if (this.hasPickerPanelTarget) {
      this.pickerPanelTarget.classList.add("hidden")
    }
    if (this.hasPickerCardTarget) {
      this.pickerCardTarget.classList.add("hidden")
    }
    this.selectedPanelTarget.classList.remove("hidden")

    if (this.hasCustomerBarTarget) {
      this.customerBarTarget.classList.remove("hidden")
      const barName = this.customerBarTarget.querySelector("[data-pos-customer-target='barName']")
      const barMeta = this.customerBarTarget.querySelector("[data-pos-customer-target='barMeta']")
      if (barName) barName.textContent = name
      if (barMeta) barMeta.textContent = meta
    }

    if (this.hasStepHintTarget) {
      this.stepHintTarget.classList.add("hidden")
    }

    this.unlockProducts()
    this.focusProductSearch()
  }

  changeCustomer() {
    if (this.hasCustomerIdTarget) {
      this.customerIdTarget.value = ""
    }
    this.searchTarget.value = ""
    this.showEmptyResults()

    if (this.hasPickerPanelTarget) {
      this.pickerPanelTarget.classList.remove("hidden")
    }
    if (this.hasPickerCardTarget) {
      this.pickerCardTarget.classList.remove("hidden")
    }
    this.selectedPanelTarget.classList.add("hidden")

    if (this.hasCustomerBarTarget) {
      this.customerBarTarget.classList.add("hidden")
    }

    if (this.hasStepHintTarget) {
      this.stepHintTarget.classList.remove("hidden")
    }

    this.lockProducts()
    this.searchTarget.focus()
  }

  focusProductSearch() {
    const productSearch = this.element.querySelector("[data-pos-cart-target='search']")
    if (productSearch) {
      setTimeout(() => productSearch.focus(), 100)
    }
  }

  lockProducts() {
    this.productAreaTarget.classList.add("opacity-40", "pointer-events-none", "select-none")
    this.productAreaTarget.setAttribute("aria-disabled", "true")
  }

  unlockProducts() {
    this.productAreaTarget.classList.remove("opacity-40", "pointer-events-none", "select-none")
    this.productAreaTarget.removeAttribute("aria-disabled")
  }

  customerMeta(customer) {
    return [customer.phone, customer.address].filter(Boolean).join(" · ") || "—"
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  escapeAttr(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;")
  }
}
