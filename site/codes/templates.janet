(import mendoza :as mdz)
(import mendoza/markup :as mrk)
(import mendoza/template :as tmp)
(import mendoza/render :as ren)
(import ./globs :as G)
(import ./helpers :as H)

(def briefing-length 5000)

(defn- get-content-by-ref [ref]    
 (def path (H/get-draft-path (get (H/get-drafts-hash) (get ref :hash))))  
 (def dump (get (mrk/markup (slurp path)) :content))
 (get (find struct? dump) :content)) 

(defn gen-briefing [ref]
	(take briefing-length (string ;(get-content-by-ref ref))))

(defn get-page-by-hash [h]	
	(string/replace ".mdz" ".html" (get (H/get-drafts-hash) h)))

(defn get-title-by-hash [ref]
	(def path (H/get-draft-path (get (H/get-drafts-hash) (get ref :hash)))) 
	(def buf (slurp path))
	(def front (take (string/find "---" buf) buf))
	(def p (parser/new))
	(parser/consume p front)
	(def obj (parser/produce p))
	
	(if (nil? (get obj :title)) 
		""
		(get obj :title)))



(defn get-cover-by-hash [ref]
	(def path (H/get-draft-path (get (H/get-drafts-hash) (get ref :hash)))) 
	(def buf (slurp path))
	(def front (take (string/find "---" buf) buf))
	(def p (parser/new))
	(parser/consume p front)
	(def obj (parser/produce p))
	
	(if (nil? (get obj :cover)) 
		""
		(get obj :cover)))

