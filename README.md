## Synopsis

Erlang Data Adaptor.

This application handles incoming data, and uses EDC ( Erlang data client/connector ) for connecting and sending data.

The list of available incomming protocols are:

* TCP/IP V4
* TCP/IP v6 ( TODO )
* UDP over v4
* UDP over v6 ( TODO )
* SSL over v4 ( TODO )
* SSL over v6 ( TODO )
* HTTP ( TODO )
* HTTPS (TODO)
* WebSocket ( TODO )
* MQTT
* More comming

## Code Example


## Motivation

Simplify receiving and sending data.

## Installation

git clone
make 

if more debugging is needed, then set env, or change sys.config
```Erlang
application:set_env(interlay, log_debug, false).
application:set_env(edc, log_debug, false).
application:set_env(eda, log_debug, false).
```

## API Reference

Depending on the size of the project, if it is small and simple enough the reference docs can be added to the README.
For medium size to larger projects it is important to at least provide a link to where the API reference docs live.

## Tests

Describe and show how to run the tests with code examples.

## Contributors

Let people know how they can dive into the project, include important links to things like issue trackers,
irc, twitter accounts if applicable.

## License

A short snippet describing the license (MIT, Apache, etc.)

TODO:
- move examples to seperate folder