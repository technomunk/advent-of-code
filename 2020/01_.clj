(defn read-inputs [] (line-seq (java.io.BufferedReader. *in*)))

(defn find-pair
  ([numbers] (find-pair numbers 2020))
  ([numbers sum] (filter #(contains? numbers (- sum %)) numbers)))

(defn find-triplet [numbers]
  (filter #(seq (find-pair numbers (- 2020 %))) numbers))

(let [input (into #{} (map parse-long (read-inputs)))
      pair (find-pair input)
      triplet (find-triplet input)]
  (prn pair (apply * pair))
  (prn triplet (apply * triplet)))
