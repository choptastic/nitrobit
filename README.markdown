# NitroBit

A simple demo of a bitcoin tracking system using Erlang and Nitrogen 2.3 Beta
and the blockchain API.

You'll need at least Erlang 16 installed.

## To build

```bash
$ git clone git://github.com/choptastic/nitrobit
$ cd nitrobit
$ make fix-slim-release
$ make
$ bin/nitrogen console
```

Then open your browse to: http://127.0.0.1:8002

# If you're new to Nitrogen

The file we're focusing on is
[site/src/index.erl](https://github.com/choptastic/nitrobit/blob/master/site/src/index.erl)

# Author

Jesse Gumm (@jessegumm).
