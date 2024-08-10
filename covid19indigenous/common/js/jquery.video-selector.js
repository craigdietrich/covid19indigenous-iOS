(function( $ ) {

	var defaults = {
			hasUserMovedLeftOrRight: false
	};

    $.fn.videoSelector = function(options) {

    	return this.each(function() {
    	
	    	var self = this;
	    	var $this = $(this);
	    	var opts = $.extend( {}, defaults, options );
	
	    	var $wrapper = $('<div class="container-fluid open-selector-wrapper"></div>').appendTo($this);
	    	var $row = $('<div class="row"></div>').appendTo($wrapper);
	    	$('<div class="col-12"><div class="open-selector-element video"><span class="title">Record video</span></div></div>').appendTo($row);
    		var $next_row = $('<div class="row"></div>').appendTo($wrapper);
    		var $next_cell = $('<div class="col-12"></div>').appendTo($next_row);
    		
    		var calculateTimeDuration = function(secs) {
    		    var hr = Math.floor(secs / 3600);
    		    var min = Math.floor((secs - (hr * 3600)) / 60);
    		    var sec = Math.floor(secs - (hr * 3600) - (min * 60));

    		    if (sec < 10) {
    		        sec = "0" + sec;
    		    }

    		    if(hr <= 0) {
    		        return min + ':' + sec;
    		    }

    		    return hr + ':' + min + ':' + sec;
    		}
    		
	    	$row.find('.open-selector-element').on('click', function() {

	 			$next_cell.empty();
				$next_cell.append('<input type="hidden" name="base64_string" value="" />');
				$next_cell.append('<div style="margin-bottom:10px;"><button class="btn btn-success">Start recording</button><button class="btn btn-danger" style="display:none;">Stop recording</button></div>');
				$next_cell.append('<video class="open-video" style="width:100%;background-color:#AAAAAA;" playsinline></video>');
	            $next_cell.append('<div class="progress" style="max-width:400px;margin:0px auto 0px auto;"><div class="progress-bar" style="width:0%;" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div></div>');
				$next_cell.append('<div class="progress-text"><span>0:00</span> / 1:00</div>');
	            navigator.mediaDevices.getUserMedia({
                    video: {
                        facingMode: {exact : 'environment'}
                    },
                    audio: true 
                }).then(function(camera) {
                    var video = $next_cell.find('video')[0];
                    video.setAttribute('autoplay', 'autoplay');
                    video.setAttribute('muted', 'muted');
                    video.setAttribute('playsinline', 'playsinline');
                    //video.setAttribute('controls', 'controls');
                    video.srcObject = camera;
                    video.play = true;
	                recorder = RecordRTC(camera, {
	                    type: 'video',
	                });
	                var is_recording = false;
	                $next_cell.find('button:first').on('click', function() {
	                	is_recording = true;
	                	var $this = $(this);
	                	$this.hide();
	                	$this.nextAll('button').show();
	                	recorder.startRecording();
	                	var timer = 0;
	                	var max_time = 60;
	                	var doTimer = function(timer) {
	                		if (!is_recording) return;
	                		if (timer == max_time) {
	    	                	is_recording = false;
	    	                	$(this).hide();
	    	                    recorder.stopRecording(function() {
	    	                        var blob = recorder.getBlob();
	    	                        camera.getTracks().forEach(function(track) {
	    	                        	track.stop();
	    	                        });
	    	    	                $next_cell.find('video')[0].srcObject = null;
	    	    	                $next_cell.find('video')[0].autoplay = false;
	    	    	                $next_cell.find('video')[0].controls = true;
	    	    	                $next_cell.find('video')[0].muted = false;
	    	                        $next_cell.find('video')[0].src = URL.createObjectURL(blob);
	    	                        $next_cell.find('.progress, .progress-text').hide();
	    	                        var reader = new FileReader();
	    	                        reader.onloadend = function() {
	    	                            var encoded = reader.result;                
	    	                            $next_cell.find('input[type="hidden"]').val(encoded);
	    	                        }
	    	                        reader.readAsDataURL(blob); 
	    	                    });
	                			return;
	                		}
	                		timer++;
	                		var str = calculateTimeDuration(timer);
	                		$this.closest('.row').find('.progress-text').find('span').text(str);
	                		var width = (timer / max_time) * 100;
	                		$this.closest('.row').find('.progress').children('div').css('width', width + '%');
	                		setTimeout(function() {
	                			doTimer(timer);
	                		}, 1000);
	                	}
	                	doTimer(timer);
	                });
	                $next_cell.find('button:last').on('click', function() {
	                	is_recording = false;
	                	$(this).hide();
	                    recorder.stopRecording(function() {
	                        var blob = recorder.getBlob();
	                        camera.getTracks().forEach(function(track) {
	                        	track.stop();
	                        });
	    	                $next_cell.find('video')[0].srcObject = null;
	    	                $next_cell.find('video')[0].autoplay = false;
	    	                $next_cell.find('video')[0].controls = true;
	    	                $next_cell.find('video')[0].muted = false;
	                        $next_cell.find('video')[0].src = URL.createObjectURL(blob);
	                        $next_cell.find('.progress, .progress-text').hide();
	                        var reader = new FileReader();
	                        reader.onloadend = function() {
	                            var encoded = reader.result;                
	                            $next_cell.find('input[type="hidden"]').val(encoded);
	                        }
	                        reader.readAsDataURL(blob); 
	                    });
	                });
                }).catch(function(error) {
                    $next_cell.empty();
                    $next_cell.append('<input type="hidden" name="base64_string" value="" />');
                    $next_cell.append('<input type="file" style="display:none;" />');  // TODO: image-specific attribute
                    $next_cell.append('<div style="text-center msg"></div>');
                    $next_cell.append('<video src="" style="width:100%;" />');
                    $next_cell.find('input[type="file"]').on('change', function() {
                         var reader = new FileReader();
                         var f = this.files;
                         $next_cell.find('.msg').text('Reading file from your device...');
                         reader.onloadend = function () {
                            $next_cell.find('.msg').text('');
                            var encoded = reader.result;
                            var mime = encoded.substring("data:".length, encoded.indexOf(";base64"));
                            var mime_arr = mime.split('/');
                            if (mime_arr[0].toLowerCase() != 'video' || 'undefined' == typeof(mime_arr[1])) {
                                alert('Uploaded file was not a video. Please try again.');
                                return;
                            }
                           $next_cell.find('video')[0].srcObject = null;
                          $next_cell.find('video')[0].autoplay = false;
                          $next_cell.find('video')[0].controls = true;
                          $next_cell.find('video')[0].muted = false;
                            $next_cell.find('video').attr('src', encoded);
                            $next_cell.find('input[type="hidden"]').val(encoded);
                         };
                         setTimeout(function() {
                            reader.readAsDataURL(f[0]);
                         }, 500);
                    }).trigger('click');
                });

	    	});
	    	
	    	$this.find('form')[0].getValues = function() {
	    		var $form = $(this);
	    		var $container = $form.closest('.container');
	    		if ($container.find('input[name="base64_string"]').length && $container.find('input[name="base64_string"]').val().length) {
	    			return ['video', $container.find('input[name="base64_string"]').val()]
	    		} else {
	    			return [];
	    		}
	    	};
	    	
	    	$this.find('form')[0].setValues = function(values) {
	    		var $form = $(this);
	    		var $container = $form.closest('.container');
	    		if ('undefined' == typeof(values[0]) || 'undefined' == typeof(values[1])) return;
	    		var type = values[0];
	    		switch (type) {
	    			case 'open-text':
	    				$container.find('.text').click();
	    				$container.find('textarea').val(values[1]);
	    				break;
	    			case 'open-photo':
	    				// TODO
	    				break;
	    			case 'open-video':
	    				// TODO
	    				break;
	    			case 'open-audio':
	    				// TODO
	    				break;
	    		}
	    	}
	    	
    	});	
	    	
    };

}( jQuery ));
