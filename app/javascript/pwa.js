export function registerServiceWorker() {
  if (!("serviceWorker" in navigator)) return

  window.addEventListener("load", () => {
    navigator.serviceWorker
      .register("/service-worker", { scope: "/" })
      .then((registration) => {
        registration.addEventListener("updatefound", () => {
          const installing = registration.installing
          if (!installing) return

          installing.addEventListener("statechange", () => {
            if (installing.state === "installed" && navigator.serviceWorker.controller) {
              console.info("PWA update available — refresh to apply.")
            }
          })
        })
      })
      .catch((error) => {
        console.warn("PWA service worker registration failed:", error)
      })
  })
}

registerServiceWorker()
