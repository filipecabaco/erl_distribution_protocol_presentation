(defproject iot "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.erlang.otp/jinterface "1.6.1"]
                 [org.clojure/core.async "0.4.490"]
                 [org.eclipse.paho/org.eclipse.paho.client.mqttv3 "1.2.0"]]
  :main ^:skip-aot iot.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
