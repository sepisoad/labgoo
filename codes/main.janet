(import ./helpers :as H)
(import ./globs :as G)

(defn- switch-hash-id [posts]
	(let [res @{}]
		(map
			(fn [h] 
				(def post (merge @{} (get posts h)))
				(def id (get post :id))
				(put post :hash h)
				(put res id post))					
			(keys posts))
		res))

#
# database lookup/update
#

(let [p (parser/new)]	
	(when (empty? (H/get-drafts))
		(error "drafts folder is empty")
		(os/exit))

	(parser/consume p (slurp (H/get-db-path G/posts-repo)))
	(var posts (parser/produce p))
	(def new @{})
	(def existing @{})	
	(def posts-ex (switch-hash-id posts))

	(map # remove existing content dir files
		(fn [name] (os/rm (H/get-content-path name))) 
		(os/dir (H/get-content-path "")))	
	
	(var last-id (max ;(keys posts-ex)))
	(when (nil? last-id) (set last-id 0)) #hack!

	(map 
		(fn [key val] 
			(if (nil? (get posts key))
				(put new key {:name val :id (++ last-id)})
				(put existing key (get posts key))))
		(keys (H/get-drafts-hash)) #key
		(values (H/get-drafts-hash))) #val

	(each h (keys posts) 
		(when (nil? (get existing h))
			(eprint (string "error: " (get (get posts h) :name) " is missing!"))
			(quit)))
	
	(when (not (nil? new))
		(merge-into posts new)		
		(spit (H/get-path G/posts-repo) (string/format "%j" posts)))

	(H/update-posts-hash posts)
	(H/update-posts-id (switch-hash-id posts))

	# (pp G/posts-hash)
	# (pp G/posts-id)
	

	(def id-post
		(map
			(fn [h]  {(get (get posts h) :id) (get (get posts h) :name)})
			(keys posts)))
	

	(H/update-pages
		(let [pids (partition G/news-per-page (reverse (sort (keys G/posts-id))))
					pages (map (fn [num] @{:page (string/format "page-%d" num) :refs @[]}) (range 1 (+ (length pids) 1)))]						
			(map 
				(fn [page ids]
					(array/push 
						(get page :refs)
						;(map 
							(fn [id] {:id id :hash ((get G/posts-id id) :hash)})
							ids)))
				pages
				pids)
			pages))

	(pp G/pages)
	(put (get G/pages 0) :page "index") # a hack to use index as page-1

	(spit (H/get-db-path G/posts-repo) (string/format "%j" G/posts-hash))
	
	(for i 0 (length G/pages)	
		(H/gen-page 
			(get (get G/pages i) :page)
			(get (get G/pages i) :refs)
			(H/get-path G/content-dir)
			(get (get G/pages (- i 1)) :page)
			(get (get G/pages (+ i 1)) :page)))

	(map
		(fn [name] 
			(spit 
				(H/get-content-path name)
				(slurp (H/get-draft-path name))))
		(H/get-drafts)))