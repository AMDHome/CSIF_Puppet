class csif_mount {

	mount { '/home':
		ensure => 'mounted',
		device => 'Yonder.ucdavis.edu:/GFS_ST_NR_4D_CS',
		fstype => 'nfs',
		options => 'rw,bg,soft,rsize=65536,wsize=65536,vers=3,nointr,timeo=600,tcp,noatime',
	}

}
