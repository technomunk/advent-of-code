(require '[clojure.set])

(defn read-lines [in] (line-seq (java.io.BufferedReader. in)))

(defn answers [group] (map set group))

(defn parse-groups [lines]
  (map
   answers
   (filter
    #(not= % [""])
    (partition-by #(= % "") lines))))

(let [groups (parse-groups (read-lines *in*))]
;;   (prn (apply + (map count (reduce conj groups))))
  (prn (apply + (map count (map #(apply clojure.set/union %) groups))))
  (prn (apply + (map count (map #(apply clojure.set/intersection %) groups)))))
