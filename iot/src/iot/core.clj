(ns iot.core
  (:import
    [com.ericsson.otp.erlang OtpNode OtpErlangTuple]
    [org.eclipse.paho.client.mqttv3 MqttClient IMqttMessageListener])
  (:require [clojure.core.async :refer [<! >!! go chan]])
  (:gen-class))

  (def topic "iot-topic")

  (def listener
    (reify IMqttMessageListener
      (messageArrived [this _ msg] (println (str "Received " (. msg toString))))))

  (defn mqtt-handle-sub
    [mqtt-client]
    (. mqtt-client subscribe topic listener))

  (defn mqtt-handle-pub
    [mqtt-client
    message]
    (let
      [value (. message stringValue)
      to-publish (. value getBytes)]

      (. mqtt-client publish topic to-publish 0 false)
      (println (str "Published " value))))

  (defn prepare-mqtt-client
    []
    (let
      [mqtt-id (.toString (java.util.UUID/randomUUID))
      mqtt-client (MqttClient. "tcp://localhost:1883" mqtt-id)
      _ (. mqtt-client connect)
      _ (mqtt-handle-sub mqtt-client)]
      mqtt-client))

  (defn -main
    [& args]
    (let
      [node (OtpNode. "iot@localhost")
      _ (. node setCookie "secret")
      mailbox (. node createMbox "mailbox")
      chan-receive (chan)
      mqtt-client (prepare-mqtt-client)
      prepared-mqtt-handle-pub (partial mqtt-handle-pub mqtt-client)]

      (println "Connected!")
      (go
        (loop
          []
          (prepared-mqtt-handle-pub (<! chan-receive))
          (recur)))
      (loop
        []
        (>!! chan-receive (. mailbox receive))
        (recur))))