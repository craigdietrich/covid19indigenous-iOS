(function( $ ) {

	var action = null;
	var defaults = {
		info: {},
		key: null
	};

    $.fn.action = function(options, options2) {

    	if ('string' == typeof(options)) {
    		action = options;
    		options = options2;
    	}
    	
    	return this.each(function() {
    	
	    	var self = this;
	    	var $this = $(this);
	    	var opts = $.extend( {}, defaults, options );
	    	var $modal = $('#feedbackModal');
	    	
	    	var doLoadFromSaved = function() {
	    		
    			var formStorage = JSON.parse(localStorage.getItem('forms'));
    			if (!formStorage) formStorage = {};
    			if ('undefined' == typeof(formStorage[opts.info.id])) {
    				return false;
    			}
    			questions = formStorage[opts.info.id];
    			for (var j = 0; j < questions.length; j++) {
    				var id = questions[j].id;
    				var answers = questions[j].answers;
    				console.log(id);
    				console.log(answers);
    				$('form[data-question-id="'+id+'"]')[0].setValues(answers);
    			}
    			return true;
	    		
	    	};
	    	
	    	var doStartOver = function() {
    			var formStorage = JSON.parse(localStorage.getItem('forms'));
    			if (!formStorage) formStorage = {};
    			if ('undefined' != typeof(formStorage[opts.info.id])) {
    				delete formStorage[opts.info.id];
    			}
    			localStorage.setItem('forms', JSON.stringify(formStorage));
    			return true;
	    		
	    	}
	    	
	    	var testConnection = function(successCallback, errorCallback) {
	    		
    			// Test connection
	    		$.ajax({
	    			url: opts.info.handler + '?test_connection=1', 
	    			type: "GET"
	    		}).done(function() {
	    			successCallback()
	    		}).fail(function(data) {
	    			errorCallback()
	    		});
	    		
	    	}
	    	
	    	var finish = function(callback) {
	    		
	    		doStartOver();
	    		// Extract answers for each question
    			var questions = [];
    			$this.find('form:visible').each(function() {
    				var $form = $(this);
    				var id = $form.data('question-id');
    				var answers = $form[0].getValues(); 
    				questions.push({id:id,answers:answers});
    			});
    			// Save to handler
	    		var json = {
		    		action:'doSaveAnswers',
		    		questionnaire_id:opts.info.id,
		    		key:opts.key,
		    		answers:questions
		    	};
	    		console.log(json);
	    		$.ajax({
	    			url: opts.info.handler,
	    			type: "POST",
	    			dataType: 'json',
	    			contentType: 'application/json',
	    			data: JSON.stringify(json),
	    			success: function success(data) {
	    				if ('undefined' != typeof(data.error)) {
	    					alert('There was an error attempting to save the questionnaire: '+data.error);
	    					$('#finishModal').find('button').prop('disabled', false);
	    					return;
	    				}
	    	    		callback();
	    			}
	    		}).fail(function(data) {
	    		    callback();
	    		});
	    		
	    	};
	    	
	    	var doSaveForLater = function() {
	    		
	    		// Extract answers for each question
    			var questions = [];
    			$this.find('form:visible').each(function() {
    				var $form = $(this);
    				var id = $form.data('question-id');
    				var answers = $form[0].getValues(); 
    				questions.push({id:id,answers:answers});
    			});
    			// Save to localStorage
    			var formStorage = JSON.parse(localStorage.getItem('forms'));
    			if (!formStorage) formStorage = {};
    			formStorage[opts.info.id] = questions;
    			localStorage.setItem('forms', JSON.stringify(formStorage));
    			return true;
	    		
	    	};
	    	
	    	switch (action) {
	    	
	    		case 'start_over':
	    			$('#startOverModal').modal();
	    			$('#startOverModal').find('button:first').off('click').on('click', function() {
	    				$('#startOverModal').modal('hide');
	    			});
	    			$('#startOverModal').find('button:last').off('click').on('click', function() {
	    				$('#startOverModal').modal('hide');
	    				doStartOver();
	    				document.location.reload();
	    			});
	    			break;
	    		case 'check_save_for_later':
	    			var formStorage = JSON.parse(localStorage.getItem('forms'));
	    			if (!formStorage) formStorage = {};
	    			if ('undefined' != typeof(formStorage[opts.info.id])) {
	    				$('.saved').show();
	    			}
	    			break;
	    		case 'finish':
	    			$finishModal = $('#finishModal');
	    			$finishModal.modal();
	    			$finishModal.find('button:first').off('click').on('click', function() {
	    				$finishModal.modal('hide');
	    			});
	    			$finishModal.find('button:last').off('click').on('click', function() {
	    				$finishModal.find('button').prop('disabled', true);
	    				$('#finishModalSpinnerWrapper').html('<div class="col-12 text-center"><div class="spinner-border text-primary" role="status"><span class="sr-only">Loading...</span></div></div>');
	    				testConnection(function() {
		    				finish(function() {
		    					$finishModal.find('button').prop('disabled', false);
		    					$('#finishModalSpinnerWrapper').html('');
		    					document.location.href = 'completed.html';
		    				});
	    				}, function() {
	    					$('#finishModal').find('button').prop('disabled', false);
	    					$('#finishModalSpinnerWrapper').html('');
	    					alert("It appears you aren't connected to the network. Please reconnect and try again.");
	    				});
	    			});
	    			break;
	    		case 'save_for_later':
	    			$saveForLaterModal = $('#saveForLaterModal');
	    			$saveForLaterModal.modal();
	    			$saveForLaterModal.find('button:first').off('click').on('click', function() {
	    				$saveForLaterModal.modal('hide');
	    			});
	    			$saveForLaterModal.find('button:last').off('click').on('click', function() {
	    				$saveForLaterModal.find('button').prop('disabled', true);
	    				doSaveForLater();
	    				document.location.reload();
	    			});
	    			break;
	    		case 'load_from_saved':
	    			$('.saved').find('button').prop('disabled', true);
	    			doLoadFromSaved();
	    			$('.saved').find('button').prop('disabled', false);
	    			$('.saved').hide();
	    			break;
	    	};
	    	
    	});	
	    	
    };

}( jQuery ));