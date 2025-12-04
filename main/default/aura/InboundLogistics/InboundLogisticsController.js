({
    getAllDetails : function(cmp, event, helper) {
        console.log('InboundLogistics cmp');
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var logId = cmp.get("v.logisticId");   
        var show = cmp.get("v.show");  
        var action = cmp.get("c.getAll");
        action.setParams({logisticId:logId, searchText:"", Channel:"", Site:"", Offset:0, Show:show});
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            //alert(state);  
            if (state === "SUCCESS") {
                cmp.set("v.PreventChange", true);
                cmp.set("v.Container", response.getReturnValue());
                cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                cmp.set("v.SiteOptions",response.getReturnValue().channelSites);
                cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                cmp.set("v.PreventChange", false);
                //cmp.set("v.SyncSalesforce", response.getReturnValue().SalesFile);
                cmp.set("v.isGDrive", response.getReturnValue().DriveFile);
                // cmp.set("v.SyncGDrive", response.getReturnValue().DriveFile);
                cmp.set("v.logisticId",'');
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
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
        
        if(!cmp.get("v.PreventChange") && channel != ""){
            //alert('in');
            $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
            var action = cmp.get("c.getAll");
            action.setParams({logisticId:logId, searchText:searchtext, Channel:channel, Site:site, Offset:offset, Show:show});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.PreventChange", true);
                    cmp.set("v.Container", response.getReturnValue());
                    cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                    //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                    cmp.set("v.SiteOptions",response.getReturnValue().channelSites);
                    cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                    cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                    cmp.set("v.PreventChange", false);
                    cmp.set("v.logisticId",'');
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
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
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                var action = cmp.get("c.getAll");
                action.setParams({logisticId:logId, searchText:searchtext, Channel:channel, Site:site, Offset:offset, Show:show});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        //alert(response.getReturnValue().selectedSite);
                        cmp.set("v.PreventChange", true);
                        cmp.set("v.Container", response.getReturnValue());
                        cmp.set("v.currentEmployee", response.getReturnValue().Employee);
                        //cmp.find("Site").set("v.options", response.getReturnValue().channelSites);
                        cmp.set("v.SiteOptions",response.getReturnValue().channelSites);
                        cmp.set("v.selectedSite", response.getReturnValue().selectedSite);
                        cmp.set("v.exceptionError", response.getReturnValue().exceptionError);
                        cmp.set("v.PreventChange", false);
                        cmp.set("v.logisticId",'');
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                });
                $A.enqueueAction(action);
            }
        }
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
        var obj = cmp.get("v.Container.LogisticWrapperList");
        var val = cmp.get("v.checkAll");
        for(var x in obj){
            obj[x].isSelected = val;
        }
        cmp.set("v.Container.LogisticWrapperList",obj);
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
        var logId = '';
        try{
            logId = event.currentTarget.getAttribute('data-logisticId');
        } catch(err){ }
        
        if(logId == undefined || logId == '' || logId == 'null' || logId == null){
            var Logs = cmp.get("v.Container.LogisticWrapperList");
            for(var x in Logs){
                if(Logs[x].isSelected == true) {
                    if(logId == undefined || logId == '' || logId == 'null' || logId == null) logId = Logs[x].Logistic.Id;
                    else logId = logId+','+Logs[x].Logistic.Id;
                }
            }
        }
        if(logId == '' || logId == 'null' || logId == null) cmp.set("v.exceptionError", $A.get('$Label.c.Please_select_an_order_to_proceed_to_receive'));   
        else{
            //var RecUrl = "/apex/ReceiveLC?core.apexpages.devmode.url=1&loId=" + logId;
            //window.open(RecUrl,'_self');
            $A.createComponent("c:Receive",{
                "logisticIds":logId
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = cmp.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        
    },
    
    Putaway : function(cmp, event, helper) {
        var logId = '';
        try{
            logId = event.currentTarget.getAttribute('data-logisticId');
        } catch(err){ }
        
        if(logId == undefined || logId == '' || logId == 'null' || logId == null){
            var Logs = cmp.get("v.Container.LogisticWrapperList");
            for(var x in Logs){
                if(Logs[x].isSelected == true) {
                    if(logId == undefined || logId == '' || logId == 'null' || logId == null) logId = Logs[x].Logistic.Id;
                    else logId = logId+','+Logs[x].Logistic.Id;
                }
            }
        }
        if(logId == '' || logId == 'null' || logId == null) cmp.set("v.exceptionError", $A.get('$Label.c.Please_select_an_order_to_proceed_to_putaway'));   
        else{
            //var RecUrl = "/apex/ReceiveLC?core.apexpages.devmode.url=1&loId=" + logId;
            //window.open(RecUrl,'_self');
            $A.createComponent("c:Receive",{
                "logisticIds":logId,
                "Putaway":true
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = cmp.find("body");
                    body.set("v.body", newCmp);
                }
            });
        }
        
    },
    
    focusTOscan : function (component, event,helper) {
        console.log('focusTOscan called');
        component.set("v.scanValue",'');
        helper.focusTOscan(component, event);  
    },
    
    verifyScanCode : function (cmp, event, helper) {
        console.log('verifyScanCode called');
        var scan_Code = cmp.get("v.scanValue");
        var mybarcode = scan_Code;
        if(mybarcode != ''){
            cmp.set("v.exceptionError", '');
            //alert(mybarcode); 
            if(mybarcode == 'ORDER') { cmp.Back2Inbound(); }
            else if(mybarcode == 'RECEIVE') { cmp.Receive(); }
                else if(mybarcode == 'PUTAWAY') { cmp.Putaway(); }
                    else{  
                        cmp.set("v.logisticId",mybarcode); 
                        cmp.getAllDetails();
                    }  
            cmp.set("v.scanValue",'');
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
                            var obj = cmp.get("v.Container.LogisticWrapperList");
                            for(var x in obj){
                                if(obj[x].Attach.Id == RecordId){
                                    parentId = obj[x].Logistic.Id;
                                    obj[x].Attach = response.getReturnValue().universalAttachment;
                                    break;
                                }
                                if(obj[x].conAttach.ContentDocumentId == RecordId){
                                    parentId = obj[x].Logistic.Id;
                                    obj[x].conAttach = response.getReturnValue().uniContentVersion;
                                    break;
                                }
                            }
                            cmp.set("v.Container.LogisticWrapperList",obj);
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
    
    handleCheckSalesforce : function(component, event, helper) {
        var parentId = event.getSource().get("v.name");  
        var Logs = component.get("v.Container.LogisticWrapperList");
        var Sales, GDrives;
        for(var x in Logs){
            if(Logs[x].Logistic.Id == parentId) {
                Sales = Logs[x].isSales;
                GDrives = Logs[x].isGDrive;
                if(Sales == false && GDrives == false) { Logs[x].showUpload = true; }else{ Logs[x].showUpload = false; }
            }
        }
        component.set("v.Container.LogisticWrapperList",Logs);
    },
    
    handleCheckGDrive : function(component, event, helper) {
        var parentId = event.getSource().get("v.name");  
        var Logs = component.get("v.Container.LogisticWrapperList");
        var Sales, GDrives;
        for(var x in Logs){
            if(Logs[x].Logistic.Id == parentId) {
                Sales = Logs[x].isSales;
                GDrives = Logs[x].isGDrive;
                if(Sales == false && GDrives == false) { Logs[x].showUpload = true; }else{ Logs[x].showUpload = false; }
            }
        }
        component.set("v.Container.LogisticWrapperList",Logs);
    },   
    
    uploadFile: function(component, event, helper) {        
        try{
            var uploadedFiles = event.getParam("files");
            var totalRequestSize = 0;
            
            for (var i = 0; i < uploadedFiles.length; i++) {
                var fileSize = uploadedFiles[i].size;
                console.log('fileSize : ', fileSize);
            
                if (fileSize > 2000000) { // 2 MB limit
                    helper.showToast('Error', 'error', 'File ' + filesDataToUpload[i].fileName + ' exceeds the 2 MB limit.');
                    return;
                }
            
                totalRequestSize += fileSize;
                console.log('totalRequestSize : ', totalRequestSize);
            
                if (totalRequestSize > 6000000) { // 6 MB total request size limit
                    helper.showToast('Error', 'error', 'Total request size exceeds the 6 MB limit. Please upload fewer or smaller files.');
                    return;
                }
            }
            
            for(var i in uploadedFiles)
                if(uploadedFiles[i].documentId !='')
                    FileIds.push(uploadedFiles[i].documentId)
                    var parentId = event.getSource().get("v.recordId");
            var Logs = component.get("v.Container.LogisticWrapperList");
            var Sales, GDrives;
            for(var x in Logs){
                if(Logs[x].Logistic.Id == parentId) {
                    Sales = Logs[x].isSales;
                    GDrives = Logs[x].isGDrive;
                }
            }
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var action = component.get("c.uploadGFile");
            action.setParams({
                parent: parentId,
                documentIds: FileIds,
                SyncSales: Sales,
                SyncGDrive: GDrives
            });
            action.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS'){
                    console.log('SUCCESS');
                    if(response.getReturnValue().exceptionError == '') {
                        var obj = component.get("v.Container.LogisticWrapperList");
                        for(var x in obj){
                            if(obj[x].Logistic.Id == parentId){
                               if(Sales) obj[x].conAttach = response.getReturnValue().uniContentVersion;
                               if(GDrives) obj[x].GDrive = response.getReturnValue().uniGdrive;
                                break;
                            }
                        }
                        component.set("v.Container.LogisticWrapperList",obj);
                    }
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                }else{                
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    var errors = response.getError();
                    if (errors) {
                        console.log(JSON.stringify(errors));
                        if (errors[0] && errors[0].message) {                                    
                            this.showToast('Error','error',errors[0].message);
                        }
                    } else {
                        console.log("Unknown error~>"+errors);
                    }                
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log('error ' + e);
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        }   
    }, 
    
    reRender : function(cmp, event, helper) { },
    
    closeError : function (cmp, event) {
        cmp.set("v.exceptionError",'');
    },
    imageError: function(component,event,helper){
        console.log('imageError called');
        event.target.style.display = 'none';
    }   
    
})