(defn read-lines [in] (line-seq (java.io.BufferedReader. in)))

(defn mid [[mn mx]] (quot (+ mn mx) 2))
(defn upper [[mn mx]] [(mid [mn mx]) mx])
(defn lower [[mn mx]] [mn (mid [mn mx])])

(defn follow
  ([d rows cols]
   (cond
     (= d \F) [(lower rows) cols]
     (= d \B) [(upper rows) cols]
     (= d \L) [rows (lower cols)]
     (= d \R) [rows (upper cols)])))

(defn find-seat
  ([dirs] (find-seat dirs [0 128] [0 8]))
  ([dirs rows cols]
   (if
    (empty? dirs)
     (let [row (first rows)
           col (first cols)]
       (+ (* row 8) col))
     (apply
      find-seat
      (rest dirs)
      (follow (first dirs) rows cols)))))

(let [seats (map find-seat (read-lines *in*))]
  (prn (apply max seats))
  (prn
   (+ 1 (reduce #(if (= (+ %1 1) %2) %2 %1) (sort seats)))))
