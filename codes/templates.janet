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
 (def el 
 	 (find
 	 	(fn [el] 
 	 		(and 
 	 			(struct? el)
 	 			(not (nil? (get el :tag)))
 	 			(not (nil? (get el :content)))
 	 			(not (empty? (get el :content)))
 	 			(= "p" (get el :tag))))
 	  dump))

 (when 
 	(nil? el) 
 	(error "SEPI: this markup file has no <p> tag in it!!!"))
 
 (take 500 (get el :content)))

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

