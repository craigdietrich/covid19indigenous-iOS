(function( $ ) {

	var defaults = {
		
	};

    $.fn.likertSliderSelector = function(options) {

    	return this.each(function() {
    	
	    	var self = this;
	    	var $this = $(this);
	    	var opts = $.extend( {}, defaults, options );
	
	    	var doRangeColorsAndLabels = function() {
	    		$this.find('input[type="range"]').each(function() {
		    		var $range = $(this);
					var value = $range.val();
					var prompts = $range.data('prompts').split(';');
					var prompt = prompts[parseInt(value) - 1];
					$range.removeClass('range-low').removeClass('range-med').removeClass('range-neu');
					if (opts.prompts.length <= 6) {
						if (prompt.toLowerCase().indexOf("don't know") != -1) {
							$range.addClass('range-neu');
						} else if (value <= Math.ceil(prompts.length * 0.33)) {
							$range.addClass('range-low');
						} else if (value < Math.ceil(prompts.length * 0.66)) {
							$range.addClass('range-med');
						}
					} else {
						if (prompt.toLowerCase().indexOf("don't know") != -1) {
							$range.addClass('range-neu');
						} else if (prompt.toLowerCase().indexOf("not applicable") != -1) {
							$range.addClass('range-neu');
						} else if (value <= Math.floor(prompts.length * 0.33)) {
							$range.addClass('range-low');
						} else if (value < Math.floor(prompts.length * 0.66)) {
							$range.addClass('range-med');
						}						
					}
					$range.nextAll('b').text(prompt);
	    		});
	    	};
	    	
	    	var broadcastValueChange = function() {
	    		$this.trigger( "valueChange", [ '', this, opts ] );
	    	}
	    	
	    	doRangeColorsAndLabels();
	    	broadcastValueChange();
	    	$this.find('input[type="range"]').on('input', doRangeColorsAndLabels); 
	    	$this.find('input[type="range"]').on('input', broadcastValueChange);
	    	
	    	$this.find('form')[0].getValues = function() {
	    		var $form = $(this);
	    		var values = [];
	    		$form.find('input').each(function() {
	    			values.push($(this).val());
	    		});
	    		return values
	    	};
	    	
	    	$this.find('form')[0].setValues = function(values) {
	    		var $form = $(this);
	    		$form.find('input').each(function(index) {
	    			var value = values[index];
	    			if (null == value) return;
	    			$(this).val(value).trigger('input');
	    		});
	    	}
	    	
    	});	
	    	
    };

}( jQuery ));