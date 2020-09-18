(function( $ ) {

	var defaults = {
		
	};

    $.fn.rangeSelector = function(options) {

    	return this.each(function() {
    	
	    	var self = this;
	    	var $this = $(this);
	    	var opts = $.extend( {}, defaults, options );
	
	    	var doRangeColor = function() {
	    		var $range = $this.find('input[type="range"]:first');
				var value = $range.val();
				$range.removeClass('range-low').removeClass('range-med');
				if (value <= Math.ceil(opts.max * 0.33)) {
					$range.addClass('range-low');
				} else if (value < Math.ceil(opts.max * 0.66)) {
					$range.addClass('range-med');
				}
	    	};
	    	
	    	var broadcastValueChange = function() {
	    		var value = $this.find('input[type="range"]:first').val();
	    		$this.trigger( "valueChange", [ value, this, opts ] );
	    	}
	    	
	    	doRangeColor();
	    	broadcastValueChange();
	    	$this.find('input[type="range"]:first').on('input', doRangeColor); 
	    	$this.find('input[type="range"]:first').on('input', broadcastValueChange);
	    	
	    	$this.find('form')[0].getValues = function() {
	    		var $form = $(this);
	    		return [$form.find('input').val()];
	    	};
	    	
	    	$this.find('form')[0].setValues = function(values) {
	    		var $form = $(this);
	    		$form.find('input').val(values[0]);
	    		$form.find('input[type="range"]:first').trigger('input');
	    	}
	    	
    	});	
	    	
    };

}( jQuery ));