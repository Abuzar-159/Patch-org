({
	onScriptReady: function(cmp, evt, h) {

		if (cmp.get('v.RecordId') == null || cmp.get('v.RecordId') == 'undefined' || cmp.get('v.RecordId') == '') {
			h.init(cmp);
		}
	},

	onCapture: function(cmp, evt, h) {
		h.capture(cmp);
	},

	handleTouchMove: function(cmp, evt, h) {
		evt.stopPropagation();
	},

	onTouch: function(cmp, evt, h) {
		h.touch(cmp);
	},

	onClear: function(cmp, evt, h) {
		h.clear(cmp);
	},
	saveSignature: function(cmp, evt, h) {
		h.capture(cmp);
		var RecordId = cmp.get('v.RecordId');
		var idata = cmp.get('v.signatureData');
        //alert(idata);
		if (RecordId != null && RecordId != '' && RecordId != 'undefined') {
			h.fetchExistAttachment(cmp);
		} else {
			var action = cmp.get("c.captureSignature");
			action.setParams({
				imageData: cmp.get('v.signatureData'),
				parentid: cmp.get('v.parentID'),
				name: cmp.get('v.Name'),
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				//alert('save status '+state);
				if (state === "SUCCESS") {
					var cmpEvent = cmp.getEvent("cmpEvent");

					cmpEvent.setParams({
						"Attachments": response.getReturnValue(),
					});
					cmpEvent.fire();

				} else {
				}
			});
			$A.enqueueAction(action);
		}
	},
})