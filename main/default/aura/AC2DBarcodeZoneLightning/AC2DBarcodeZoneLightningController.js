({
    doInit : function(component, event, helper) {
        
    },  
    cssLoaded: function(component, event, helper){
        
    },
    jsLoaded: function(component, event, helper){
        
        var bartype=component.get("v.BrcdType");        
        if(bartype == 'qrcode'){          
            jQuery(function processQRCODEBarcode() {
                var height = component.get("v.BrcdHeight");
                var width = component.get("v.BrcdWidth");
                var correctLevel = 2;
                 //var parentId = 'brcode';
                var textEntered = component.get("v.Value");                
                if(height == '') height=150; 
                if(width== '') width=150;
                //jQuery('#brcode').qrcode({
                var D2BarcodeId=component.get("v.D2BarcodeId");
                var parentId = D2BarcodeId;
                
                jQuery('#'+D2BarcodeId).qrcode({
                    render: "canvas",
                    border: 20,
                    text: textEntered,
                    height: height,                                
                    width: width,
                    qrId: "BRCD"+parentId, 
                    correctLevel: correctLevel
                });               
            });
           // exit(0);
        }
        else if(bartype == 'pdf417'){
            
            jQuery(function processPDF417Barcode() {
                var textEntered = component.get("v.Value"); 
                try {  
                    barcode_data.PDF417.init(textEntered);
                } 
                catch(DOMException){
                    console.log("Error :"+DOMException);                    
                }
                var barcode = barcode_data.PDF417.getBarcodeArray(),bw=2,bh=2,e="",canvas=document.createElement("canvas");
                canvas.width=bw*barcode.num_cols;
                canvas.height=bh*barcode.num_rows;
                var height= component.get("v.BrcdHeight")+'px';
                var width= component.get("v.BrcdWidth")+'px';
                canvas.style.height = height;
                canvas.style.width = width;
                if(height == '') canvas.style.height = '150px';
                if(width == '') canvas.style.width = '150px';
                var D2BarcodeId=component.get("v.D2BarcodeId");
                canvas.setAttribute("id", 'canvasId'+D2BarcodeId);
                jQuery('#'+D2BarcodeId).append(canvas);
                for(var ctx=canvas.getContext("2d"),y=0,r=0;r<barcode.num_rows;++r){
                    for(var x=0,c=0;c<barcode.num_cols;++c)
                        1==barcode.bcode[r][c]&&ctx.fillRect(x,y,bw,bh),x+=bw;y+=bh; 
                }
            });
        }
    },
})