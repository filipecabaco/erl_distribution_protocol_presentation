# Erlang Distribution Protocol - Interoperability made easy

Did you ever felt that interoperability was difficult? Did you ever miss a library or feature from a different language? Well stress no more! We're going to do a shallow dive onto the Erlang Distribution Protocol with a small example application, showing how EDP enables us to share messages between multiple systems, giving us the power to use multiple languages in a scalable way with little to no sacrifices.

## Requirements
* `brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/f2a764ef944b1080be64bd88dca9a1d80130c558/Formula/python.rb` - Python 3.6.5
* `brew install elixir leinegen mosquitto`

## How to start

* `brew services start mosquitto`
* `epmd -d`
* On ./orchestrator:
  * `mix deps.get`
  * `iex -S mix`
* On ./iot:
  * `lein run`
* On ./registry:
  * `pip3 install -r requirements.txt`
  * `python3 registry.py`

## How to interact?
* On iex: `GenServer.call(Process.whereis(:orchestrator), :stats)`
* On iex: `GenServer.call(Process.whereis(:orchestrator), {:timer, 5000})`