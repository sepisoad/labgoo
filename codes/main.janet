(use ./globs)
(import ./helpers :as H)

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

	(parser/consume p (slurp (H/get-db-path g-posts-repo)))
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
			(quit -1)))
	
	(when (not (nil? new))
		(merge-into posts new)		
		(spit (H/get-path g-posts-repo) (string/format "%j" posts)))

	(H/update-posts-hash posts)
	(H/update-posts-id (switch-hash-id posts))

	(def id-post
		(map
			(fn [h]  {(get (get posts h) :id) (get (get posts h) :name)})
			(keys posts)))
	
	(def tags-repo @{})
	(map 
		(fn [post] 
			(def page-tags (H/get-tags(post :name)))			
			(def tags (get page-tags :tags))
			(def page (get page-tags :page))			
			(each tag tags
				(when (nil? (get tags-repo tag))
					(put tags-repo tag @[]))
				(array/push (get tags-repo tag) page)))
		(values posts))

	(H/update-pages
		(let [pids (partition g-news-per-page (reverse (sort (keys g-posts-id))))
					pages (map (fn [num] @{:page (string/format "page-%d" num) :refs @[]}) (range 1 (+ (length pids) 1)))]						
			(map 
				(fn [page ids]
					(array/push 
						(get page :refs)
						;(map 
							(fn [id] {:id id :hash ((get g-posts-id id) :hash)})
							ids)))
				pages
				pids)
			pages))
	
	(put (get g-pages 0) :page "index") # a hack to use index as page-1

	(spit (H/get-db-path g-posts-repo) (string/format "%j" g-posts-hash))
	
	(for i 0 (length g-pages)	
		(H/gen-page 
			(get (get g-pages i) :page)
			(get (get g-pages i) :refs)
			(H/get-path g-content-dir)
			(get (get g-pages (- i 1)) :page)
			(get (get g-pages (+ i 1)) :page)))

	(each tag (keys tags-repo)
		(H/gen-tag-pages tag (get tags-repo tag) g-content-dir))

	(map
		(fn [name] 
			(spit 
				(H/get-content-path name)
				(slurp (H/get-draft-path name))))
		(H/get-drafts)))