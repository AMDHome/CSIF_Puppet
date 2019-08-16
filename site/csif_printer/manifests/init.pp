class csif_printer {

	# if printer is installed incorrectly, remove it.
	exec {'remove_broken_printer':
		command => 'lpadmin -x csif',
		path => ['usr/sbin', 'usr/bin', '/bin'],
		onlyif => 'lpstat -l -p csif',
		unless => 'ls /etc/cups/ppd/csif.ppd',
	}

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
		purge_unmanaged_queues => true,
	}


	# clear queue when no one is connected
	exec { "clear_queue":
		command => 'lprm -',
		path => ['/usr/bin', '/bin'],
		onlyif => 'exit $(who | wc -l)',
		provider => 'shell'
	}


	# if printer is not ready restart cups (using exec as an if statement)
	exec { "check_status":
		command => ':',
		path => ['/usr/bin', '/bin'],
		unless => 'lpq | head -n 1 | grep -q "csif is ready"',
		notify => Service['cups.service'],
		provider => 'shell',
	}


	# restart service (when called)
	service { 'cups.service':
		ensure => running,
		enable => true,
	}
}
