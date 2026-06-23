# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "pwa", to: "pwa.js"
pin "html5-qrcode", to: "https://esm.sh/html5-qrcode@2.3.8"
pin "tom-select", to: "https://esm.sh/tom-select@2.4.3"
