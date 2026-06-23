import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form", "paymentMethod", "paymentMethodField", "amountPaidField",
    "checkoutPanel", "paymentPanel",
    "totalBelanjaPayment", "nominalInput",
    "bayarDisplay", "kembalianDisplay", "kembalianWrapper",
    "confirmBtn", "insufficientWarning"
  ]

  connect() {
    this.cartTotal = 0
    this.syncPaymentMethod()
  }

  syncPaymentMethod() {
    if (this.hasPaymentMethodFieldTarget && this.hasPaymentMethodTarget) {
      this.paymentMethodFieldTarget.value = this.paymentMethodTarget.value
    }
  }

  setCartTotal(total) {
    this.cartTotal = total
    if (this.hasTotalBelanjaPaymentTarget) {
      this.totalBelanjaPaymentTarget.textContent = this.formatRupiah(total)
    }
  }

  syncTotal(event) {
    this.setCartTotal(event.detail.total)
  }

  handleCheckout(event) {
    event.preventDefault()
    this.syncPaymentMethod()
    if (this.paymentMethodTarget.value === "cash") {
      this.openPayment()
    } else {
      this.paymentMethodFieldTarget.value = "transfer"
      this.amountPaidFieldTarget.value = ""
      this.formTarget.requestSubmit()
    }
  }

  handleSubmit(event) {
    if (this.paymentMethodTarget.value === "cash") {
      event.preventDefault()
      this.openPayment()
    }
  }

  openPayment() {
    if (this.cartTotal <= 0) {
      const totalEl = this.element.querySelector('[data-pos-cart-target="totalAmount"]')
      if (totalEl) {
        const digits = totalEl.textContent.replace(/\D/g, "")
        this.cartTotal = parseInt(digits, 10) || 0
      }
    }
    if (this.cartTotal <= 0) return

    this.totalBelanjaPaymentTarget.textContent = this.formatRupiah(this.cartTotal)
    this.nominalInputTarget.value = ""
    this.updatePayment()
    this.checkoutPanelTarget.classList.add("hidden")
    this.paymentPanelTarget.classList.remove("hidden")
    this.nominalInputTarget.focus()
  }

  closePayment() {
    this.paymentPanelTarget.classList.add("hidden")
    this.checkoutPanelTarget.classList.remove("hidden")
  }

  updatePayment() {
    const paid = this.parseNominal(this.nominalInputTarget.value)
    const change = paid - this.cartTotal
    const sufficient = paid >= this.cartTotal

    this.bayarDisplayTarget.textContent = this.formatRupiah(paid)
    this.kembalianDisplayTarget.textContent = this.formatRupiah(Math.max(change, 0))

    if (sufficient) {
      this.kembalianWrapperTarget.classList.remove("text-red-600")
      this.kembalianWrapperTarget.classList.add("text-emerald-600")
      this.insufficientWarningTarget.classList.add("hidden")
      this.confirmBtnTarget.disabled = false
      this.confirmBtnTarget.classList.remove("opacity-50", "cursor-not-allowed")
    } else {
      this.kembalianWrapperTarget.classList.remove("text-emerald-600")
      this.kembalianWrapperTarget.classList.add("text-red-600")
      this.kembalianDisplayTarget.textContent = this.formatRupiah(0)
      this.insufficientWarningTarget.classList.remove("hidden")
      this.confirmBtnTarget.disabled = true
      this.confirmBtnTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  setExactAmount() {
    this.nominalInputTarget.value = String(Math.round(this.cartTotal))
    this.updatePayment()
  }

  addNominal(event) {
    const add = parseInt(event.currentTarget.dataset.amount, 10)
    const current = this.parseNominal(this.nominalInputTarget.value)
    this.nominalInputTarget.value = String(current + add)
    this.updatePayment()
  }

  confirmPayment() {
    const paid = this.parseNominal(this.nominalInputTarget.value)
    if (paid < this.cartTotal) return

    this.paymentMethodFieldTarget.value = "cash"
    this.amountPaidFieldTarget.value = paid
    this.formTarget.submit()
  }

  parseNominal(value) {
    const digits = String(value).replace(/\D/g, "")
    return digits === "" ? 0 : parseInt(digits, 10)
  }

  formatNominalInput() {
    const paid = this.parseNominal(this.nominalInputTarget.value)
    if (paid > 0) {
      this.nominalInputTarget.value = paid.toLocaleString("id-ID")
    }
    this.updatePayment()
  }

  formatRupiah(amount) {
    return "Rp " + Math.round(amount).toLocaleString("id-ID")
  }
}
