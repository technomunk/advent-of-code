(defn read-lines [] (line-seq (java.io.BufferedReader. *in*)))

(defn wrapped-nth [coll n]
  (nth coll
       (mod n
            (count coll))))

(defn bool-to-int [b] (if b 1 0))

(defn count-trees
  ([lines slope] (count-trees lines slope [0 0]))
  ([lines [dx dy] [x y]]
   (if
    (>= y (count lines))
     0
     (+
      (bool-to-int (= (wrapped-nth (nth lines y) x) \#))
      (count-trees lines [dx dy] [(+ x dx) (+ y dy)])))))

(let [lines (read-lines)]
  (prn (count-trees lines [3 1]))
  (prn (apply * (map #(count-trees lines %) [[1 1] [3 1] [5 1] [7 1] [1 2]]))))
