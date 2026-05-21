({
    getAllDetails : function(cmp, event, helper) {
        cmp.set('v.selectedTab','Inbound');
        console.log('InboundLogistics cmp');
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//1
        cmp.set("v.showSpinner",true);
        var logId = cmp.get("v.logisticId");   
        var show = cmp.get("v.show");  
        var accountId  = cmp.get("v.selectedAccount");
        console.log('accountId : ',accountId);
        var channel = '';
        if(!$A.util.isEmpty(cmp.get("v.currentEmployee.ERP7__Channel__c")) && !$A.util.isUndefinedOrNull(cmp.get("v.currentEmployee.ERP7__Channel__c"))){
            channel = cmp.get("v.currentEmployee.ERP7__Channel__c");
        }
        
        var site = '';
        if(!$A.util.isEmpty(cmp.get("v.selectedSite")) && !$A.util.isUndefinedOrNull(cmp.get("v.selectedSite"))){
            site = cmp.get("v.selectedSite");
        }
        var filtertype = cmp.get("v.filtertype");
        
        console.log('channel~>'+channel);
        console.log('site~>'+site);
        console.log('filtertype~>'+filtertype);
        
        var action = cmp.get("c.getAll");
        action.setParams({logisticId:logId, searchText:"", Channel:channel, Site:site, Offset:0, Show:show,filter:filtertype,accId : accountId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('Inbreceive getAllDetails resp success : ',response.getReturnValue());
                cmp.set("v.PreventChange", true);
                cmp.set("v.Container", response.getReturnValue());
                console.log('1');
                
                cmp.set("v.ShowAttachment",response.getReturnValue().showAttachment);
                cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                cmp.set("v.SiteOptions",response.getReturnValue().channelSites);
                cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                cmp.set('v.showBarcode',response.getReturnValue().showBarcodes);
                cmp.set('v.showInboundDescription',response.getReturnValue().showInboundDescription);
                cmp.set('v.enableQAforMO',response.getReturnValue().enableQAMO);
                
                cmp.set("v.PreventChange", false);
                cmp.set("v.logisticId",'');
                
                var alllogistics = response.getReturnValue().allLogs;
                let totalNonreceivedItems = 0;
                let totalpartialreceivedItems = 0;
                let totalFullreceivedItems = 0;
                console.log('alllogistics length~>'+alllogistics.length);
                for(var x in alllogistics){
                    if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c == 0 && alllogistics[x].ERP7__Closed__c == false){
                        totalNonreceivedItems =totalNonreceivedItems + 1;
                    }
                    else if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c > 0 && alllogistics[x].ERP7__Closed__c == false && alllogistics[x].ERP7__Total_Quantity__c > alllogistics[x].ERP7__Putaway_Quantity__c){
                        totalpartialreceivedItems = totalpartialreceivedItems +1; 
                    }
                        else if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c > 0 && alllogistics[x].ERP7__Total_Quantity__c == alllogistics[x].ERP7__Putaway_Quantity__c){
                            totalFullreceivedItems = totalFullreceivedItems + 1; 
                        }
                }
                console.log('totalNonreceivedItems~>'+totalNonreceivedItems);
                console.log('totalpartialreceivedItems~>'+totalpartialreceivedItems);
                console.log('totalFullreceivedItems~>'+totalFullreceivedItems);
                
                cmp.set('v.TotalNonReceivedItems',totalNonreceivedItems);
                cmp.set('v.TotalPartialReceivedItems',totalpartialreceivedItems);
                cmp.set('v.TotalFullReceivedItems',totalFullreceivedItems);
                console.log(response.getReturnValue().QALogCount);
                cmp.set('v.TotalQAItems',response.getReturnValue().QALogCount); 
                cmp.set('v.TotalQAItemsMO',response.getReturnValue().QAMOsCount); 
                
                //$A.util.addClass(cmp.find('mainSpin'), "slds-hide"); //2
                cmp.set("v.showSpinner",false);//uncomment
            }
        });
        $A.enqueueAction(action);
    },  
    
    LoadNow : function(cmp, event, helper) {
        //alert('out'); 
        window.scrollTo(0, 0);
        var logId = cmp.get("v.logisticId");
        var searchtext = cmp.get("v.searchText");
        var channel = cmp.get("v.currentEmployee.ERP7__Channel__c");
        var site = cmp.get("v.selectedSite");
        var show = cmp.get("v.show");
        var offset = cmp.get("v.Container.Offset");
        if(channel == undefined) { channel = ""; site = ""; }
        if(searchtext == undefined) searchtext = "";
        cmp.set("v.checkAll",false);
        var accountId  = cmp.get("v.selectedAccount");
        console.log('accountId LoadNow: ',accountId);
        var filterVal = cmp.get('v.filtertype');
       console.log('filterVal LoadNow: ',filterVal);
        if(!cmp.get("v.PreventChange") && channel != ""){
            //alert('in');
            //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//3
            cmp.set("v.showSpinner",true);
            var action = cmp.get("c.getAll");
            action.setParams({logisticId:logId, searchText:searchtext, Channel:channel, Site:site, Offset:offset, Show:show, filter:'', accId : accountId}); //added filterVal and accId on 17 jul,24 shaguftha M // removed filterVal on 19 jul,24 to apply the filter globally
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.PreventChange", true);
                    cmp.set("v.Container", response.getReturnValue());
                    
                    console.log('2');
                    cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                    //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                    cmp.set("v.SiteOptions",response.getReturnValue().channelSites);
                    cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    cmp.set("v.PreventChange", false);
                    cmp.set("v.logisticId",'');
                    
                    //alert(response.getReturnValue().LogisticWrapperList.length);
                    //Added by Imran
                    let totalNonreceivedItems = 0;
                    let totalpartialreceivedItems = 0;
                    let totalFullreceivedItems = 0;
                    
                    var alllogistics = response.getReturnValue().allLogs;
                    //var alllogistics = response.getReturnValue().LogisticWrapperList;
                    
                    for(var x in alllogistics){
                        if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c == 0 && alllogistics[x].ERP7__Closed__c == false){
                            totalNonreceivedItems =totalNonreceivedItems + 1;
                        }
                        else if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c > 0 && alllogistics[x].ERP7__Closed__c == false && alllogistics[x].ERP7__Total_Quantity__c > alllogistics[x].ERP7__Putaway_Quantity__c){
                            totalpartialreceivedItems = totalpartialreceivedItems +1; 
                        }
                        else if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c > 0 && alllogistics[x].ERP7__Total_Quantity__c == alllogistics[x].ERP7__Putaway_Quantity__c){
                            totalFullreceivedItems = totalFullreceivedItems + 1; 
                        }
                    }
                    /*
                    for(var x in response.getReturnValue().LogisticWrapperList){
                        if(alllogistics[x].Logistic.ERP7__Total_Quantity__c > 0 && alllogistics[x].Logistic.ERP7__Putaway_Quantity__c == 0 && alllogistics[x].Logistic.ERP7__Closed__c == false){
                            totalNonreceivedItems =totalNonreceivedItems + 1;
                        }
                        else if(alllogistics[x].Logistic.ERP7__Total_Quantity__c > 0 && alllogistics[x].Logistic.ERP7__Putaway_Quantity__c > 0 && alllogistics[x].Logistic.ERP7__Closed__c == false && alllogistics[x].Logistic.ERP7__Total_Quantity__c > alllogistics[x].Logistic.ERP7__Putaway_Quantity__c){
                            totalpartialreceivedItems = totalpartialreceivedItems +1; 
                        }
                        else if(alllogistics[x].Logistic.ERP7__Total_Quantity__c > 0 && alllogistics[x].Logistic.ERP7__Putaway_Quantity__c > 0 && alllogistics[x].Logistic.ERP7__Total_Quantity__c == alllogistics[x].Logistic.ERP7__Putaway_Quantity__c){
                            totalFullreceivedItems = totalFullreceivedItems + 1; 
                        }
                    }
                    */
                    console.log('totalNonreceivedItems~>'+totalNonreceivedItems);
                    console.log('totalpartialreceivedItems~>'+totalpartialreceivedItems);
                    console.log('totalFullreceivedItems~>'+totalFullreceivedItems);
                    
                    cmp.set('v.TotalNonReceivedItems',totalNonreceivedItems);
                    cmp.set('v.TotalPartialReceivedItems',totalpartialreceivedItems);
                    cmp.set('v.TotalFullReceivedItems',totalFullreceivedItems);
                    //alert(response.getReturnValue().QALogCount);
                    cmp.set('v.TotalQAItems',response.getReturnValue().QALogCount); 
                     cmp.set('v.TotalQAItemsMO',response.getReturnValue().QAMOsCount); 
                    //added by imran    
                    //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//4
                    cmp.set("v.showSpinner",false);
                }
            });
            $A.enqueueAction(action);
        }
    }, 
    
    SetShow : function(cmp, event, helper) {
        cmp.set("v.Container.Offset",0);
        cmp.LoadNow();
    },
    
    OfsetChange : function(cmp, event, helper) {
        var container = cmp.get("v.Container");
        var PNS = container.PNS;
        var PageNum = container.PageNum;
        var Offset = parseInt(container.Offset);
        var show = parseInt(cmp.get("v.show"));
        
        if(PageNum > 0 && PageNum <= PNS.length){
            if(((Offset+show)/show) != PageNum){
                Offset = (show*PageNum)-show;
                cmp.set("v.Container.Offset",Offset);
            }
            cmp.LoadNow();
        } else cmp.set("v.Container.PageNum",(Offset+show)/show);
    },
    
    Next : function(cmp, event, helper) {
        var container = cmp.get("v.Container");
        var show = parseInt(cmp.get("v.show"));
        var Offset = parseInt(container.Offset);
        var endCount = parseInt(container.endCount);
        var recSize = parseInt(container.recSize);
        
        if(endCount != recSize){
            var newOffset = Offset+show
            cmp.set("v.Container.Offset",Offset+show);
            cmp.LoadNow();
        }
    },
    
    NextLast : function(cmp, event, helper) {
        var container = cmp.get("v.Container");
        var PNS = container.PNS;
        var show = parseInt(cmp.get("v.show"));
        var endCount = parseInt(container.endCount);
        var recSize = parseInt(container.recSize);
        if(endCount != recSize){
            cmp.set("v.Container.Offset",((PNS.length-1)*show));
            cmp.LoadNow();
        }
    },
    
    Previous : function(cmp, event, helper) {
        var container = cmp.get("v.Container");
        var Offset = parseInt(container.Offset);
        var show = parseInt(cmp.get("v.show"));
        var startCount = parseInt(container.startCount);
        if(startCount > 1){
            cmp.set("v.Container.Offset",Offset-show);
            cmp.LoadNow();
        }
    },
    
    PreviousFirst : function(cmp, event, helper) {
        var container = cmp.get("v.Container");
        var startCount = parseInt(container.startCount);
        if(startCount > 1){
            cmp.set("v.Container.Offset",0);
            cmp.LoadNow();
        }
    },
    
    Load : function(cmp, event, helper) {
        if(!cmp.get("v.PreventChange")){
            cmp.set("v.Container.Offset",0);
            //Deselect all tabs here for Search Button Action
            var cmpTarget = cmp.find('NonReceivedItems');
            $A.util.removeClass(cmpTarget, 'active-receive-grey');
            var cmpTarget = cmp.find('FullReceivedItems');
            $A.util.removeClass(cmpTarget, 'active-receive-green');
            var cmpTarget = cmp.find('PartialReceivedItems');
            $A.util.removeClass(cmpTarget, 'active-receive-orange');
            var cmpTarget = cmp.find('AwaitingQualityCheck');
            $A.util.removeClass(cmpTarget, 'active-receive-purple');
            
            cmp.LoadNow();
        }
    },
    
    LoadChannelChange : function(cmp, event, helper) {
        if(!cmp.get("v.PreventChange")){
            cmp.set("v.Container.Offset",0);
            //alert('out');
            window.scrollTo(0, 0);
            var logId = cmp.get("v.logisticId");
            var searchtext = cmp.get("v.searchText");
            var channel = cmp.get("v.currentEmployee.ERP7__Channel__c");
            var site = cmp.get("v.selectedSite");
            var show = cmp.get("v.show");
            var offset = cmp.get("v.Container.Offset");
            site = "";
            if(channel == undefined) { channel = ""; site = ""; }
            if(searchtext == undefined) searchtext = "";
            cmp.set("v.checkAll",false);
            //alert('offset : '+offset);
            //alert('show : '+show);
            if(!cmp.get("v.PreventChange") && channel != ""){
                //alert('in');
                //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//5
                cmp.set("v.showSpinner",true);
                var action = cmp.get("c.getAll");
                action.setParams({logisticId:logId, searchText:searchtext, Channel:channel, Site:site, Offset:offset, Show:show,accId : cmp.get('v.selectedAccount')});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        //alert(response.getReturnValue().selectedSite);
                        cmp.set("v.PreventChange", true);
                        cmp.set("v.Container", response.getReturnValue());
                        
                        console.log('3');
                        cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                        //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                        cmp.set("v.SiteOptions",response.getReturnValue().channelSites);
                        cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        cmp.set("v.PreventChange", false);
                        cmp.set("v.logisticId",'');
                        
                        //Added by Imran
                        var alllogistics = response.getReturnValue().allLogs;
                        let totalNonreceivedItems = 0;
                        let totalpartialreceivedItems = 0;
                        let totalFullreceivedItems = 0;
                        console.log('alllogistics length~>'+alllogistics.length);
                        for(var x in alllogistics){
                            if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c == 0 && alllogistics[x].ERP7__Closed__c == false){
                                totalNonreceivedItems =totalNonreceivedItems + 1;
                            }
                            else if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c > 0 && alllogistics[x].ERP7__Closed__c == false && alllogistics[x].ERP7__Total_Quantity__c > alllogistics[x].ERP7__Putaway_Quantity__c){
                                totalpartialreceivedItems = totalpartialreceivedItems +1; 
                            }
                            else if(alllogistics[x].ERP7__Total_Quantity__c > 0 && alllogistics[x].ERP7__Putaway_Quantity__c > 0 && alllogistics[x].ERP7__Total_Quantity__c == alllogistics[x].ERP7__Putaway_Quantity__c){
                                totalFullreceivedItems = totalFullreceivedItems + 1; 
                            }
                        }
                        console.log('totalNonreceivedItems~>'+totalNonreceivedItems);
                        console.log('totalpartialreceivedItems~>'+totalpartialreceivedItems);
                        console.log('totalFullreceivedItems~>'+totalFullreceivedItems);
                        
                        cmp.set('v.TotalNonReceivedItems',totalNonreceivedItems);
                        cmp.set('v.TotalPartialReceivedItems',totalpartialreceivedItems);
                        cmp.set('v.TotalFullReceivedItems',totalFullreceivedItems);
                        console.log(response.getReturnValue().QALogCount);
                        cmp.set('v.TotalQAItems',response.getReturnValue().QALogCount);  
                        //added by imran    
                        
                        //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//6
                        cmp.set("v.showSpinner",false);
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    LoadAccountChange : function (component, event) {
        var accId = component.get('v.selectedAccount');
        console.log('accId : ',accId);
        if(accId != null && accId != '' && accId != undefined){
            component.getAllDetails();
        }
        else component.LoadNow();
    },
    
    NavRecord : function (component, event) {
        var RecId = event.getSource().get("v.title");
        var RecUrl = "/" + RecId;
        window.open(RecUrl,'_blank');
    },
    
    Reload : function (component, event) {
        window.location.reload();
    },
    
    checkAll : function(cmp, event, helper) {
        if(cmp.get('v.filtertype') == 'QualityCheckMO'){
          var obj = cmp.get("v.Container.MOWrapperList");
            var val = cmp.get("v.checkAll");
            for(var x in obj){
                obj[x].isSelected = val;
            }
            cmp.set("v.Container.MOWrapperList",obj);  
        }
        else{
            var obj = cmp.get("v.Container.LogisticWrapperList");
            var val = cmp.get("v.checkAll");
            for(var x in obj){
                obj[x].isSelected = val;
            }
            cmp.set("v.Container.LogisticWrapperList",obj);
        }
        
    },
    
    Back2Inbound : function(cmp, event, helper) {
        $A.createComponent("c:InboundReceiveLogistics",{
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    Receive : function(cmp, event, helper) {
        console.log('filter Type : ',cmp.get('v.filtertype'));
        if(cmp.get('v.filtertype') == 'QualityCheckMO'){
            var receiveClickedMOAction = cmp.get('c.ReceiveClickedMO');
            $A.enqueueAction(receiveClickedMOAction);
        }
        else{
            var logId = ''; 
            var vendorId = ''; 
            try{
                logId = event.currentTarget.getAttribute('data-logisticId');
            } catch(err){ }
            
            if(logId == undefined || logId == '' || logId == 'null' || logId == null){
                var Logs = cmp.get("v.Container.LogisticWrapperList");
                for(var x in Logs){
                    if(Logs[x].isSelected == true) {
                        console.log('Logs[x] : ',JSON.stringify(Logs[x]));
                        if(vendorId == '' || vendorId == null || vendorId == undefined) vendorId = Logs[x].Logistic.ERP7__Account__c;
                        if(logId == undefined || logId == '' || logId == 'null' || logId == null) logId = Logs[x].Logistic.Id;
                        else logId = logId+','+Logs[x].Logistic.Id;
                    }
                }
            }
            
            if(logId == '' || logId == 'null' || logId == null) cmp.set("v.exceptionError", $A.get('$Label.c.Please_select_an_order_to_proceed_to_receive'));   
            else{
                if(vendorId == '' || vendorId == null || vendorId == undefined) {
                    var Logs = cmp.get("v.Container.LogisticWrapperList");
                    for(var x in Logs){
                        if(Logs[x].Logistic.Id == logId){
                            vendorId = Logs[x].Logistic.ERP7__Account__c; 
                        }
                    }
                }
                console.log('vendorId : ',vendorId);
                $A.createComponent("c:ReceiveInbound",{
                    "logisticIds":logId,
                    "vendId" : vendorId
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") {
                        var body = cmp.find("body");
                        body.set("v.body", newCmp);
                    }
                }); 
                cmp.set('v.selectedTab','Receive');
            }
            
        }
        
    },
    ReceiveClickedMO : function(cmp, event, helper) {
        console.log('method called');
         var moId = ''; 
        try{
            moId = event.currentTarget.getAttribute('data-logisticId');
        } catch(err){ }
        if(moId == undefined || moId == '' || moId == 'null' || moId == null){
            var MOs = cmp.get("v.Container.MOWrapperList");
            for(var x in MOs){
                if(MOs[x].isSelected == true) {
                    console.log('MOs[x] : ',JSON.stringify(MOs[x]));
                    if(moId == undefined || moId == '' || moId == 'null' || moId == null) moId = MOs[x].MOrders.Id;
                    else moId = moId+','+MOs[x].MOrders.Id;
                }
            }
        }
         if(moId == '' || moId == 'null' || moId == null) cmp.set("v.exceptionError", $A.get('$Label.c.Please_select_an_order_to_proceed_to_receive'));   
        else{
            $A.createComponent("c:ReceiveInbound",{
                "MOIds":moId
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = cmp.find("body");
                    body.set("v.body", newCmp);
                }
            }); 
            cmp.set('v.selectedTab','Receive');
        }
        
    },
    
    
    focusTOscan : function (component, event,helper) {
        console.log('Inside focusTOscan');
         /*var scanedfield = component.get("v.scanValue");
        console.log('focusTOscan scanedfield Inbound: ',scanedfield);
        var editedFieldId = event.getSource().getLocalId();
        console.log('focusTOscan editedFieldId Inbound: ',editedFieldId);
        if(editedFieldId == scanedfield){*/ 
       // }by asra as it was not working 21/5/24
       component.set("v.scanValue",'');
       helper.focusTOscan(component, event);  
    },
    
    verifyScanCode : function (cmp, event, helper) {
       var tabselected =  cmp.get('v.selectedTab');
        if(tabselected != 'Receive'){
            console.log('Inside verifyScanCode');
            var scan_Code = cmp.get("v.scanValue");
            var mybarcode = scan_Code;
            console.log('InbRec mybarcode~>'+mybarcode);
            if(mybarcode != ''){
                cmp.set("v.exceptionError", '');
                //alert(mybarcode); 
                if(mybarcode == 'ORDER') { cmp.Back2Inbound(); }
                else if(mybarcode == 'RECEIVE') { cmp.Receive(); }
                    else if(mybarcode == 'PUTAWAY') { cmp.Receive(); }
                        else{  
                            cmp.set("v.logisticId",mybarcode);
                            console.log('barcode scanned getAllDetails calling ');
                            cmp.getAllDetails();
                        }  
                cmp.set("v.scanValue",'');
            }
        }
        
    },
    
    DeleteRecordAT: function(component, event) {
        var result = confirm("Are you sure?");
        console.log('result : ',result);
        var RecordId = event.getSource().get("v.name");
        console.log('RecordId : ',RecordId);
        var parentId = event.getSource().get("v.title");
        console.log('parentId : ',parentId);
        if (result) {
            //window.scrollTo(0, 0);
            //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            try{
                var action = component.get("c.DeleteAttachFromInboundList");
                action.setParams({
                    attachId: RecordId,
                    parentId: parentId,
                });
                action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log("DeleteRecordAT resp: ", JSON.stringify(response.getReturnValue()));
                    if(component.get('v.enableQAforMO') && component.get('v.filtertype') == 'QualityCheckMO'){
                        var obj1 = component.get("v.Container.MOWrapperList");
                        for(var x in obj1){
                            if(obj1[x].MOrders.Id == parentId){
                                obj1[x].Attachments = response.getReturnValue();
                                break;
                            }
                        }
                        component.set("v.Container.MOWrapperList",obj1);
                    }
                    else{
                        var obj = component.get("v.Container.LogisticWrapperList");
                        for(var x in obj){
                            if(obj[x].Logistic.Id == parentId){
                                obj[x].Attachments = response.getReturnValue();
                                break;
                            }
                        }
                        component.set("v.Container.LogisticWrapperList",obj);
                    }
                   
                    
                   // $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }
                else{
                   // $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    var errors = response.getError();
                    console.log("server error in doInit : ", JSON.stringify(errors));
                    component.set("v.exceptionError", errors[0].message);
                }
            });
                $A.enqueueAction(action);
            }
            catch(err) {
                console.log('Exception : ',err);
            }
        } 
    },
    
    //method changed for multiple files upload arshad 30/03/23
    onFileUploaded : function(cmp, event, helper) {
        //$A.util.removeClass(cmp.find('mainSpin'), "slds-hide");//7
        cmp.set("v.showSpinner",true);
        try{
            let files = cmp.get("v.FileList");  
             var totalRequestSize = 0;
            for (let i = 0; i < files[0].length; i++) {
                let file = files[0][i];
               
    // Validate individual file size (max 2 MB) before processing
    if (file.size > 2000000) {
        helper.showToast("Error", "error", "File " + file.name + " exceeds the 2 MB limit.");
        cmp.set("v.showSpinner", false);
        return; // Skip processing for this file
    }
             totalRequestSize += file.size;
console.log("totalRequestSize",totalRequestSize);
            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                cmp.set("v.showSpinner", false);
                return;
            }}
console.log('FileList : ', JSON.stringify(FileList));
            let fileNameList = [];
            let base64DataList = [];
            let contentTypeList = [];
            
            if (files && files.length > 0) {
                let parentId = event.getSource().get("v.name");
                console.log('files : ',files.length);
                console.log('files[0] : ',files[0].length);
                if(files[0].length > 0){
                    for (let i = 0; i < files[0].length; i++) {
                         var totalRequestSize = 0;

       /* for ( i = 0; i < files.length; i++) {
            var fileSize = files[i][0].size;

            if (fileSize > 2000000) {
                helper.showToast('Error', 'error', 'File ' + files[i][0].name + ' exceeds the 2 MB limit.');
                return;
            }

            totalRequestSize += fileSize;

            if (totalRequestSize > 6000000) {
                helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                return;
            }
        }*/
                        console.log('i~>'+i);
                        let file = files[0][i];
                        let reader = new FileReader();
                        //reader.onloadend is asynchronous using let instead of var inside for loop arshad 
                        reader.onloadend = function() {
                            
                            console.log('inside reader.onloadend');
                            let contents = reader.result;
                            let base64Mark = 'base64,';
                            let dataStart = contents.indexOf(base64Mark) + base64Mark.length;
                            let fileContents = contents.substring(dataStart);
                           
                            
                            fileNameList.push(file.name);
                            base64DataList.push(encodeURIComponent(fileContents));
                            contentTypeList.push(file.type);

                            
                            console.log('fileNameList~>'+fileNameList.length);
                            console.log('base64DataList~>'+base64DataList.length);
                            console.log('contentTypeList~>'+contentTypeList.length);
                            
                            if(fileNameList.length == files[0].length){
                            helper.finishAllFilesUpload(parentId,fileNameList,base64DataList,contentTypeList,cmp,event,helper);
                            }else console.log('notequal');
                        }
                        reader.onerror = function() {
                            console.log('for i~>'+i+' err~>'+reader.error);
                            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//8
                            cmp.set("v.showSpinner",false);
                        };
                        reader.readAsDataURL(file);
                    }
                }
            }
        }catch(err){
            console.log("Error catch:",err);
            //$A.util.addClass(cmp.find('mainSpin'), "slds-hide");//9
            cmp.set("v.showSpinner",false);
        }
        
    },
    
    reRender : function(cmp, event, helper) { },
    
    closeError : function (cmp, event) {
        cmp.set("v.exceptionError",'');
    },
    
    imageError: function(component,event,helper){
        console.log('imageError called');
        event.target.style.display = 'none';
    },   
    
    getSortedRecords : function(component,event,helper){
        console.log('getSortedRecords clled');
        component.set("v.OrderBy",event.currentTarget.id); 
        console.log('event.currentTarget.id : ',event.currentTarget.id);
        // component.set("v.Order",event.currentTarget.dataset.service); 
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');   
        console.log('component.get(v.Order) : ',component.get("v.Order"));
        helper.getLogisticRecords(component,event); 
    },
    
    showNonReceivedItems : function(component,event,helper){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//10
        component.set("v.showSpinner",true);
        var cmpTarget = component.find('NonReceivedItems');
        $A.util.addClass(cmpTarget, 'active-receive-grey');
        var cmpTarget = component.find('FullReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-green');
        var cmpTarget = component.find('PartialReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-orange');
        var cmpTarget = component.find('AwaitingQualityCheck');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
        var cmpTarget = component.find('QualityCheckMO');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
        let filter = event.target.dataset.record;
        console.log('filter : ',filter);
        component.set('v.filtertype',filter);
        var a = component.get('c.getAllDetails');
        $A.enqueueAction(a);
        
        //$A.enqueueAction(component.get('c.getAllDetails');
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");//11
        component.set("v.showSpinner",false);
        /* component.set('v.showAllLogs',false); 
         component.set('v.shownonReceivedLogs',true ); 
         component.set('v.showpartialLogs',false); 
         component.set('v.showfullLogs',false); */
    },
    
    showPartialReceivedItems : function(component,event,helper){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//12
        component.set("v.showSpinner",true);
        var cmpTarget = component.find('NonReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-grey');
        var cmpTarget = component.find('FullReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-green');
        var cmpTarget = component.find('PartialReceivedItems');
        $A.util.addClass(cmpTarget, 'active-receive-orange');
        var cmpTarget = component.find('AwaitingQualityCheck');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
         var cmpTarget = component.find('QualityCheckMO');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
        let filter = event.target.dataset.record;
        console.log('filter : ',filter);
        component.set('v.filtertype',filter);
        var a = component.get('c.getAllDetails');
        $A.enqueueAction(a);
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");//13
        component.set("v.showSpinner",false);
    },
    
    showFullReceivedItems : function(component,event,helper){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//14
        component.set("v.showSpinner",true);
        var cmpTarget = component.find('NonReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-grey');
        var cmpTarget = component.find('FullReceivedItems');
        $A.util.addClass(cmpTarget, 'active-receive-green');
        var cmpTarget = component.find('PartialReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-orange');
        var cmpTarget = component.find('AwaitingQualityCheck');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
         var cmpTarget = component.find('QualityCheckMO');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
        let filter = event.target.dataset.record;
        console.log('filter : ',filter);
        component.set('v.filtertype',filter);
        var a = component.get('c.getAllDetails');
        $A.enqueueAction(a);
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");//15
        component.set("v.showSpinner",false);
        
        
    },
    
    showFullReceivedItems : function(component,event,helper){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//16
        component.set("v.showSpinner",true);
        var cmpTarget = component.find('NonReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-grey');
        var cmpTarget = component.find('FullReceivedItems');
        $A.util.addClass(cmpTarget, 'active-receive-green');
        var cmpTarget = component.find('PartialReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-orange');
        var cmpTarget = component.find('AwaitingQualityCheck');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
         var cmpTarget = component.find('QualityCheckMO');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
        let filter = event.target.dataset.record;
        console.log('filter : ',filter);
        component.set('v.filtertype',filter);
        var a = component.get('c.getAllDetails');
        $A.enqueueAction(a);
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");//17
        component.set("v.showSpinner",false);
    },
    
    
    showAwaitingQAItems : function(component,event,helper){
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//18
        component.set("v.showSpinner",true);
        var cmpTarget = component.find('NonReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-grey');
        var cmpTarget = component.find('FullReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-green');
        var cmpTarget = component.find('PartialReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-orange'); 
        var cmpTarget = component.find('AwaitingQualityCheck');
        $A.util.addClass(cmpTarget, 'active-receive-purple');
         var cmpTarget = component.find('QualityCheckMO');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
        let filter = event.target.dataset.record;
        console.log('filter : ',filter);
        component.set('v.filtertype',filter);
        var a = component.get('c.getAllDetails');
        $A.enqueueAction(a);
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");//19
        component.set("v.showSpinner",false);
    },
    showQAItemsMO : function(component,event,helper){
        console.log('showQAItemsMO called');
        component.set("v.showSpinner",true);
        var cmpTarget = component.find('NonReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-grey');
        var cmpTarget = component.find('FullReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-green');
        var cmpTarget = component.find('PartialReceivedItems');
        $A.util.removeClass(cmpTarget, 'active-receive-orange'); 
        var cmpTarget = component.find('AwaitingQualityCheck');
        $A.util.removeClass(cmpTarget, 'active-receive-purple');
        var cmpTarget = component.find('QualityCheckMO');
        $A.util.addClass(cmpTarget, 'active-receive-purple');
        let filter = event.target.dataset.record;
        console.log('filter : ',filter);
        component.set('v.filtertype',filter);
        helper.getQAMOs(component,event,helper);
        component.set("v.showSpinner",false);
    },
    handleTextKeyUp : function(component,event,helper){
        console.log('arshad handleTextKeyUp called');
        try{
            var textvalue = event.currentTarget.getAttribute('data-name');
            var LogId = event.currentTarget.getAttribute('data-id');
            if(!$A.util.isEmpty(textvalue) && !$A.util.isUndefinedOrNull(textvalue) && !$A.util.isEmpty(LogId) && !$A.util.isUndefinedOrNull(LogId)){
                if (event.which === 13 || event.keyCode === 13) {
                    console.log('textvalue~>'+textvalue.length);
                    console.log('LogId~>'+LogId);
                    if(textvalue.length > 0){
                        console.log('arshad in here');
                        var action = component.get("c.saveLogisticDescription");
                        action.setParams({
                            "LogId": LogId,
                            "textvalue": textvalue,
                        });
                        action.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                console.log("arshadhandleTextKeyUp resp: ", JSON.stringify(response.getReturnValue()));
                            }else{
                                var errors = response.getError();
                                console.log("arshad error in handleTextKeyUp : ", JSON.stringify(errors));
                            } 
                        });
                        $A.enqueueAction(action);
                    }
                }
            }
        }catch(e){
            console.log('arshad handleTextKeyUp err~>'+e);
        }
    },    
})