class csif_printer {

	# ensure printer is installed
	cups_queue { 'csif':
		ensure => 'printer',
		ppd => '/usr/share/cups/model/HP-LaserJet-M605.ppd',
		uri => 'smb://AD3/coe-it-pcprint.engr.ucdavis.edu/CS-Balance',
		location => 'Room 71',
		enabled => true,
		accepting => true,
		options => { printer-op-policy => 'authenticated' },
		notify => Service['cups.service'],
	}

	class { '::cups':
		default_queue => 'csif',
	}


	# clear queue when no one is connected
	exec { "clear_queue":
		command => 'lprm -',
		path => ['/usr/bin', '/bin'],
		onlyif => 'sh -c "W(){ return $(who | wc -l); }; W;"',
	}


	# if printer is not ready restart cups
	exec { "check_status":
		command => '',
		path => ['/usr/bin', '/bin'],
		unless => 'lpq | head -n 1 | grep -q "csif is ready"',
		notify => Service['cups.service'],
	}


	# restart service (when called)
	service { 'cups.service':
		ensure => running,
		enable => true,
	}
}
