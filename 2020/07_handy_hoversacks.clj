(require '[clojure.string :as string])


(defn read-lines [in] (line-seq (java.io.BufferedReader. in)))
(defn parse-content [content]
  (if (= content "no other bags.")
    nil
    (let [[amount color] (rest (re-find #"(\d+) ([\w\s]+) bags?\.?" content))]
      [color (parse-long amount)])))

(defn parse-rule [line]
  (let [[holder contents] (string/split line #" bags contain " 2)]
    [holder (map parse-content (string/split contents #", "))]))

(let [lines (read-lines *in*)]
  (prn (map parse-rule lines)))
