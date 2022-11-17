(defn read-inputs [] (line-seq (java.io.BufferedReader. *in*)))

(defn parse-entry [line]
  (let [matches (first (re-seq #"(\d+)-(\d+) ([a-zA-Z]): ([a-zA-Z]+)" line))]
    [(mapv parse-long (take 2 (rest matches)))
     (first (nth matches 3))
     (nth matches 4)]))

(defn count-chars [str ch] (count (filter #(= % ch) str)))
(defn within-limits? [cnt [min max]] (and (>= cnt min) (<= cnt max)))

(defn valid-count? [limits ch line] (within-limits? (count-chars line ch) limits))
(defn valid-pos? [pos ch line]
  (=
   1
   (count-chars
    (map
     #(nth line (- % 1) \0)
     pos)
    ch)))

(let [entries (map parse-entry (read-inputs))]
  (prn (count (filter #(apply valid-count? %) entries)))
  (prn (count (filter #(apply valid-pos? %) entries))))