module CashierHelper
  NAV_ACTIVE   = "bg-emerald-600/90 text-white shadow-lg shadow-emerald-900/30"
  NAV_INACTIVE = "text-slate-300 hover:bg-white/10 hover:text-white"
  NAV_BASE     = "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition"

  def cashier_nav_link(path, **options, &block)
    nav_opts = options.extract!(:exact, :prefix, :match)
    active = cashier_nav_active?(path, **nav_opts)
    link_to path,
            class: [NAV_BASE, active ? NAV_ACTIVE : NAV_INACTIVE, options[:class]].compact.join(" "),
            **options.except(:class),
            &block
  end

  def cashier_nav_active?(path = nil, exact: false, prefix: nil, match: nil)
    current = request.path

    return current.match?(match) if match
    return current.start_with?(prefix) if prefix
    return current == path if exact

    false
  end
end
