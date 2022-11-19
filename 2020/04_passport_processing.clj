(require '[clojure.string :as string])

(defn read-lines [in] (line-seq (java.io.BufferedReader. in)))

(defn into-passport [line]
  (into {} (map
            #(string/split % #":")
            (string/split line #" "))))

(defn parse-passports [lines]
  (map into-passport
       (map
        #(string/join " " %)
        (filter
         #(not= % [""])
         (partition-by #(= % "") lines)))))

(defn is-number-between? [s minVal maxVal]
  (try
    (let [value (parse-long s)]
      (and (>= value minVal) (<= value maxVal)))
    (catch Exception _ false)))

(def rules
  {"byr" #(is-number-between? % 1920 2002)
   "iyr" #(is-number-between? % 2010 2020)
   "eyr" #(is-number-between? % 2020 2030)
   "hgt" #(boolean (re-matches #"(1([5-8][0-9]|9[0-3])cm|(59|6[0-9]|7[0-6])in)" %))
   "hcl" #(boolean (re-matches #"#[0-9a-f]{6}" %))
   "ecl" #(contains? #{"amb" "blu" "brn" "gry" "grn" "hzl" "oth"} %)
   "pid" #(boolean (re-matches #"\d{9}" %))})

(defn all-fields-present? [passport] (every? #(contains? passport %) (keys rules)))
(defn valid-passport? [passport] (every? (fn [[field rule]] (rule (get passport field ""))) rules))

(let [passports (parse-passports (read-lines *in*))]
  (prn (count (filter all-fields-present? passports)))
  (prn (count (filter valid-passport? passports))))
