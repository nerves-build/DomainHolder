use Mix.Config

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :phoenix, :json_library, Jason

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

config :logger, backends: [RingLogger]

key = Path.join(System.user_home!(), ".ssh/id_rsa.pub")
unless File.exists?(key), do: Mix.raise("No SSH Keys found. Please generate an ssh key")

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(key)
  ]

config :domain_holder, prefs_location: "/root/config.term"

config :domain_holder,
  seconds_per_bucket: 5,
  buckets_to_hold: 180

config :domain_holder,
  network_adapter: Nerves.NetworkInterface

config :blink_o_meter,
  uv_meter_gpio_pin: 12,
  breath_depth: 25,
  warning_light_gpio_pin: 18,
  behavior: :decay,
  pigpiox_adapter: Pigpiox,
  neopixel_adapter: Nerves.Neopixel

config :domain_holder, DomainHolderWeb.Endpoint,
  secret_key_base: "/OlhcHuXG0mNeQuBw4Y5Eb9d/kf2h25i+w3NzJxEHYq0PfFQy5l748NM5DcDsl3g",
  render_errors: [view: DomainHolderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DomainHolder.PubSub, adapter: Phoenix.PubSub.PG2],
  http: [:inet6, port: 80],
  root: Path.dirname(__DIR__),
  check_origin: ["http://localhost", "http://127.0.0.1", "//domainholder.local"],
  url: [host: "domainholder.local", port: 80],
  live_view: [signing_salt: "HfpsyY8aJLj52N6xC85CLNKZD5UCrptg"],
  server: true,
  render_errors: [accepts: ~w(html json)]

config :dynu_reporter,
  password: System.get_env("DYNU_UPDATE_PW"),
  location: "RPI0W",
  user_name: System.get_env("DYNU_UPDATE_USERNAME"),
  polling_interval: 1000 * 60 * 30

config :nerves_network,
  regulatory_domain: "US"

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "domainholder.local",
  node_name: "domain_holder",
  node_host: :mdns_domain

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: :"WPA-PSK"
  ],
  eth0: []

# import_config "#{Mix.target()}.exs"
