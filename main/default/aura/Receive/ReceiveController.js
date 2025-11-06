({
	getAllRecieveDetails : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");  
        var logisticIds = logIds.split(",");
        var LIds = JSON.stringify(logisticIds);
        console.log('logisticIds : '+LIds);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var action = cmp.get("c.ReceiveAll");
        action.setParams({LogisticIds:LIds});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                console.log('res of getAllRecieveDetails:',response.getReturnValue());
                cmp.set("v.PreventChange", true);
                cmp.set("v.Container", response.getReturnValue());
                var LOLI=cmp.get('v.Container.LOLIWrapperList');
                var count=0;
                for(var x in LOLI){
                    if(LOLI[x].LOLI.ERP7__Quantity_Received__c > LOLI[x].LOLI.ERP7__Putaway_Quantity__c)
                        count++;
                }
                if(count > 0){
                    cmp.set('v.showSelAll',true);
                }
                cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                cmp.set("v.SiteName", response.getReturnValue().SiteName);
                cmp.set("v.ChannelName", response.getReturnValue().ChannelName);
                cmp.set("v.ChannelId", response.getReturnValue().ChannelId);
                cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                cmp.set("v.PreventChange", false);
                cmp.set("v.ShowAttachment",response.getReturnValue().showReceiveAtt);
                cmp.set("v.putawayLocationReq",response.getReturnValue().putawayLocationReq)
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                
                if(cmp.get("v.Putaway") == true) cmp.PutawayAll();
            }else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(action);
        
    },  
        
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    Reload : function (component, event) {
        window.location.reload();
    },
    
    Back2Inbound : function(cmp, event, helper) {
        $A.createComponent("c:InboundLogistics",{
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
	
	Receive : function(cmp, event, helper) {
        var logIds = cmp.get("v.logisticIds");
        //var RecUrl = "/apex/ReceiveLC?core.apexpages.devmode.url=1&loId=" + logId;
        //window.open(RecUrl,'_self');
        $A.createComponent("c:Receive",{
            "logisticIds":logIds
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    focusTOscan : function (component, event,helper) {
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);  
        
    },
    
    verifyScanCodes : function (cmp, event, helper) {
        var scan_Code = cmp.get("v.scanValue");
        var isPutaway = cmp.get("v.Container.Putaway");
        var mybarcode = scan_Code;
        console.log('verifyScanCodes preventchange~>'+cmp.get("v.PreventChange"));
        if(mybarcode != '' && !cmp.get("v.PreventChange")){
            console.log(scan_Code);
        	console.log(isPutaway);
            cmp.set("v.exceptionError", '');
            console.log(mybarcode); 
            if(mybarcode == 'ORDER') { cmp.Back2Inbound(); }
            else if(mybarcode == 'RECEIVE') { cmp.Receive(); }
            else if(mybarcode == 'PUTAWAY') { cmp.PutawaySelected(); }
            else if(mybarcode == 'SAVE' && !isPutaway) { cmp.SaveLinesReceived(); }
            else if(mybarcode == 'SAVE' && isPutaway) { cmp.SaveAllLOLines(); }
            else if(!isPutaway){
                var itemFound = false;
                var obj = cmp.get("v.Container.LOLIWrapperList");
                for(var x in obj){
                    if(obj[x].selected == false && (obj[x].LOLI.ERP7__Quantity_Received__c > obj[x].LOLI.ERP7__Putaway_Quantity__c) &&(obj[x].LOLI.ERP7__Product__r.ERP7__Barcode__c == mybarcode || obj[x].LOLI.ERP7__Barcode__c == mybarcode)){
                        obj[x].selected = true;
                        itemFound = true;
                        var uscroll = document.getElementById(obj[x].LOLI.Id);
                        uscroll.scrollIntoView();
                        break;
                    }
                    else if(obj[x].selected == true && (obj[x].LOLI.ERP7__Quantity_Received__c > obj[x].LOLI.ERP7__Putaway_Quantity__c) &&(obj[x].LOLI.ERP7__Product__r.ERP7__Barcode__c == mybarcode || obj[x].LOLI.ERP7__Barcode__c == mybarcode)){
                        cmp.set("v.exceptionError", 'Scanned Product is already selected');
                        window.scrollTo(0,0);
                        break;
                    }
                }
                if(itemFound) cmp.set("v.Container.LOLIWrapperList",obj);
                else {
                    for(var x in obj){ 
                        if((obj[x].selected == true || (obj[x].LOLI.ERP7__Quantity_Received__c == obj[x].LOLI.ERP7__Putaway_Quantity__c)) && (obj[x].LOLI.ERP7__Product__r.ERP7__Barcode__c == mybarcode || obj[x].LOLI.ERP7__Barcode__c == mybarcode)){
                            itemFound = true;
                            var uscroll = document.getElementById(obj[x].LOLI.Id);
                            uscroll.scrollIntoView();
                            break;
                        }
                    }
                    if(!itemFound) {
                        cmp.set("v.exceptionError", 'Invalid barcode scanned.');
                        window.scrollTo(0,0);
                    }
                }
                
            } 
            else if(isPutaway){ 
                var LWLR = cmp.get("v.Container.LOLIWrapperList");
            	var LWLI = JSON.stringify(LWLR);
                var Counter = cmp.get("v.Container.counter");
                console.log('Counter~>',cmp.get("v.Container.counter"));
                //alert(Counter);
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var action = cmp.get("c.ScannerMethod");
                action.setParams({LWL:LWLI,barcode:mybarcode,counter:Counter});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") { 
                        if(response.getReturnValue().exceptionError == '') {
                            cmp.set("v.Container.itemFoundOnScan", response.getReturnValue().itemFoundOnScan);
                            cmp.set("v.Container.counter", response.getReturnValue().counter);
                            cmp.set("v.Container.DisMsg", response.getReturnValue().DisMsg);
                            cmp.set("v.Container.LOLIWrapperList", response.getReturnValue().LOLIWrapperList);
                            console.log('LOLIWrapperList~>'+JSON.stringify(response.getReturnValue()));
                        }   
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
            cmp.set("v.scanValue",'');
            cmp.set("v.PreventChange", false);
        }
    },
    
    DeleteRecordAT: function(cmp, event) {
        var result = confirm("Are you sure?");
        var RecordId = event.getSource().get("v.name");
        var ObjName = event.getSource().get("v.title");
        //alert(RecordId);
        if (result) {
            //window.scrollTo(0, 0);
            //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            try{
                var action = cmp.get("c.DeleteAT");
                action.setParams({
                    RAId: RecordId,
                    ObjName: ObjName
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var parentId = '';
                        if(response.getReturnValue().exceptionError == '') {
                            var obj = cmp.get("v.Container.LOLIWrapperList");
                            for(var x in obj){
                                if(obj[x].Attach.Id == RecordId){
                                    parentId = obj[x].LOLI.Id;
                                	obj[x].Attach = response.getReturnValue().universalAttachment;
                                    break;
                                }
                            }
                            cmp.set("v.Container.LOLIWrapperList",obj);
                        }
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //var uscroll = document.getElementById(parentId);
                        //uscroll.scrollIntoView();
                    } else { 
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError); 
                    }
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
            catch(err) {
                //alert("Exception : "+err.message);
            }
        } 
    },
    
    onFileUploaded : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var files = cmp.get("v.FileList");  
    	var file = files[0][0];
        var filek = JSON.stringify(file);
        var parentId = event.getSource().get("v.name");
        if (files && files.length > 0) {
            var reader = new FileReader();
            reader.onloadend = function() {
                var contents = reader.result;
                var base64Mark = 'base64,';
                var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                var fileContents = contents.substring(dataStart);
                        
                var action = cmp.get("c.uploadFile");
                
                action.setParams({
                    parent: parentId,
                    fileName: file.name,
                    base64Data: encodeURIComponent(fileContents),
                    contentType: file.type
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //window.scrollTo(0, 0);            		
                    //alert(state);
                    if (state === "SUCCESS") {
                        //alert(response.getReturnValue().exceptionError);
                        if(response.getReturnValue().exceptionError == '') {
                            var obj = cmp.get("v.Container.LOLIWrapperList");
                           // var achId = cmp.get("v.attachIds");
                            for(var x in obj){
                                if(obj[x].LOLI.Id == parentId){
                                	obj[x].Attach = response.getReturnValue().universalAttachment;
                                 	//achId = obj[x].Attach.Id;
                                    break;
                                }
                            }
                            cmp.set("v.Container.LOLIWrapperList",obj);
                          	//cmp.set("v.attachIds",achId);
                        }        
                        cmp.set("v.exceptionError",response.getReturnValue().exceptionError); 
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        //var uscroll = document.getElementById(parentId);
                        //uscroll.scrollIntoView();
                    } 
                });
                $A.enqueueAction(action); 
            }
            reader.readAsDataURL(file);
        }
    },
    
    reRender : function(cmp, event, helper) { },
    
    SaveLinesReceived : function(cmp, event, helper) {
        var LWLR = cmp.get("v.Container.LOLIWrapperList");
       // var achIds =[];
        var Error = false;
        var isOkmainWrapper = true;
        var isSelect=false;
        var isSelCount=0;
        cmp.set("v.exceptionError","");
        for(var x in LWLR){
            var LOLIW = LWLR[x]; 
            if(LOLIW.Attach.ParentId != undefined) LOLIW.Attach={};
            if(!$A.util.isUndefinedOrNull(LOLIW.LOLI.ERP7__Special_Instruction__c)){
                if(LOLIW.LOLI.ERP7__Special_Instruction__c.length > 255){
                    Error = true; 
                    cmp.set("v.exceptionError", LOLIW.LOLI.Name+': Speacial instruction can not be more that 255 characters');
                }
            }

            if(LOLIW.LOLI.ERP7__Quantity__c == LOLIW.LOLI.ERP7__Quantity_Received__c){
                isSelCount++;
                if(LOLIW.selected){
                    isSelect=true;
                }
            }
                
          /*  var reader = new FileReader();
            reader.onload = function() {
                alert(reader.result);
            }
            reader.readAsText(LOLIW.Attach.body);*/
            // const reader = new FileReader();
    		//reader.readAsDataURL(LOLIW.Attach.body);
          //  LOLIW.Attach.body= JSON.stringify({blob: LOLIW.Attach.body});
            //LOLIW.Attach.body = '';
            //achIds.push(LOLIW.Attach.Id);
            LOLIW.errMsg = '';
            if(parseFloat(LOLIW.ReceiveQty) > LOLIW.LOLI.ERP7__Remaining_Quantity__c){
                Error = true; 
                isOkmainWrapper = false;
                LOLIW.errMsg = 'Quantity Receive cannot be greater than Remaining Quantity';
            }
            if(LOLIW.LOLI.ERP7__Quantity_Received__c < LOLIW.lineItemprocessedQuantity){
                Error = true; 
                isOkmainWrapper = false; 
                LOLIW.errMsg = 'Quantity Received cannot be less than Quantity added';
            }
            if(!Error) LOLIW.LOLI.ERP7__Quantity_Received__c = parseFloat(LOLIW.LOLI.ERP7__Quantity_Received__c) + parseFloat(LOLIW.ReceiveQty);
        }
        if((isSelCount == LWLR.length) && !isSelect){
            cmp.set("v.exceptionError","Please select items to Putaway");
            Error = true;
        }

        if(!isOkmainWrapper) { 
            cmp.set("v.exceptionError","Records not updating on save, please verify the errors below");
        }
        cmp.set("v.Container.LOLIWrapperList",LWLR);
        
        console.log('Error :',Error);
        // Successful Processing 
        if(!Error){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide"); 
            var LWLI = JSON.stringify(LWLR);
            
            var action = cmp.get("c.SaveLOLinesReceived");
            action.setParams({LWL:LWLI});
            action.setCallback(this, function(response) {
                var state = response.getState(); 
                if (state === "SUCCESS") {
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    if(response.getReturnValue().exceptionError == ''){
                        cmp.getAllRecieveDetails();
                    } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } 
            });
            $A.enqueueAction(action);   
        }
    }, 
    
    PutawaySelected : function(cmp, event, helper) {
        console.log('Inside PutawaySelected');
        var loglineId = '';
        try{
             loglineId = event.currentTarget.getAttribute('data-logisticlineId');
        } catch(err){ }
        var comWSR = cmp.get("v.Container");
        //if(comWSR.Putaway == false){
            var obj = comWSR.LOLIWrapperList;
            cmp.set("v.exceptionError","");
            var isSelected = false;
            var objSel = [];
            if(loglineId != ''){
                for(var x in obj){
                    obj[x].selected = false;
                    if(obj[x].LOLI.Id == loglineId){
                        obj[x].selected = true;
                    }
                }
            }
            for(var x in obj){
                if(obj[x].selected == true){
                    isSelected = true;
                    objSel.push(obj[x]);
                }
            }
            if(isSelected){
                comWSR.LOLIWrapperList = objSel;
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide"); 
                console.log('comWSR:',comWSR);
                setTimeout(
                    $A.getCallback(function() {
                        try{
                            //Changes Made by Akhtar
                            let comW = comWSR;
                            let LOLIWrapperList = comW.LOLIWrapperList;
                            let proceed = false;
                            for(let i=0; i< LOLIWrapperList.length; i++){
                                let counter = i;
                                let LOLI = LOLIWrapperList[i];
                                if(LOLI.selected) proceed = true;
                                if(LOLI.StockWrapperList.length==0 && LOLI.LOLI.ERP7__Quantity__c > 0 && LOLI.LOLI.ERP7__Quantity_Received__c > 0 && LOLI.LOLI.ERP7__Quantity_Received__c > LOLI.lineItemprocessedQuantity){
                                    if((LOLI.LOLI.ERP7__Product__r.ERP7__Is_Kit__c == true && LOLI.LOLI.ERP7__Explode__c == false) || LOLI.LOLI.ERP7__Product__r.ERP7__Is_Kit__c != true){
                                        counter = i;
                                        if(LOLI.LOLI.ERP7__Product__r.ERP7__Serialise__c){
                                            let N = parseInt(LOLI.LOLI.ERP7__Quantity_Received__c - LOLI.lineItemprocessedQuantity);
                                            for(let j=0; j<N; j++) { 
                                                counter = i; 
                                                LOLIWrapperList[counter] = helper.AddStock(cmp,LOLIWrapperList, counter)[counter];//.LOLIWrapperList[counter]; 
                                            }
                                        } else {
                                            LOLIWrapperList[counter] = helper.AddStock(cmp,LOLIWrapperList, counter)[counter];//.LOLIWrapperList[counter];
                                        }
                                    }  else if (LOLI.LOLI.Product__r.ERP7__Is_Kit__c == true && LOLI.LOLI.ERP7__Explode__c == true) {
                                        counter = i;
                                        comW.LOLIWrapperList = LOLIWrapperList;
                                        LOLIWrapperList[counter] = helper.ExplodeKit(cmp,comW, counter)[counter];//.LOLIWrapperList[counter];                                
                                    }
                                }
                            }
                            if(proceed) comW.Putaway = true;
                            else comW.Putaway = false;
                            
                            comW.LOLIWrapperList = LOLIWrapperList;
                            cmp.set("v.Container", comW);
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        }catch(e){console.log('Exception:',e);}
                    }), 100
                );
                
                
                
                
                
                /*Previous Code (It is not working when items are more than 500)
                comWSR.LOLIWrapperList = objSel;
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide"); 
                console.log('comWSR:',comWSR);
                var comWSI = JSON.stringify(comWSR);
                console.log('comWSI:',comWSI);
                var action = cmp.get("c.PutAway");
                action.setParams({comWS:comWSI});
                action.setCallback(this, function(response) {
                    var state = response.getState(); 
                    //alert(state);
                    if (state === "SUCCESS") {
                        console.log('res of PutawaySelected:',response.getReturnValue());
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        if(response.getReturnValue().exceptionError == ''){
                            cmp.set("v.Container", response.getReturnValue());
                            //cmp.set("v.Showbin", response.getReturnValue().showbinn);
                        }
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } 
                });
                $A.enqueueAction(action);*/
            } else cmp.set("v.exceptionError","Please select a line item to putaway.");
        //}
    }, 
    
    selectAll : function(cmp, event, helper) {
        var LOLI = cmp.get("v.Container.LOLIWrapperList");
        var val = cmp.get("v.checkAll");
        for(var x in LOLI){
            if(LOLI[x].LOLI.ERP7__Quantity_Received__c > LOLI[x].LOLI.ERP7__Putaway_Quantity__c)
            	LOLI[x].selected = val;
        }
        cmp.set("v.Container.LOLIWrapperList",LOLI);
    },
    
    PutawayAll : function(cmp, event, helper) {
        console.log('inside PutawayAll');
        var comWSR = cmp.get("v.Container");
        cmp.set("v.exceptionError","");
        var isSelected = true;
        var obj = comWSR.LOLIWrapperList;
        for(var x in obj){
            if(obj[x].LOLI.ERP7__Quantity_Received__c > obj[x].LOLI.ERP7__Putaway_Quantity__c) obj[x].selected = true;
        }
        
        if(isSelected){
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");  
            var comWSI = JSON.stringify(comWSR);
            console.log('comWSI:',comWSI);

            /*Previous code (It is not working when items are more than 500)
            var action = cmp.get("c.PutAway");
            action.setParams({comWS:comWSI});
            action.setCallback(this, function(response) {
                var state = response.getState(); 
                //alert(state);
                if (state === "SUCCESS") {
                    console.log('res of PutawayAll:',response.getReturnValue());
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    if(response.getReturnValue().exceptionError == ''){
                        cmp.set("v.Container", response.getReturnValue());
                        cmp.set("v.Showbin",response.getReturnValue().showbinn);
                    }
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                } 
            });
            $A.enqueueAction(action);  */ 

            try{
                //Changes Made by Akhtar
                let comW = comWSR;
                let LOLIWrapperList = comW.LOLIWrapperList;
                let proceed = false;
                for(let i=0; i< LOLIWrapperList.length; i++){
                    let counter = i;
                    let LOLI = LOLIWrapperList[i];
                    if(LOLI.selected) proceed = true;
                    if(LOLI.StockWrapperList.length==0 && LOLI.LOLI.ERP7__Quantity__c > 0 && LOLI.LOLI.ERP7__Quantity_Received__c > 0 && LOLI.LOLI.ERP7__Quantity_Received__c > LOLI.lineItemprocessedQuantity){
                        if((LOLI.LOLI.ERP7__Product__r.ERP7__Is_Kit__c == true && LOLI.LOLI.ERP7__Explode__c == false) || LOLI.LOLI.ERP7__Product__r.ERP7__Is_Kit__c != true){
                            counter = i;
                            if(LOLI.LOLI.ERP7__Product__r.ERP7__Serialise__c){
                                let N = parseInt(LOLI.LOLI.ERP7__Quantity_Received__c - LOLI.lineItemprocessedQuantity);
                                for(let j=0; j<N; j++) { 
                                    counter = i; 
                                    LOLIWrapperList[counter] = helper.AddStock(cmp,LOLIWrapperList, counter)[counter];//.LOLIWrapperList[counter]; 
                                }
                            } else {
                                LOLIWrapperList[counter] = helper.AddStock(cmp,LOLIWrapperList, counter)[counter];//.LOLIWrapperList[counter];
                            }
                        }  else if (LOLI.LOLI.Product__r.ERP7__Is_Kit__c == true && LOLI.LOLI.ERP7__Explode__c == true) {
                            counter = i;
                            comW.LOLIWrapperList = LOLIWrapperList;
                            LOLIWrapperList[counter] = helper.ExplodeKit(cmp,comW, counter)[counter];//.LOLIWrapperList[counter];                                
                        }
                    }
                }
                if(proceed) comW.Putaway = true;
                else comW.Putaway = false;
                
                comW.LOLIWrapperList = LOLIWrapperList;
                cmp.set("v.Container", comW);
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }catch(e){console.log('Exception:',e);}



            
        }
    },
    
    AddNewStock : function(cmp, event, helper) {
        var counter = event.currentTarget.getAttribute('data-counter');
        var subcounter = event.currentTarget.getAttribute('data-subcounter');
        var lastcounter = event.currentTarget.getAttribute('data-lastcounter');
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var LWLR = cmp.get("v.Container.LOLIWrapperList");
        var LWLI = JSON.stringify(LWLR);
        
        var action = cmp.get("c.AddStock");
        action.setParams({LWL:LWLI, counter:counter});
        action.setCallback(this, function(response) {
            var state = response.getState();  
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                if(response.getReturnValue().exceptionError == ''){
                    cmp.set("v.Container.LOLIWrapperList",response.getReturnValue().LOLIWrapperList);
                } 
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);   
    },
    
    RemoveTheStock : function(cmp, event, helper) { 
        var r = confirm('Are you sure you want to delete?'); 
        if (r == true) { 
            var counter = event.currentTarget.getAttribute('data-counter');
            var subcounter = event.currentTarget.getAttribute('data-subcounter');
            try{
                cmp.set("v.renderList",false);
                var LWLR = cmp.get("v.Container.LOLIWrapperList");
                var LWLI = JSON.stringify(LWLR);
                var SW = [];
                SW = LWLR[counter].StockWrapperList;
                var newSW = [];
                var stockId2Delete = '';
                var serialId2Delete = ''; 
                for(var i in SW){
                    if(i != subcounter) newSW.push(SW[i]); 
                    else{
                        if(SW[i].Stock != undefined && SW[i].Stock.Id != undefined) stockId2Delete = SW[i].Stock.Id; 
                        if(SW[i].SerialNumber != undefined && SW[i].SerialNumber.Id != undefined) serialId2Delete = SW[i].SerialNumber; 
                    } 
                }
                LWLR[counter].StockWrapperList = newSW;
                //cmp.set("v.Container.LOLIWrapperList",LWLR);
                //cmp.set("v.Container.LOLIWrapperList[counter].StockWrapperList",newSW);
                cmp.set("v.renderList",true);
            } catch(err) {
                //alert("Exception : "+err.message);
            }
            
            if(stockId2Delete != '' || serialId2Delete != ''){
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var action = cmp.get("c.DeleteStock");
                action.setParams({StockId:stockId2Delete, SerialId:stockId2Delete});
                action.setCallback(this, function(response) {
                    var state = response.getState(); 
                    //alert(state);
                    if (state === "SUCCESS") {
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    AddNewStockKit : function(cmp, event, helper) {
        var counter = event.currentTarget.getAttribute('data-counter');
        var subcounter = event.currentTarget.getAttribute('data-subcounter');
        var lastcounter = event.currentTarget.getAttribute('data-lastcounter');
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var LWLR = cmp.get("v.Container.LOLIWrapperList");
        var LWLI = JSON.stringify(LWLR);
        
        var action = cmp.get("c.AddStockKit");
        action.setParams({LWL:LWLI, counter:counter, subcounter:subcounter});
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            //alert(state);
            if (state === "SUCCESS") {
                //alert(response.getReturnValue().exceptionError);
                cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                if(response.getReturnValue().exceptionError == ''){
                    cmp.set("v.Container.LOLIWrapperList",response.getReturnValue().LOLIWrapperList);
                    //cmp.set("v.Container.LOLIWrapperList[counter].BOMS[subcounter].StockWrapperList",response.getReturnValue().LOLIWrapperList[counter].BOMS[subcounter].StockWrapperList);
                } 
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action); 
    },
    
    RemoveTheStockKit : function(cmp, event, helper) {
        var r = confirm('Are you sure you want to delete?'); 
        if (r == true) { 
            var counter = event.currentTarget.getAttribute('data-counter');
            var subcounter = event.currentTarget.getAttribute('data-subcounter');
            var lastcounter = event.currentTarget.getAttribute('data-lastcounter');
            try{
                cmp.set("v.renderList",false);
                var LWLR = cmp.get("v.Container.LOLIWrapperList");
                var LWLI = JSON.stringify(LWLR);
                var SW = [];
                SW = LWLR[lastcounter].BOMS[counter].StockWrapperList;
                var newSW = [];
                var stockId2Delete = '';
                var serialId2Delete = ''; 
                for(var i in SW){
                    if(i != subcounter) newSW.push(SW[i]); 
                    else{
                        if(SW[i].Stock != undefined && SW[i].Stock.Id != undefined) stockId2Delete = SW[i].Stock.Id; 
                        if(SW[i].SerialNumber != undefined && SW[i].SerialNumber.Id != undefined) serialId2Delete = SW[i].SerialNumber; 
                    } 
                }
                LWLR[lastcounter].BOMS[counter].StockWrapperList = newSW;
                //cmp.set("v.Container.LOLIWrapperList",LWLR);
                //cmp.set("v.Container.LOLIWrapperList[lastcounter].BOMS[counter].StockWrapperList",newSW);
                cmp.set("v.renderList",true);
            } catch(err) {
                //alert("Exception : "+err.message);
            }
            
            if(stockId2Delete != '' || serialId2Delete != ''){
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var action = cmp.get("c.DeleteStock");
                action.setParams({StockId:stockId2Delete, SerialId:stockId2Delete});
                action.setCallback(this, function(response) {
                    var state = response.getState(); 
                    //alert(state);
                    if (state === "SUCCESS") {
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    } else $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    SaveAllLOLines : function(cmp, event, helper) {
        var LWLR = cmp.get("v.Container.LOLIWrapperList");
        console.log('LWLR:',JSON.stringify(LWLR));
        for(var i in LWLR){
            if(LWLR[i].StockWrapperList.length == 0){
                cmp.set("v.exceptionError", LWLR[i].LOLI.ERP7__Product__r.Name+" : Item not found for creating inventory.");
                return;
            }
            if(LWLR[i].StockWrapperList[0].Stock.Name.length>80){
                cmp.set("v.exceptionError", LWLR[i].LOLI.ERP7__Product__r.Name+" : Name value too large");
                return;
            }
            if(cmp.get("v.putawayLocationReq")){
                if($A.util.isEmpty(LWLR[i].StockWrapperList[0].Stock.ERP7__Location__c) || $A.util.isUndefinedOrNull(LWLR[i].StockWrapperList[0].Stock.ERP7__Location__c)){
                    cmp.set("v.exceptionError", LWLR[i].LOLI.ERP7__Product__r.Name+" : Location not found.");
                    return;
                }
            }            
            if($A.util.isEmpty(LWLR[i].StockWrapperList[0].SPLI[0].ERP7__Quantity__c)){
                cmp.set("v.exceptionError", LWLR[i].LOLI.ERP7__Product__r.Name+" : Quantity can not be empty.");
                return;
            }
            
        }
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide"); 
        var LWLI = JSON.stringify(LWLR);
        var action = cmp.get("c.SaveLOLines"); 
        action.setParams({LWL:LWLI});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('err :',response.getReturnValue().exceptionError);
                cmp.set("v.Container.LOLIWrapperList", response.getReturnValue().LOLIWrapperList);
                cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                if(response.getReturnValue().exceptionError == ''){
                    cmp.Receive();
                } 
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
            }  else{
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                var errors = response.getError();
                console.log("server error in doInit : ", errors);
            } 
            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action); 
    }, 
    
    
    closeError : function (cmp, event) {
    	cmp.set("v.exceptionError",'');
    },
   /*  handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },*/
    
    createBatchModal : function(cmp,event,helper){
        cmp.set('v.BatchError','');
        var LOLId=event.currentTarget.getAttribute('data-index');
        cmp.set('v.currLOLIForBatch',LOLId);
        var prodId=event.currentTarget.getAttribute('data-prodId');
        cmp.set('v.newBatch.ERP7__Product__c',prodId);
        cmp.set('v.newBatch.ERP7__Shelf_Life_Expiration_Date__c','');
        var prodName=event.currentTarget.getAttribute('data-proName');
        cmp.set('v.proNameForBatch',prodName);
        var Container=cmp.get('v.Container');
        
        $A.util.addClass(cmp.find("myModalCard"),"slds-fade-in-open");
        $A.util.addClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
    },
    
    closeBatchModal : function(cmp,event,helper){
        $A.util.removeClass(cmp.find("myModalCard"),"slds-fade-in-open");
        $A.util.removeClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
        cmp.set('v.BatchError','');
        cmp.set('v.newBatch.ERP7__Product__c','');
        cmp.set('v.newBatch.ERP7__Production_Version__c','');
        cmp.set('v.newBatch.Name','');
        cmp.set('v.newBatch.ERP7__Barcode__c','');
        cmp.set('v.proNameForBatch','');
        cmp.set('v.currLOLIForBatch','');
    },

    updateBarcode : function(cmp,event,helper){
        var name=event.getSource().get("v.value");
        cmp.set('v.newBatch.ERP7__Barcode__c',name);
    },
    
    CreateBatch1: function(cmp,event,helper){
        cmp.set("v.exceptionError",'');
        var newBatch=cmp.get('v.newBatch');
        
        if($A.util.isUndefinedOrNull(newBatch.ERP7__Shelf_Life_Expiration_Date__c) || $A.util.isEmpty(newBatch.ERP7__Shelf_Life_Expiration_Date__c)){
            delete newBatch['ERP7__Shelf_Life_Expiration_Date__c'];
        }
        
        if(newBatch.Name.length > 80){
            cmp.set("v.exceptionError", 'Batch name too large.');
            return;
        }
        if(newBatch.Name==""){
            cmp.set("v.exceptionError", 'Please Enter Batch Name.');
            return;
        }
        if(newBatch.ERP7__Product__c==""){
            cmp.set("v.exceptionError", 'Please select the Product.');
            return;
        }
        
        var action=cmp.get('c.createBatch');
        action.setParams({newBatch1 : JSON.stringify(newBatch)});
        action.setCallback(this, function(response){
            if(response.getState() ==="SUCCESS"){
                cmp.set("v.exceptionError", response.getReturnValue().exError);
                if(response.getReturnValue().exError != '') return;
                var resBatch=response.getReturnValue().batch;
                delete resBatch['ERP7__Shelf_Life_Expiration_Date__c'];
                var LOLI = cmp.get("v.Container.LOLIWrapperList");
                for(var i in LOLI){
                    if(LOLI[i].LOLI.Id == cmp.get('v.currLOLIForBatch')){
                        //LOLI[i].StockWrapperList[0].BatchNumber=response.getReturnValue().batch;
                        LOLI[i].StockWrapperList[0].BatchNumber=resBatch;  
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type":"success",
                            "message": "Batch Created successfully."
                        });
                        toastEvent.fire();
                    }
                }
                cmp.set('v.Container.LOLIWrapperList',LOLI);
                $A.util.removeClass(cmp.find("myModalCard"),"slds-fade-in-open");
                $A.util.removeClass(cmp.find("myModalCardBackdrop"),"slds-backdrop_open");
                cmp.set('v.BatchError','');
                cmp.set('v.newBatch.ERP7__Product__c','');
                cmp.set('v.newBatch.ERP7__Production_Version__c','');
                cmp.set('v.newBatch.Name','');
                cmp.set('v.newBatch.ERP7__Barcode__c','');
            }else{
                var error=response.getError();
                console.log('Error:',error);
                cmp.set("v.exceptionError", error[0].message+' '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    
    
})