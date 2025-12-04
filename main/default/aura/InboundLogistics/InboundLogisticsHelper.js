({
   
	focusTOscan:function(component, event){
        $(document).ready(function() {
            component.set("v.scanValue",'');  
            var barcode = "";
            var pressed = false;
            var chars = [];
            
            $(window).keypress(function(e) {
                $(".scanMN").keypress(function(e){ 
                    e.stopPropagation()
                });
                          
                chars.push(String.fromCharCode(e.which)); 
                if (pressed == false) {
                    setTimeout(
                        $A.getCallback(function() {
                            if (chars.length >= 4) {                        
                            var barcode = chars.join("");
                            barcode = barcode.trim();
                            component.set("v.scanValue",barcode);     
                        }
                        chars = [];
                        pressed = false;
                        }), 250
                    );
                                                     
                }              
                pressed = true;
            }); // end of window key press function         
            
            $(window).keydown(function(e){
                if ( e.which === 13 ) {
                    e.preventDefault();
                }
            }); 
            
        });       
        
    },
    
    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }else{
            sforce.one.showToast({
                "title": title,
                "message": message,
                "type": type
            });
        }
        
    },
    
})