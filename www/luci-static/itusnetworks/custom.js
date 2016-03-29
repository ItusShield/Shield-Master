var itus_setter = function() {
	var value = document.getElementById('3pm').innerHTML.indexOf('basic') === -1 ? 'no' : 'yes'
	var url = document.URL.split('/admin')[0]
	$.post(url + '/admin/status/itus',
		{
			'cbi.submit':'1',
			'cbid.itus.itus.advanced':value,
			'cbi.apply': 'Save & Apply'
		},
		function(data) {
		},
		'text/html'
	).always(function() {
		setTimeout(location.reload(), 1000)
		location.href = url + '/admin/status/overview'
	})
}

