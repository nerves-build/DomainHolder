# DomainHolder
DomainHolder is a proof of concept Phoenix app for hosting landing pages for multiple domains. It is the companion project for the blog post at [nerves.build](https://nerves.build/posts/DomainHolding).

It is configured to run as a Nerves device and will run quite happily on an RPI0W. In its Nerves configuration this version of the app expects to be running on the BlinkOMeter platform.

To run this without the BlinkOMeter extras stub out the hardware dependencies in `/fw/config/config.exs'

```
config :blink_o_meter,
  pigpiox_adapter: PigpioxStub,
  neopixel_adapter: NeopixelStub
```


DomainHolder has a number of limitations, among them a lack of authorization and a less than optimal means of persistance. So it should not be used in a situation of any importance.