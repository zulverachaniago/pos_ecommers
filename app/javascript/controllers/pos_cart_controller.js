import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "productList", "resultsHint", "cartItems", "cartEmpty", "totalAmount", "itemsFields", "submitBtn"]
  static values = { products: Array }

  static MAX_RESULTS = 12
  static MIN_QUERY = 2

  connect() {
    this.cart = []
    this._filteredProducts = []
    this.showEmptyProducts()
  }

  filterProducts() {
    clearTimeout(this._debounce)
    this._debounce = setTimeout(() => this.applyFilter(), 150)
  }

  applyFilter() {
    const query = this.searchTarget.value.toLowerCase().trim()

    if (query.length < this.constructor.MIN_QUERY) {
      this.showEmptyProducts()
      return
    }

    const filtered = this.productsValue.filter((p) =>
      p.label.toLowerCase().includes(query) ||
      (p.sku && p.sku.toLowerCase().includes(query))
    )

    this._filteredProducts = filtered
    this.renderProducts(filtered, query)
  }

  searchKeydown(event) {
    if (event.key !== "Enter") return
    event.preventDefault()

    const query = this.searchTarget.value.trim()
    if (!query) return

    const exact = this.productsValue.find(
      (p) => p.sku && p.sku.toLowerCase() === query.toLowerCase()
    )
    if (exact) {
      this.addProduct(exact)
      return
    }

    if (this._filteredProducts.length > 0) {
      this.addProduct(this._filteredProducts[0])
    }
  }

  showEmptyProducts() {
    this._filteredProducts = []
    if (this.hasResultsHintTarget) {
      this.resultsHintTarget.textContent = `${this.productsValue.length} produk tersedia`
    }
    this.productListTarget.innerHTML = `
      <div class="text-center py-16 px-4">
        <div class="text-4xl mb-3">📦</div>
        <p class="text-sm font-medium text-slate-600 mb-1">Cari produk untuk ditambahkan</p>
        <p class="text-xs text-slate-400">Ketik min. ${this.constructor.MIN_QUERY} karakter atau scan SKU lalu Enter</p>
      </div>
    `
  }

  renderProducts(products, query) {
    const limited = products.slice(0, this.constructor.MAX_RESULTS)
    const remaining = products.length - limited.length

    if (this.hasResultsHintTarget) {
      this.resultsHintTarget.textContent = products.length === 0
        ? "Tidak ada hasil"
        : `Menampilkan ${limited.length} dari ${products.length} hasil`
    }

    if (products.length === 0) {
      this.productListTarget.innerHTML = `
        <div class="text-center py-12 text-slate-400 text-sm">
          Produk "<strong>${this.escapeHtml(query)}</strong>" tidak ditemukan
        </div>
      `
      return
    }

    this.productListTarget.innerHTML = `
      ${limited.map((p) => this.productButtonHtml(p)).join("")}
      ${remaining > 0 ? `
        <p class="text-center text-xs text-slate-400 py-3 sticky bottom-0 bg-white/90 backdrop-blur-sm border-t border-slate-100">
          +${remaining} produk lain — perjelas pencarian
        </p>
      ` : ""}
    `
  }

  productButtonHtml(p) {
    const stock = p.stock ?? 0
    const stockClass = stock <= 0 ? "text-red-600" : stock <= 10 ? "text-amber-600" : "text-slate-500"
    const stockLabel = stock <= 0 ? "Habis" : `Stok: ${stock}${p.unit ? ` ${p.unit}` : ""}`
    const disabled = stock <= 0

    return `
      <button type="button"
              data-action="click->pos-cart#addItem"
              data-variant-id="${p.id}"
              data-price="${p.price}"
              data-label="${this.escapeAttr(p.label)}"
              data-stock="${stock}"
              ${disabled ? "disabled" : ""}
              class="w-full flex items-center justify-between gap-3 p-3 rounded-xl border border-slate-100 ${disabled ? "opacity-50 cursor-not-allowed" : "hover:border-emerald-300 hover:bg-emerald-50/50"} transition text-left group">
        <div class="flex items-center gap-3 min-w-0">
          <div class="w-9 h-9 bg-slate-100 group-hover:bg-emerald-100 rounded-lg flex items-center justify-center text-sm flex-shrink-0 transition">📦</div>
          <div class="min-w-0">
            <p class="font-medium text-slate-900 truncate text-sm">${this.escapeHtml(p.label)}</p>
            ${p.sku ? `<p class="text-xs text-slate-400 font-mono">${this.escapeHtml(p.sku)}</p>` : ""}
            <p class="text-[11px] ${stockClass} font-medium">${stockLabel}</p>
          </div>
        </div>
        <div class="text-right flex-shrink-0">
          <p class="font-semibold text-emerald-600 text-sm">${this.formatRupiah(p.price)}</p>
          <p class="text-[10px] text-emerald-600 ${disabled ? "hidden" : "opacity-0 group-hover:opacity-100"} transition">+ Tambah</p>
        </div>
      </button>
    `
  }

  addItem(event) {
    const btn = event.currentTarget
    if (btn.disabled) return

    this.addProduct({
      id: parseInt(btn.dataset.variantId),
      price: parseFloat(btn.dataset.price),
      label: btn.dataset.label,
      stock: parseInt(btn.dataset.stock || "0", 10)
    })
  }

  addProduct(product) {
    const variantId = product.id
    const price = product.price
    const label = product.label
    const catalogItem = this.productsValue.find((p) => p.id === variantId)
    const maxStock = catalogItem?.stock ?? product.stock ?? null

    const existing = this.cart.find((item) => item.variantId === variantId)
    const nextQuantity = existing ? existing.quantity + 1 : 1

    if (maxStock !== null && nextQuantity > maxStock) {
      if (this.hasResultsHintTarget) {
        this.resultsHintTarget.textContent = maxStock <= 0
          ? `Stok ${label} habis`
          : `Stok ${label} tersisa ${maxStock}`
        this.resultsHintTarget.classList.add("text-red-600")
        clearTimeout(this._flashTimeout)
        this._flashTimeout = setTimeout(() => {
          this.resultsHintTarget.classList.remove("text-red-600")
          this.applyFilter()
        }, 1500)
      }
      return
    }

    if (existing) {
      existing.quantity += 1
    } else {
      this.cart.push({ variantId, price, label, quantity: 1 })
    }

    this.renderCart()
    this.flashAdded(label)
  }

  flashAdded(label) {
    if (!this.hasResultsHintTarget) return
    const original = this.resultsHintTarget.textContent
    this.resultsHintTarget.textContent = `✓ ${label} ditambahkan`
    this.resultsHintTarget.classList.add("text-emerald-600")
    clearTimeout(this._flashTimeout)
    this._flashTimeout = setTimeout(() => {
      this.resultsHintTarget.classList.remove("text-emerald-600")
      this.applyFilter()
    }, 800)
  }

  increase(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    const item = this.cart[index]
    const catalogItem = this.productsValue.find((p) => p.id === item.variantId)
    const maxStock = catalogItem?.stock

    if (maxStock !== undefined && item.quantity + 1 > maxStock) return

    item.quantity += 1
    this.renderCart()
  }

  decrease(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    if (this.cart[index].quantity > 1) {
      this.cart[index].quantity -= 1
    } else {
      this.cart.splice(index, 1)
    }
    this.renderCart()
  }

  removeItem(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.cart.splice(index, 1)
    this.renderCart()
  }

  renderCart() {
    const total = this.cart.reduce((sum, item) => sum + item.price * item.quantity, 0)
    const itemCount = this.cart.reduce((sum, item) => sum + item.quantity, 0)

    if (this.cart.length === 0) {
      this.cartItemsTarget.classList.add("hidden")
      this.cartEmptyTarget.classList.remove("hidden")
      this.submitBtnTarget.disabled = true
      this.submitBtnTarget.classList.add("opacity-50", "cursor-not-allowed")
    } else {
      this.cartItemsTarget.classList.remove("hidden")
      this.cartEmptyTarget.classList.add("hidden")
      this.submitBtnTarget.disabled = false
      this.submitBtnTarget.classList.remove("opacity-50", "cursor-not-allowed")

      this.cartItemsTarget.innerHTML = this.cart.map((item, index) => `
        <div class="flex items-center gap-2 p-2.5 bg-slate-50 rounded-xl">
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-slate-900 truncate">${this.escapeHtml(item.label)}</p>
            <p class="text-xs text-slate-500">${this.formatRupiah(item.price)} × ${item.quantity}</p>
          </div>
          <div class="flex items-center gap-0.5 flex-shrink-0">
            <button type="button" data-action="click->pos-cart#decrease" data-index="${index}"
                    class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:bg-slate-100 font-bold text-sm">−</button>
            <span class="w-7 text-center text-sm font-semibold">${item.quantity}</span>
            <button type="button" data-action="click->pos-cart#increase" data-index="${index}"
                    class="w-7 h-7 rounded-lg bg-white border border-slate-200 text-slate-600 hover:bg-slate-100 font-bold text-sm">+</button>
            <button type="button" data-action="click->pos-cart#removeItem" data-index="${index}"
                    class="w-7 h-7 rounded-lg text-red-500 hover:bg-red-50 text-sm">✕</button>
          </div>
          <p class="text-sm font-semibold text-slate-900 w-20 text-right flex-shrink-0">${this.formatRupiah(item.price * item.quantity)}</p>
        </div>
      `).join("")
    }

    this.totalAmountTarget.textContent = this.formatRupiah(total)
    if (this.submitBtnTarget) {
      this.submitBtnTarget.textContent = this.cart.length === 0 ? "Bayar" : `Bayar (${itemCount} item)`
    }
    this.syncHiddenFields()
    this.dispatch("totalChanged", { detail: { total }, bubbles: true })
  }

  syncHiddenFields() {
    this.itemsFieldsTarget.innerHTML = this.cart.map((item, index) => `
      <input type="hidden" name="pos_transaction[pos_transaction_items_attributes][${index}][product_variant_id]" value="${item.variantId}">
      <input type="hidden" name="pos_transaction[pos_transaction_items_attributes][${index}][quantity]" value="${item.quantity}">
      <input type="hidden" name="pos_transaction[pos_transaction_items_attributes][${index}][price_at_sale]" value="${item.price}">
    `).join("")
  }

  formatRupiah(amount) {
    return "Rp " + Math.round(amount).toLocaleString("id-ID")
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
