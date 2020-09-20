(use ./globs)

(defn get-path [name]
	(string (os/cwd) "/" name))

(defn get-draft-path [name]
	(string (get-path g-draft-dir) name))

(defn get-db-path [name]
	(string (get-draft-path (string g-db-dir name))))

(defn get-content-path [name]
	(string (get-path g-content-dir) name))

(defn update-pages [pages]
	(merge-into g-pages pages ))

(defn update-posts-hash [posts]
	(merge-into g-posts-hash posts))

(defn update-posts-id [posts]
	(merge-into g-posts-id posts))

(defn get-drafts []
  (filter
    (fn [dir] (= (get (os/stat (string (os/cwd) "/" g-draft-dir dir)) :mode) :file))
    (os/dir (string (os/cwd) "/" g-draft-dir))))
    
(defn get-drafts-hash []
  (let [result @{}]
    (each d (get-drafts)
      (put result (hash d) d))
   result))
 
(defn get-tags [page]	
	(def buf (slurp (get-draft-path page)))
	(def front (take (string/find "---" buf) buf))
	(def p (parser/new))
	(parser/consume p front)
	(def obj (parser/produce p))	
	(if (nil? (get obj :tags))
		nil
		{:page page :tags (get obj :tags)}))


(defn gen-page [name refs dest older newer]
	(def f (file/open (string dest "/" name ".mdz") :w))
	(when (nil? f)
		(error (string/format "cannot open %s" dest)))

	(file/write f (string/format `{:title "%s"` name))
	(file/write f "\n ");
	(file/write f `:template "page.html"`)
	(file/write f "\n ");
	(file/write f `:kind "page"`)
	(file/write f "\n ");
	(file/write f (string/format `:refs %j` (tuple/brackets ;refs)))	
	(file/write f "\n ");
	(file/write f ":older ")
	(if (not (nil? older))
		(file/write f (string/format "%j" (string older ".html")))
		(file/write f (string/format "%j" nil)))
	(file/write f "\n ");
	(file/write f ":newer ")
	(if (not (nil? newer))
		(file/write f (string/format "%j" (string newer ".html")))
		(file/write f (string/format "%j" nil)))
	(file/write f "}")
	(file/write f "\n---\n");
	(file/close f))

(defn gen-tag-pages [tag pages dest] 
	(def f (file/open (string dest "/" "tag-" tag ".mdz") :w))
	(when (nil? f)
		(error (string/format "cannot open %s" dest)))

	(file/write f (string/format `{:title "%s"` tag))
	(file/write f "\n ")
	(file/write f `:template "tag.html"`)
	(file/write f "\n ")
	(file/write f `:kind "page"`)
	(file/write f "\n ")
	(file/write f (string/format `:pages %j` (tuple/brackets ;(map |(string/trimr $ ".mdz") pages))))	
	(file/write f "\n ")
	(file/write f "}")
	(file/write f "\n---\n")
	(file/close f))