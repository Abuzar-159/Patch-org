({
    helperMethod : function() {
        
    },
    
    helperFun : function(cmp,event,secId) {
        var acc = cmp.find(secId); 
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        } 
    },
    
    init: function(cmp) {
        var wrapper = document.getElementById(this._getWrapperElement(cmp));
        if(wrapper!=null && wrapper!='' && wrapper!=undefined) {     
            var  canvas = wrapper.querySelector('canvas');
            var  minWidth = parseFloat(cmp.get('v.minWidth'));
            var  maxWidth = parseFloat(cmp.get('v.maxWidth'));
            var  penColor = cmp.get('v.penColor');
            
            function resizeCanvas() { 
                var ratio = Math.max(window.devicePixelRatio || 1, 1);
                canvas.width = canvas.offsetWidth * ratio;
                canvas.height = canvas.offsetHeight * ratio;
                canvas.getContext("2d").scale(ratio, ratio);
                
                var ctx = canvas.getContext("2d");
                ctx.beginPath();
                ctx.rect(0, 0, 750, 200);
                ctx.fillStyle = "#ffffff";
                ctx.fill();
            }
            
            cmp.set('v.signaturePad', new SignaturePad(canvas, {
                minWidth: minWidth,
                maxWidth: maxWidth,
                penColor: penColor,
            }));
            resizeCanvas();
        }
    },
    
    _getWrapperElement: function(cmp){
        return 'signatureWrapper' + cmp.get('v.id');
    },
    
    capture: function(cmp) {
        console.log('helper capture called');
        var dataUrl, pad = cmp.get('v.signaturePad');
        pad.trimCanvas();
        dataUrl = pad.toDataURL();
        console.log('helper capture b4 set signatureData');
        cmp.set('v.signatureData', dataUrl);
        console.log('capture helper signatureData~>'+cmp.get('v.signatureData'));
    },
    
    clear: function(cmp) {
        cmp.get('v.signaturePad').clear();
    },
    
    touch: function(cmp) {
        var e = document.querySelector('input.esignature-hide');
        e.focus();
    },
      showToast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type
            });
            toastEvent.fire();
        } else {
            console.error("Toast event not supported.");
        }
    }
})