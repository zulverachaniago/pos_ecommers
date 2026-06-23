import { Controller } from "@hotwired/stimulus"
import { Html5Qrcode, Html5QrcodeSupportedFormats } from "html5-qrcode"

export default class extends Controller {
  static targets = ["input", "form", "modal", "reader"]

  static values = {
    submitOnScan: { type: Boolean, default: true },
    barcodeMode: { type: Boolean, default: false }
  }

  connect() {
    this.scanner = null
    this.scanning = false
  }

  disconnect() {
    this.stopScanner()
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    this.startScanner()
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    this.stopScanner()
  }

  handleEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      if (this.hasFormTarget) this.formTarget.requestSubmit()
    }
  }

  async startScanner() {
    if (this.scanning) return

    const config = {
      fps: 10,
      qrbox: this.barcodeModeValue
        ? { width: 280, height: 120 }
        : { width: 240, height: 240 }
    }

    if (this.barcodeModeValue) {
      config.formatsToSupport = [
        Html5QrcodeSupportedFormats.EAN_13,
        Html5QrcodeSupportedFormats.EAN_8,
        Html5QrcodeSupportedFormats.CODE_128,
        Html5QrcodeSupportedFormats.CODE_39,
        Html5QrcodeSupportedFormats.UPC_A,
        Html5QrcodeSupportedFormats.UPC_E,
        Html5QrcodeSupportedFormats.QR_CODE
      ]
    }

    try {
      this.scanner = new Html5Qrcode(this.readerTarget.id)
      await this.scanner.start(
        { facingMode: "environment" },
        config,
        (decodedText) => this.onScan(decodedText),
        () => {}
      )
      this.scanning = true
    } catch (error) {
      console.error("Scanner error:", error)
      alert("Tidak dapat mengakses kamera. Pastikan izin kamera diaktifkan.")
      this.close()
    }
  }

  async stopScanner() {
    if (!this.scanner || !this.scanning) return

    try {
      await this.scanner.stop()
      this.scanner.clear()
    } catch (_error) {
      // scanner may already be stopped
    }

    this.scanning = false
    this.scanner = null
  }

  onScan(decodedText) {
    const value = decodedText.trim()
    if (!value) return

    this.inputTarget.value = value
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.close()

    if (this.submitOnScanValue && this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }
}
