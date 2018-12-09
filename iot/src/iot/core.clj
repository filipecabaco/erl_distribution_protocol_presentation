(ns iot.core
  (:import
   [com.ericsson.otp.erlang OtpNode OtpErlangTuple OtpErlangString OtpErlangAtom OtpErlangObject]
   [org.eclipse.paho.client.mqttv3 MqttClient IMqttMessageListener])
  (:require [clojure.core.async :refer [<! >!! go chan]])
  (:gen-class))

(def topic "iot-topic")

(defn listener
  [mailbox]
  (reify IMqttMessageListener
    (messageArrived [_ _ msg]
      (try
        (let
         [m (. msg toString)
          pid (. mailbox self)
          pid_id (. pid node)
          pid_to_send (OtpErlangString. pid_id)
          message_to_send (OtpErlangString. m)
          type_to_send (OtpErlangAtom. "received")
          tuple_array (into-array OtpErlangObject [type_to_send pid_to_send message_to_send])
          tuple_to_send (OtpErlangTuple. tuple_array)]
          (println (str "Sending to registry " m))
          (. mailbox send "mailbox" "registry@localhost" tuple_to_send))
        (catch Exception error
          (println (. error getMessage ())))))))

(defn mqtt-handle-sub
  [mailbox
   mqtt-client]
  (. mqtt-client subscribe topic (listener mailbox)))

(defn mqtt-handle-pub
  [mqtt-client
   message]
  (let
   [value (. message stringValue)
    to-publish (. value getBytes)]
    (. mqtt-client publish topic to-publish 0 false)
    (println (str "Published " value))))

(defn prepare-mqtt-client
  [mailbox]
  (let
   [mqtt-id (.toString (java.util.UUID/randomUUID))
    mqtt-client (MqttClient. "tcp://localhost:1883" mqtt-id)
    _ (. mqtt-client connect)
    _ (mqtt-handle-sub mailbox mqtt-client)]
    mqtt-client))

(defn -main
  [& args]
  (let
   [id (.toString (java.util.UUID/randomUUID))
    node (OtpNode. (str "iot_" id "@localhost"))
    _ (. node setCookie "secret")
    mailbox (. node createMbox "mailbox")
    chan-receive (chan)
    mqtt-client (prepare-mqtt-client mailbox)
    prepared-mqtt-handle-pub (partial mqtt-handle-pub mqtt-client)]
    (println (str id " Connected!"))
    (go
      (loop []
        (prepared-mqtt-handle-pub (<! chan-receive))
        (recur)))
    (loop []
      (>!! chan-receive (. mailbox receive))
      (recur))))