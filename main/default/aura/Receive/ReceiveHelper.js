({
    focusTOscan: function (component, event) {
        $(document).ready(function () {
            component.set("v.scanValue", '');
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function (e) {

                $(".scanMN").keypress(function (e) {
                    e.stopPropagation()
                });

                chars.push(String.fromCharCode(e.which));
                if (pressed == false) {
                    setTimeout(
                        $A.getCallback(function () {
                            if (chars.length >= 3) {
                                var barcode = chars.join("");
                                barcode = barcode.trim();
                                component.set("v.scanValue", barcode);
                            }
                            chars = [];
                            pressed = false;
                        }), 250
                    );
                }
                pressed = true;
            }); // end of window key press function         

            $(window).keydown(function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
            });

        });

    },

    AddStock: function (cmp, LWL, counter) {
        let LOLIWrapperList = LWL;
        /* counter :'+counter);*/
        let LOLIWrap = LOLIWrapperList[counter];
        let tsLOLI = [];
        let sLOLITemp = { ERP7__Material_Batch_Lot__c: null };
        if (LOLIWrap.LOLI.ERP7__Product__r.ERP7__Serialise__c != true) sLOLITemp.ERP7__Quantity__c = (LOLIWrap.LOLI.ERP7__Quantity_Received__c) ? LOLIWrap.LOLI.ERP7__Quantity_Received__c : 0;
        if (LOLIWrap.LOLI.ERP7__Product__r.ERP7__Serialise__c == true) sLOLITemp.ERP7__Quantity__c = 1;
        tsLOLI.push(sLOLITemp);

        let SW = {};
        let dateObj = new Date();
        let month = dateObj.getUTCMonth() + 1;
        let day = dateObj.getUTCDate();
        let year = dateObj.getUTCFullYear();
        let todaydate= year + "-" + month + "-" + day;
        
        //var today = new Date();
        //let todaydate = today.toISOString();
        SW.Stock = { ERP7__Batch_Lot__c: null, ERP7__Version__c: LOLIWrap.LOLI.ERP7__Production_Version__c, ERP7__Active__c: true, ERP7__Product__c: LOLIWrap.LOLI.ERP7__Product__c, Name: LOLIWrap.LOLI.Name, ERP7__Checked_In_Date__c: todaydate };
        SW.SPLI = tsLOLI;
        SW.SP={};
        SW.SerialNumber = {};
        SW.BatchNumber={};

        
        
        if (LOLIWrap.LOLI.ERP7__Product__r.ERP7__Serialise__c == true) {
            SW.SerialNumber.ERP7__Serial_Number__c = LOLIWrap.LOLI.ERP7__Starting_Number__c ? LOLIWrap.LOLI.ERP7__Serial_Number_Prefix__c + String(LOLIWrap.StockWrapperList.length + parseInt(LOLIWrap.LOLI.ERP7__Starting_Number__c)) : LOLIWrap.LOLI.ERP7__Serial_Number_Prefix__c;
            SW.SerialNumber.ERP7__Product__c = LOLIWrap.LOLI.ERP7__Product__c;
        }

        if (LOLIWrap.LOLI.ERP7__Product__r.ERP7__Default_Location__c && LOLIWrap.LOLI.ERP7__Product__r.ERP7__Default_Location__r.ERP7__Site__c && LOLIWrap.LOLI.ERP7__Product__r.ERP7__Default_Location__r.ERP7__Site__c == LOLIWrap.LOLI.ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c) { SW.Stock.ERP7__Location__c = LOLIWrap.LOLI.ERP7__Product__r.ERP7__Default_Location__c; }
        LOLIWrap.StockWrapperList.push(SW);
        LOLIWrapperList[counter] = LOLIWrap;

        //comW.LOLIWrapperList = LOLIWrapperList;

        return LOLIWrapperList;
    },
    
    ExplodeKit : function(cmp,comWS,counter){
        let comW = comWS;
        try {
            let LOLIWrapperList = comW.LOLIWrapperList;
            let LOLIWrap = LOLIWrapperList[counter];
           
            let BomsWrapper = [];
            let lineItemprocessedQuantities = new Map();
            
            let MRPS = comW.MRPS;
            let SPLIS = comW.SPLIS;
            let warehouseStocks = comW.warehouseStocks;
            let stockLines=new Map();   
            stockLines = comW.stockLines;
            let SerialMap=new Map();
            SerialMap = comW.SerialMap;

            MRPS.forEach(mrp => {
                let quantityProcessed = 0;
                SPLIS.forEach(SLOLI =>{
                    let LineId;
                    if(SLOLI.ERP7__RMA_Line_Item__c) {LineId = SLOLI.ERP7__RMA_Line_Item__c;} 
                    else if(SLOLI.ERP7__Purchase_Line_Items__c) {LineId = SLOLI.ERP7__Purchase_Line_Items__c;}  
                    else if(SLOLI.ERP7__Work_Order_Line_Items__c) {LineId = SLOLI.ERP7__Work_Order_Line_Items__c;}   
                    else if(SLOLI.ERP7__Transfer_Order_Line_Item__c) {LineId = SLOLI.ERP7__Transfer_Order_Line_Item__c;}
                    
                    if(SLOLI.ERP7__Quantity__c && mrp.ERP7__MRP_Product__c == SLOLI.ERP7__Product__c && LineId && (mrp.ERP7__RMA_Line_Item__c == LineId || mrp.ERP7__Work_Order_Line_Items__c == LineId || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineId)){    quantityProcessed += SLOLI.ERP7__Quantity__c;  }
                });
                
                lineItemprocessedQuantities.set(mrp.ERP7__MRP_Product__c, quantityProcessed);
            });
            
            /*for(ERP7__MRP__c mrp : MRPS){
                Decimal quantityProcessed = 0;
                for(Stock_Inward_Line_Item__c SLOLI : SPLIS){
                    Id LineId;
                    if(SLOLI.ERP7__RMA_Line_Item__c != Null) {LineId = SLOLI.ERP7__RMA_Line_Item__c;} else if(SLOLI.ERP7__Purchase_Line_Items__c != Null) {LineId = SLOLI.ERP7__Purchase_Line_Items__c;}  else if(SLOLI.ERP7__Work_Order_Line_Items__c != Null) {LineId = SLOLI.ERP7__Work_Order_Line_Items__c;}   else if(SLOLI.ERP7__Transfer_Order_Line_Item__c != Null) {LineId = SLOLI.ERP7__Transfer_Order_Line_Item__c;}
                    
                    if(SLOLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SLOLI.Product__c && LineId != Null && (mrp.ERP7__RMA_Line_Item__c == LineId || mrp.ERP7__Work_Order_Line_Items__c == LineId || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineId)){    quantityProcessed += SLOLI.Quantity__c;  }
                }
                lineItemprocessedQuantities.set(mrp.ERP7__MRP_Product__c, quantityProcessed);
            }*/

            MRPS.forEach(mrp=>{
                let LineId;
                if(mrp.ERP7__RMA_Line_Item__c) LineId = mrp.ERP7__RMA_Line_Item__c;
                else if(mrp.ERP7__Purchase_Line_Items__c) LineId = mrp.ERP7__Purchase_Line_Items__c;
                else if(mrp.ERP7__Work_Order_Line_Items__c) LineId = mrp.ERP7__Work_Order_Line_Items__c;
                else if(mrp.ERP7__Transfer_Order_Line_Item__c) LineId = mrp.ERP7__Transfer_Order_Line_Item__c;
                
                
                if(LineId && (mrp.ERP7__RMA_Line_Item__c == LineId || mrp.ERP7__Work_Order_Line_Items__c == LineId || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineId)){
                    let LOLIWrapIN = LOLIWrap.LOLI;
                    LOLIWrapIN.mrp = mrp;
                    LOLIWrapIN.lineItemprocessedQuantity = lineItemprocessedQuantities.get(mrp.ERP7__MRP_Product__c);
                    LOLIWrapIN.Incount  = 0;

                    warehouseStocks.forEach( WIIS =>{
                        if(mrp.ERP7__MRP_Product__c == WIIS.ERP7__Product__c){
                            stockLines.get(WIIS.Id).forEach(SLOLI=>{
                                let LineIdStock;  
                                if(SLOLI.ERP7__RMA_Line_Item__c) LineIdStock = SLOLI.ERP7__RMA_Line_Item__c;
                                else if(SLOLI.ERP7__Purchase_Line_Items__c) LineIdStock = SLOLI.ERP7__Purchase_Line_Items__c;  
                                else if(SLOLI.ERP7__Work_Order_Line_Items__c) LineIdStock = SLOLI.ERP7__Work_Order_Line_Items__c; 
                                else if(SLOLI.ERP7__Transfer_Order_Line_Item__c) LineIdStock = SLOLI.ERP7__Transfer_Order_Line_Item__c;
                                
                                if(SLOLI.ERP7__Quantity__c && mrp.ERP7__MRP_Product__c == SLOLI.ERP7__Product__c && LineIdStock && (mrp.ERP7__RMA_Line_Item__c == LineIdStock || mrp.ERP7__Work_Order_Line_Items__c == LineIdStock || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineIdStock)){
                                    let stockWrap={};
                                    stockWrap.Stock = WIIS;
                                    stockWrap.SPLI = stockLines.get(WIIS.Id);
                                    stockWrap.SP={};
                                    stockWrap.SerialNumber = {};
                                    stockWrap.BatchNumber={};
                                    LOLIWrapIN.Incount += SLOLI.ERP7__Quantity__c;
                                    if(SLOLI.ERP7__Serial__c && SerialMap.get(SLOLI.ERP7__Serial__c)){  stockWrap.SerialNumber = SerialMap.get(SLOLI.ERP7__Serial__c); }
                                    LOLIWrapIN.StockWrapperList.push(stockWrap);
                                    //break;
                                }
                            });                            
                        }
                    });

                    if(LOLIWrapIN.StockWrapperList.length == 0){
                        if(mrp.ERP7__MRP_Product__r.ERP7__Serialise__c != true){
                            let tsLOLI = [];
                            let sLOLITemp = {};
                            sLOLITemp.ERP7__Quantity__c = (LOLIWrapIN.LOLI.ERP7__Quantity_Received__c && LOLIWrapIN.lineItemprocessedQuantity)? ((LOLIWrapIN.LOLI.ERP7__Quantity_Received__c * LOLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/LOLIWrapIN.LOLI.ERP7__Quantity__c) - LOLIWrapIN.lineItemprocessedQuantity : 0;
                            tsLOLI.push(sLOLITemp);
                            let dateObj = new Date();
                            let month = dateObj.getUTCMonth() + 1;
                            let day = dateObj.getUTCDate();
                            let year = dateObj.getUTCFullYear();
                            let todaydate= year + "-" + month + "-" + day;
                            let SW={};
                            SW.Stock = { ERP7__Version__c : LOLIWrapIN.LOLI.ERP7__Production_Version__c, ERP7__Active__c : true, ERP7__Product__c : LOLIWrapIN.MRP.ERP7__MRP_Product__c, Name:LOLIWrapIN.LOLI.Name,ERP7__Checked_In_Date__c:todaydate };
                            SW.SPLI = tsLOLI;
                            SW.SP={};
                            SW.SerialNumber = {};
                            SW.BatchNumber={};
                            LOLIWrapIN.StockWrapperList.push(SW);
                        }else{
                            if(LOLIWrapIN.LOLI.ERP7__Quantity_Received__c && LOLIWrapIN.lineItemprocessedQuantity){
                                let N = ((parseInt(LOLIWrapIN.LOLI.ERP7__Quantity_Received__c) * parseInt(LOLIWrapIN.mrp.ERP7__Total_Amount_Required__c))/parseInt(LOLIWrapIN.LOLI.ERP7__Quantity__c)) - parseInt(LOLIWrapIN.lineItemprocessedQuantity);
                                for(let i=0; i<N; i++){
                                    let tsLOLI = []; 
                                    let sLOLITemp = {ERP7__Material_Batch_Lot__c:null}; 
                                    sLOLITemp.ERP7__Quantity__c = 1;  
                                    tsLOLI.push(sLOLITemp);
                                    let dateObj = new Date();
                                    let month = dateObj.getUTCMonth() + 1;
                                    let day = dateObj.getUTCDate();
                                    let year = dateObj.getUTCFullYear();
                                    let todaydate= year + "-" + month + "-" + day;
                                    let SW={};
                                    SW.Stock = { ERP7__Batch_Lot__c : null, ERP7__Version__c : LOLIWrapIN.LOLI.ERP7__Production_Version__c,ERP7__Active__c : true, ERP7__Product__c : LOLIWrapIN.MRP.ERP7__MRP_Product__c, Name:LOLIWrapIN.LOLI.Name,ERP7__Checked_In_Date__c:todaydate };
                                    SW.SPLI = tsLOLI;
                                    SW.SP={};
                                    SW.BatchNumber={};        
                                    String(LOLIWrapIN.LOLI.ERP7__Starting_Number__c + parseInt(i))                            
                                    SW.SerialNumber.ERP7__Serial_Number__c = (LOLIWrapIN.LOLI.ERP7__Starting_Number__c)? LOLIWrapIN.LOLI.ERP7__Serial_Number_Prefix__c+ String(parseInt(LOLIWrapIN.LOLI.ERP7__Starting_Number__c)+parseInt(i)) : LOLIWrapIN.LOLI.ERP7__Serial_Number_Prefix__c;  
                                    SW.SerialNumber.ERP7__Product__c = LOLIWrapIN.MRP.ERP7__MRP_Product__c; 
                                    LOLIWrapIN.StockWrapperList.push(SW);
                                }
                            }
                        }
                    }
                    BomsWrapper.push(LOLIWrapIN);
                }
            });
           
            /*for(ERP7__MRP__c mrp : MRPS){
                Id LineId;
                if(mrp.ERP7__RMA_Line_Item__c != Null) LineId = mrp.ERP7__RMA_Line_Item__c;
                else if(mrp.ERP7__Purchase_Line_Items__c != Null) LineId = mrp.ERP7__Purchase_Line_Items__c;
                else if(mrp.ERP7__Work_Order_Line_Items__c != Null) LineId = mrp.ERP7__Work_Order_Line_Items__c;
                else if(mrp.ERP7__Transfer_Order_Line_Item__c != Null) LineId = mrp.ERP7__Transfer_Order_Line_Item__c;
                
                
                if(LineId != Null && (mrp.ERP7__RMA_Line_Item__c == LineId || mrp.ERP7__Work_Order_Line_Items__c == LineId || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineId)){
                    LOLIWrapper LOLIWrapIN = new LOLIWrapper(LOLIWrap.LOLI);
                    LOLIWrapIN.mrp = mrp;
                    LOLIWrapIN.lineItemprocessedQuantity = lineItemprocessedQuantities.get(mrp.ERP7__MRP_Product__c);
                    LOLIWrapIN.Incount  = 0;
                    for(Inventory_Stock__c WIIS : warehouseStocks){
                        if(mrp.ERP7__MRP_Product__c == WIIS.Product__c){
                            for(Stock_Inward_Line_Item__c SLOLI : stockLines.get(WIIS.Id)){
                                Id LineIdStock;  if(SLOLI.ERP7__RMA_Line_Item__c != Null) {LineIdStock = SLOLI.ERP7__RMA_Line_Item__c;}  else if(SLOLI.ERP7__Purchase_Line_Items__c != Null) {LineIdStock = SLOLI.ERP7__Purchase_Line_Items__c;}  else if(SLOLI.ERP7__Work_Order_Line_Items__c != Null) {LineIdStock = SLOLI.ERP7__Work_Order_Line_Items__c;}  else if(SLOLI.ERP7__Transfer_Order_Line_Item__c != Null) {LineIdStock = SLOLI.ERP7__Transfer_Order_Line_Item__c;}
                                
                                if(SLOLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SLOLI.Product__c && LineIdStock != Null && (mrp.ERP7__RMA_Line_Item__c == LineIdStock || mrp.ERP7__Work_Order_Line_Items__c == LineIdStock || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineIdStock)){
                                    StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS.Id));
                                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) LOLIWrapIN.Incount += SLOLI.Quantity__c;
                                    if(SLOLI.Serial__c != Null && SerialMap.containsKey(SLOLI.Serial__c)){  stockWrap.SerialNumber = SerialMap.get(SLOLI.Serial__c); }
                                    LOLIWrapIN.StockWrapperList.add(stockWrap);
                                    //break;
                                }
                            }
                            
                        }
                    }
                    if(LOLIWrapIN.StockWrapperList.size() == 0){
                        if(mrp.ERP7__MRP_Product__r.Serialise__c != true){
                            List<Stock_Inward_Line_Item__c> tsLOLI = new List<Stock_Inward_Line_Item__c>();
                            Stock_Inward_Line_Item__c sLOLITemp = new Stock_Inward_Line_Item__c();
                            sLOLITemp.Quantity__c = (LOLIWrapIN.LOLI.Quantity_Received__c != Null && LOLIWrapIN.lineItemprocessedQuantity != Null)? ((LOLIWrapIN.LOLI.Quantity_Received__c * LOLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/LOLIWrapIN.LOLI.Quantity__c) - LOLIWrapIN.lineItemprocessedQuantity : 0;
                            tsLOLI.add(sLOLITemp);
                            StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Version__c = LOLIWrapIN.LOLI.ERP7__Production_Version__c, Active__c = true, Product__c = LOLIWrapIN.MRP.ERP7__MRP_Product__c, Name=LOLIWrapIN.LOLI.Name,Checked_In_Date__c=system.today()), tsLOLI);
                            LOLIWrapIN.StockWrapperList.add(SW);
                        }else{
                            if(LOLIWrapIN.LOLI.Quantity_Received__c != Null && LOLIWrapIN.lineItemprocessedQuantity != Null){
                                Integer N = Integer.valueof(((LOLIWrapIN.LOLI.Quantity_Received__c * LOLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/LOLIWrapIN.LOLI.Quantity__c) - LOLIWrapIN.lineItemprocessedQuantity);
                                for(Integer i=0; i<N; i++){
                                    List<Stock_Inward_Line_Item__c> tsLOLI = new List<Stock_Inward_Line_Item__c>(); Stock_Inward_Line_Item__c sLOLITemp = new Stock_Inward_Line_Item__c(ERP7__Material_Batch_Lot__c=null); sLOLITemp.Quantity__c = 1;  tsLOLI.add(sLOLITemp);
                                    StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Batch_Lot__c = null, Version__c = LOLIWrapIN.LOLI.ERP7__Production_Version__c, Active__c = true, Product__c = LOLIWrapIN.MRP.ERP7__MRP_Product__c, Name=LOLIWrapIN.LOLI.Name,Checked_In_Date__c=system.today()), tsLOLI);    SW.SerialNumber.Serial_Number__c = (LOLIWrapIN.LOLI.Starting_Number__c != Null)? LOLIWrapIN.LOLI.Serial_Number_Prefix__c+String.valueof(LOLIWrapIN.LOLI.Starting_Number__c+i) : LOLIWrapIN.LOLI.Serial_Number_Prefix__c;  SW.SerialNumber.Product__c = LOLIWrapIN.MRP.ERP7__MRP_Product__c; LOLIWrapIN.StockWrapperList.add(SW);
                                }
                            }
                        }
                    }
                    BomsWrapper.add(LOLIWrapIN);
                }
            }*/
            
            LOLIWrap.BOMS = BomsWrapper;
			console.log('LOLIWrap.BOMS length~>',LOLIWrap.BOMS.length);
            LOLIWrapperList[counter] = LOLIWrap;
            
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(e) {console.log('Error:',e); }    
        return comW;
    }

})