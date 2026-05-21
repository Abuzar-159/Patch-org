({
    init: function(cmp, evt, helper) {
        try{
            cmp.set("v.CostCardFilter"," AND ERP7__Supplier__c != null AND ERP7__Product__c != null AND ERP7__Cost__c >= 0 AND ERP7__Active__c = true AND ERP7__Quantity__c >= 0 And ERP7__Minimum_Quantity__c >= 0 And ERP7__Start_Date__c <= TODAY And ERP7__End_Date__c >= TODAY ");
            //var myPageRef = cmp.get("v.pageReference");
            // var polilist = myPageRef.state.c__plolist;
            //cmp.set("v.plolist", polilist);
            if(cmp.get("v.fromCreatePO")){
                helper.getPOdetails(cmp, evt, helper);
            }
            else{
                $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                cmp.set('v.channelId',cmp.get("v.plolist.channel"));
                cmp.set('v.ChannelName',cmp.get("v.plolist.distributionChannel.ERP7__Channel__r.Name"));
                cmp.set('v.dChannelId',cmp.get("v.plolist.distributionChannel.Id"));
                cmp.set('v.dChannelName',cmp.get("v.plolist.distributionChannel.Name"));
                var PorderList = cmp.get("v.plolist.poli");
                
                if(PorderList.length > 0){
                    var poline = [];
                    for(var i in PorderList){
                        poline.push(PorderList[i].pli); 
                    } console.log('poline : ',poline);
                    var chaId = cmp.get('v.channelId');
                    var dcis = cmp.get('v.dChannelId');
                    
                    var getPO = cmp.get('c.getAllPO');
                    getPO.setParams({
                        polist : JSON.stringify(poline),
                        chanId : chaId,
                        DCId : dcis
                    });
                    getPO.setCallback(this,function(response){
                        var state = response.getState();
                        if(state === 'SUCCESS'){
                            var obj  = response.getReturnValue();
                            console.log('getAllPO obj : ',response.getReturnValue());
                            cmp.set('v.AllPOs',obj);
                            var polist= cmp.get("v.AllPOs.POlist");
                            for(var i in polist){
                                polist[i].PO.FileList=[];
                                polist[i].PO.fillList=[];
                                polist[i].PO.Llist=[];
                                polist[i].PO.fileName=[];
                                polist[i].PO.taxrate=0;
                                polist[i].PO.SubTotal=0;
                                polist[i].PO.TotalTax=0;
                                polist[i].PO.TotalAmount=0;
                                if(polist[i].POLIs != undefined && polist[i].POLIs != null){
                                    for(var x in polist[i].POLIs){ 
                                        polist[i].POLIs[x].TotalAAPercentage=0;
                                        polist[i].POLIs[x].isAccCategoryChanged = false;
                                        polist[i].POLIs[x].custom = false;
                                        if(polist[i].POLIs[x].ERP7__Unit_Price__c == 0)polist[i].POLIs[x].ERP7__Unit_Price__c ="0";
                                    }
                                }
                            }
                            cmp.set("v.AllPOs.POlist",polist);
                            console.log('polist? : ',  polist);
                            helper.getVendorAddress(cmp,event,helper); 
                            helper.fetchOrgCurrncy(cmp,event,helper); 
                            $A.util.addClass(cmp.find('mainSpin'), "slds-hide");  
                            //helper.updateAmounts(cmp);
                        }
                    });
                    $A.enqueueAction(getPO);
                    //$A.enqueueAction(updateAmounts);
                    $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
                    
                } 
                
                console.log('poli : ',  cmp.get('v.plolist.poli'));
                cmp.set('v.editenableReceive',cmp.get('v.plolist.enableReceive'));
                cmp.set('v.showfileUpload',cmp.get('v.plolist.showUpload'));
                cmp.set('v.addressRequired',cmp.get('v.plolist.addressRequired')); 
                console.log('addressRequired? : ',  cmp.get('v.addressRequired'));
                console.log('addressRequired? : ',  cmp.get('v.plolist.addressRequired'));
                console.log('plolist? : ',  cmp.get('v.plolist'));
                //cmp.set('v.showfileUpload',false);
                //cmp.set('v.showAllocation',true);
                console.log('editenableReceive? : ',  cmp.get('v.editenableReceive'));
                console.log('showUpload? : ',  cmp.get('v.plolist.showUpload'));
                console.log('AllocationAccess? : ',  cmp.get('v.plolist.AllocationAccess'));
                console.log('showAllocations? : ',  cmp.get('v.showAllocations'));
                if(cmp.get('v.showAllocations') === false){
                    cmp.set('v.showAllocations',cmp.get('v.plolist.AllocationAccess')); 
                }
                
                cmp.set('v.submitApproval',cmp.get('v.plolist.submitApproval'));
                console.log('submitApproval? : ',  cmp.get('v.submitApproval'));
                //cmp.set('v.showAllocations',false);
                //console.log('AttachmentList? : ',  cmp.get('v.AllPOs.POlist[0].AttachmentList'));
            }
            let poStatus = cmp.get("c.getStatus");
            poStatus.setCallback(this,function(response){
                let resList = response.getReturnValue();
                cmp.set("v.POStatusoptions",resList);                
                
            });
            $A.enqueueAction(poStatus); 
            
            let poStatus1 = cmp.get("c.getCategoryList");
            poStatus1.setCallback(this,function(response){
                var resList = response.getReturnValue();
                var resListupdated = [];
                for(var i in resList){
                    if(i!=0) resListupdated.push(resList[i]);
                }
                cmp.set("v.PoliCategoryList",resListupdated);
                console.log('PoliCategoryList? : ',  cmp.get('v.PoliCategoryList'));
            });
            $A.enqueueAction(poStatus1);
            
            
            let getCurrency = cmp.get("c.getCurrencies");
            getCurrency.setCallback(this,function(response){
                var resList = response.getReturnValue();
                cmp.set("v.isMultiCurrency",resList.isMulticurrency);
                //cmp.set("v.isMultiCurrency",true); 
                cmp.set("v.currencyList",resList.currencyList); 
                console.log('currencyList? : ',  response.getReturnValue());
            });
            $A.enqueueAction(getCurrency); 
        }
        catch(e){console.log('exception:',e);} 
    },
    changeVendors : function(cmp, event, helper) {
        console.log('changeVendors clled');
        console.log('0');
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        console.log('1');
        var poliind = event.getSource().get('v.title');
        cmp.set('v.POLIIndex',poliind);
        var POind = event.getSource().get('v.class');
        cmp.set('v.POIndex',POind);
        if(!$A.util.isEmpty(poliind)){
            console.log('2');
            var isopen = false;
            var poliwrp = cmp.get('v.AllPOs.POlist');
            for(var x in poliwrp){
                console.log('3');
                if(x == POind){
                    for(var i in poliwrp[x].POLIs){
                        if(i == poliind){
                            if(poliwrp[x].POLIs[i].ERP7__Active__c){
                                console.log('4');
                                poliwrp[x].POLIs[i].ERP7__Active__c = false;
                                console.log('poliwrp[x].POLIs[i].ERP7__Active__c',JSON.stringify(poliwrp[x].POLIs[i].ERP7__Active__c));
                                isopen = true;
                            }
                        }
                    }
                }
                if(x != POind){
                    for(var i in poliwrp[x].POLIs){
                        poliwrp[x].POLIs[i].ERP7__Active__c = false;
                    }
                }
            }
            cmp.set('v.AllPOs.POlist',poliwrp);
            
            if(!isopen){
                console.log('5');
                cmp.set('v.showvendor',true);
                cmp.set('v.poliWrap.appven','');
                for(var x in poliwrp){
                    if(x == POind){
                        for(var i in poliwrp[x].POLIs){
                            poliwrp[x].POLIs[i].ERP7__Active__c = false;
                        }
                    }
                }
                console.log('6');
                helper.getupdateVen(cmp, event, helper,poliind,POind);
            }
            else{
                console.log('7');
                $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
            }
            
            
        }
        
    },
    popselectedDetails : function(cmp, event, helper) {
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var appvendorId = event.getSource().get('v.value');
        var index = cmp.get('v.POLIIndex');
        var POindex = cmp.get('v.POIndex');
        var poliwrp = cmp.get('v.AllPOs.POlist');
        var currProd = '';
        for(var x in poliwrp){
            if(x == POindex){
                for(var i in poliwrp[x].POLIs){
                    if(i == index){
                        poliwrp[x].POLIs[i].ERP7__Active__c = true;
                        currProd = poliwrp[x].POLIs[i].ERP7__Product__c;
                    }
                    else {
                        poliwrp[x].POLIs[i].ERP7__Active__c = false;
                    }
                }
            }
        }
        if(!$A.util.isEmpty(currProd) && !$A.util.isEmpty(appvendorId)){
            var populatedetails = cmp.get('c.populatepolidetails');
            populatedetails.setParams({
                ProductId : currProd,
                venId : appvendorId
            });
            populatedetails.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    var obj  = response.getReturnValue();
                    var poliwrp = []; 
                    poliwrp = cmp.get('v.AllPOs.POlist');
                    for(var x in poliwrp){
                        if(x == POindex){
                            for(var i in poliwrp[x].POLIs){
                                if(i == index && poliwrp[x].POLIs[i].ERP7__Active__c == true){
                                    poliwrp[x].POLIs[i].ERP7__Active__c = false;
                                    
                                    if(currProd == obj.ERP7__Product__c) poliwrp[x].POLIs[i].ERP7__Product__c = obj.ERP7__Product__c;
                                    poliwrp[x].POLIs[i].ERP7__Approved_Vendor__c =  appvendorId;
                                    poliwrp[x].POLIs[i].ERP7__Cost_Card__c =  obj.Id;
                                    poliwrp[x].POLIs[i].ERP7__Unit_Price__c = (obj.ERP7__Cost__c > 0)? obj.ERP7__Cost__c:"0";
                                    if(poliwrp[x].POLIs[i].ERP7__Product__c != null) {
                                        poliwrp[x].POLIs[i].Name = obj.ERP7__Product__r.Name;
                                        poliwrp[x].POLIs[i].ERP7__Vendor_product_Name__c = obj.ERP7__Product__r.ERP7__Vendor_product_Name__c;
                                    }
                                    if(obj.ERP7__Minimum_Quantity__c != null && obj.ERP7__Minimum_Quantity__c != '' && obj.ERP7__Minimum_Quantity__c != undefined && obj.ERP7__Minimum_Quantity__c > 0){
                                        if(poliwrp[x].POLIs[i].ERP7__Quantity__c == '' || poliwrp[x].POLIs[i].ERP7__Quantity__c == null || poliwrp[x].POLIs[i].ERP7__Quantity__c == undefined) poliwrp[x].POLIs[i].ERP7__Quantity__c = obj.ERP7__Minimum_Quantity__c;
                                        
                                    }
                                    if(poliwrp[x].POLIs[i].ERP7__Quantity__c = '')  poliwrp[x].POLIs[i].ERP7__Quantity__c = 0;
                                    if(poliwrp[x].POLIs[i].ERP7__Quantity__c != '' || poliwrp[x].POLIs[i].ERP7__Quantity__c != undefined) poliwrp[x].POLIs[i].ERP7__Total_Price__c = poliwrp[x].POLIs[i].ERP7__Quantity__c * obj.ERP7__Cost__c;
                                }
                            }
                        }
                    }
                    cmp.set('v.showvendor',false);
                    cmp.set('v.AllPOs.POlist',poliwrp);
                    $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                }
            });
            $A.enqueueAction(populatedetails);
        }
    },
    addNew : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var POind = event.getSource().get('v.title');
        var poliList = [];
        var Error = false;
        var taxrate=0;
        var poliwrp = component.get('v.AllPOs.POlist');
        if(!$A.util.isEmpty(poliwrp) && poliwrp.length > 0){
            for(var x in poliwrp){ 
                if(x == POind){
                    taxrate = poliwrp[x].PO.taxrate;
                    for(var i in poliwrp[x].POLIs){
                        if(poliwrp[x].POLIs[i].Name == ''){//poliwrp[x].POLIs[i].ERP7__Product__c == '' 
                            component.set('v.exceptionError',$A.get('$Label.c.PH_Please_enter_select_Product_to_proceed'));
                            Error = true;
                        }
                        /* else if(poliwrp[x].POLIs[i].ERP7__Product__c != null && poliwrp[x].POLIs[i].ERP7__Vendor__c == null){
                            component.set('v.exceptionError','Please Select Vendor to proceed');
                            Error = true;
                        }*/
                        
                        else if((poliwrp[x].POLIs[i].Name != '') && poliwrp[x].POLIs[i].ERP7__Vendor__c != null && poliwrp[x].POLIs[i].ERP7__Cost_Card__c == null){//poliwrp[x].POLIs[i].ERP7__Product__c != '' ||
                            component.set('v.exceptionError',$A.get('$Label.c.PH_Please_Select_Cost_card_to_proceed')); 
                            Error = true;
                        }
                            else if((poliwrp[x].POLIs[i].Name != '') && poliwrp[x].POLIs[i].ERP7__Vendor__c != null && poliwrp[x].POLIs[i].ERP7__Cost_Card__c != null && (poliwrp[x].POLIs[i].ERP7__Quantity__c <= 0 || $A.util.isEmpty(poliwrp[x].POLIs[i].ERP7__Quantity__c))){//poliwrp[x].POLIs[i].ERP7__Product__c != '' ||
                                component.set('v.exceptionError',$A.get('$Label.c.PH_Please_Enter_Quantity')); 
                                Error = true;
                            }
                    }
                }
                
            }
            
            
        }
        console.log('Error : '+Error);
        if(!Error){
            for(var x in poliwrp){
                if(x == POind){
                    //for(var i in poliwrp[x].POLIs){
                    console.log('taxrate',taxrate);
                    poliwrp[x].POLIs.unshift({ERP7__Product__c :'',ERP7__Quantity__c : '',ERP7__Cost_Card__c : '',TotalAAPercentage : 0,isAccCategoryChanged : false, custom: true}); 
                    break;
                    //}
                }
            }
            component.set("v.AllPOs.POlist",poliwrp);
            console.log('what is new poli index?',component.get("v.AllPOs.POlist"));
        }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        
        
    },
    deletePoli : function(component, event, helper) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var currtItem=event.getSource().get('v.title');
        const index = currtItem.split('-', 2);
        var POliindex = index[0];
        var poindex = index[1];
        var poliList =[];
        poliList=component.get("v.AllPOs.POlist");
        component.set("v.renderpoliaccounts",false);
        for(var x in poliList){
            if(x == poindex){
                for(var i in poliList[x].POLIs){
                    console.log('poliList[x].POLIs.length : '+poliList[x].POLIs.length);
                    if(poliList[x].POLIs.length == 1){
                        component.set('v.exceptionError',$A.get('$Label.c.PH_There_must_be_atleat_1_item_to_create_PO'));
                        break;
                    }
                    else if(i == POliindex) {
                        poliList[x].POLIs.splice(POliindex,1); 
                        break;
                    }
                }
            }
        }
        component.set("v.renderpoliaccounts",true);
        helper.updateAmounts(component);
        //poliList.splice(POliindex,1);
        //component.set("v.AllPOs.POlist",poliList);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        
    },
    closeError : function(component, event, helper) {
        component.set('v.exceptionError','');
    },
    
    SavePO : function(component, event, helper) {
        try{
            
            var pol = component.get("v.AllPOs");
            var polist = pol.POlist;
            var poDataArray = [];
            var poToAFilesMap = new Map();
            var accounts = [];
            var Err = false;  
            var errorinAccounts = false;
            var errorinAmount = false;
            errorinAccounts= helper.AnalyticalAccountCoaCheck(component, event, helper);
            errorinAmount = helper.AnalyticalAccountAmount(component, event, helper);
            console.log('After errorinAccounts',errorinAccounts);  
            for(var i in polist){
                for(var j in polist[i].POLIs){
                    //if(polist[i].POLIs[j].ERP7__Product__c == null || polist[i].POLIs[j].ERP7__Product__c == '' || polist[i].POLIs[j].ERP7__Product__c == undefined) polist[i].POLIs[j].ERP7__Cost_Card__c =null;
                    var index = i;
                    var Pindex = j;
                    
                    var poliIndex = index + "." + Pindex;
                    polist[i].POLIs[j].ERP7__Sort_Order__c = parseFloat(poliIndex);
                    for(var k in polist[i].POLIs[j].Accounts){
                        if(polist[i].POLIs[j].Accounts[k]) polist[i].POLIs[j].Accounts[k].ERP7__Sort_Order__c = parseFloat(poliIndex);
                    }
                    
                }      
            }
            console.log('polist[i].POLIs[j].Accounts[k].ERP7__Sort_Order__c?',polist); 
            
            /*for( var i in accounts){
                if((accounts[i].ERP7__Allocation_Percentage__c > 0) && (accounts[i].ERP7__Chart_of_Account__c == null || accounts[i].ERP7__Chart_of_Account__c == '' || accounts[i].ERP7__Chart_of_Account__c == undefined ||accounts[i].ERP7__Project__c == undefined ||accounts[i].ERP7__Project__c == null || accounts[i].ERP7__Project__c == '')){
                    component.set('v.exceptionError',"Please ensure the analytical and accounting Accounts are selected for "+JSON.stringify(poli.Name));
                    Err = true;
                    errorinAccounts = true;
                }
            }*/
            
            /* }else{
                component.set('v.dimensionList',accounts);
            }*/
            
            console.log('indexes of the po line items:',JSON.stringify(polist));
            component.set('v.PO2insert',pol);
            
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");
            var POpoliList =[];
            POpoliList=component.get("v.AllPOs.POlist");
            //var Err = false;
            for(var i in POpoliList){
                if(POpoliList[i].PO.ERP7__Vendor_Contact__c == null){
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set('v.exceptionError',$A.get('$Label.c.PH_Select_vendor_contact_of')+POpoliList[i].PO.ERP7__Vendor__r.Name);
                    Err = true;
                }
                if(component.get("v.addressRequired") && POpoliList[i].PO.ERP7__Vendor_Address__c == null || component.get("v.addressRequired") && POpoliList[i].PO.ERP7__Vendor_Address__c == ''){
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set('v.exceptionError',"Please select vendor address for vendor "+JSON.stringify(POpoliList[i].PO.ERP7__Vendor__r.Name));
                    Err = true;
                }
                for(var j in POpoliList[i].POLIs){
                    if((POpoliList[i].POLIs[j].ERP7__Quantity__c == '' || POpoliList[i].POLIs[j].ERP7__Quantity__c <= 0)){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        component.set('v.exceptionError',$A.get('$Label.c.PH_Enter_Quantity_for_Product')+POpoliList[i].POLIs[j].Name);
                        Err = true; 
                        
                    }
                    if((POpoliList[i].POLIs[j].ERP7__Unit_Price__c == '' || POpoliList[i].POLIs[j].ERP7__Unit_Price__c < 0 ||POpoliList[i].POLIs[j].ERP7__Unit_Price__c == null || POpoliList[i].POLIs[j].ERP7__Unit_Price__c == undefined)){
                        $A.util.addClass(component.find('mainSpin'), "slds-hide"); 
                        component.set('v.exceptionError','Please enter unit price for ' +POpoliList[i].POLIs[j].Name);//was JSON.stringify(POpoliList[i].POLIs[j].Name) 
                        Err = true; 
                    }
                    
                }
                if(errorinAccounts){
                    console.log('check Acc error');
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set('v.exceptionError','Please ensure all details related to allocation record are filled ');
                    Err = true;
                }
                if(errorinAmount){//added by asra 8/12
                    console.log('check Acc Amt error');
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    component.set('v.exceptionError','The allocation amount and percentage cannot be less or more than 100 ');
                    Err = true;
                }
            }
            
            console.log('err : '+Err);
            if(!Err){
                if(!errorinAccounts){
                    polist.forEach(function(item) {
                        // if(component.get('v.fromCreatePO') === false){
                        if(item.PO.Llist.length>0){
                            var po = item.PO.Name;
                            var fileList= item.PO.Llist;
                            var poData = {
                                poName: po,
                                fileList: fileList
                            };
                            poDataArray.push(poData);
                        }
                        item.PO.FileList=[];
                        item.PO.fillList=[];
                        item.PO.Llist=[];
                        item.PO.fileName=[];
                        // }
                        if (item.POLIs != undefined && item.POLIs != null) {
                            item.POLIs.forEach(function(poli) {
                                //if(poli.ERP7__Product__c == null || poli.ERP7__Product__c == '' || poli.ERP7__Product__c == undefined) poli.ERP7__Cost_Card__c =null;
                                if(poli.Accounts){
                                    //added on 16/11 
                                    accounts.push(poli.Accounts);
                                    poli.Accounts = [];
                                    if(component.get("v.isMultiCurrency")) poli.CurrencyIsoCode = item.PO.CurrencyIsoCode;
                                }
                            });
                        }
                        
                    });
                }
                component.set('v.dimensionList',accounts);
                console.log('accounts?',accounts);
                component.set('v.PO2insert',pol);
                console.log('poDataArray works?',poDataArray);
                //added this above part to avoid removal of accounts if met with validation errors.
                console.log('aftr check Acc error');
                var saveAction = component.get('c.savePOs');
                console.log('component.get(v.AllPOs) : ',component.get('v.AllPOs'));
                console.log('component.get(v.PO2insert) : ',component.get('v.PO2insert'));
                saveAction.setParams({POpolis : JSON.stringify(component.get('v.PO2insert'))});
                
                saveAction.setCallback(this,function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        console.log('inside success');
                        console.log('Result of PO :',JSON.stringify(response.getReturnValue()));
                        
                        var poIdsSet = [];
                        var pord=[];
                        pord=response.getReturnValue().insertedPos;
                        poIdsSet = response.getReturnValue().poIds;
                        
                        if(component.get("v.showfileUpload") === true){
                            console.log('from helper');
                            console.log('pord', pord);
                            console.log('poDataArray', poDataArray);
                            console.log('lengths', poDataArray.length, ' + ',pord.length);
                            for(var i=0;i<poDataArray.length;i++){
                                for(var j=0;j<pord.length;j++) {
                                    console.log('poDataArray ', poDataArray[i].poName,' + pord ',pord[j].Name);
                                    if(poDataArray[i].poName === pord[j].Name){
                                        console.log('poDataArray ', poDataArray[i].poName,' + pord ',pord[j].Name);
                                        console.log('poDataArray[i].fileList[0] ', poDataArray[i].fileList[0]);
                                        console.log('fileList[0],pord[j].Id ', pord[j].Id);
                                        for(var k=0;k<poDataArray[i].fileList.length;k++){
                                            var file=poDataArray[i].fileList[k];
                                            var parentId=pord[j].Id;
                                            helper.saveAtt2(component,event,file,parentId);
                                        }
                                        
                                    }
                                }  
                            }
                            console.log('Coming back to controller?');
                        }
                        
                        if(poIdsSet.length > 0){
                            console.log(poIdsSet.length);
                        }
                        
                        if(component.get("v.dimensionList.length") > 0){
                            console.log('AnalyticalAccounts',component.get("v.dimensionList"));
                            var action=component.get("c.AnalyticalAccounts");
                            action.setParams({'AA':JSON.stringify(component.get("v.dimensionList")), 'PId':poIdsSet});
                            action.setCallback(this,function(response){
                                var state = response.getState();
                                if(state === 'SUCCESS'){
                                    console.log('AnalyticalAccounts');
                                    
                                }
                                else{
                                    console.log('Error : ',response.getError());
                                }
                            });
                            $A.enqueueAction(action);
                        }
                        //}//
                        console.log('Is it getting stuck here?');
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        var obj;
                        if(component.get('v.fromCreatePO')) obj =  component.get('v.ALLPO');
                        else obj  = response.getReturnValue().insertedPos;
                        
                        if(component.get('v.fromCreatePO')) helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PH_Purchase_Order_Updated_Successfully'));
                        else helper.showToast($A.get('$Label.c.Success'),'success',$A.get('$Label.c.PH_Purchase_Order_Created_Successfully'));
                        $A.createComponent("c:ShowCreatedPO",{
                            "CreatedPOPOLIs":obj,
                            "channelId" : component.get('v.channelId'),
                            "dChannelId" : component.get('v.dChannelId'),
                            "ChannelName" : component.get('v.ChannelName'),
                            "dChannelName" : component.get('v.dChannelName'),
                            "fromAP" : component.get('v.fromAP'),
                            "poliWrap" : component.get('v.poliWrap'),
                            "submitApproval" : component.get('v.submitApproval'),
                            "showfileUpload" : component.get('v.showfileUpload'),
                            "showAllocations" : component.get('v.showAllocations'),
                            "MOId" : component.get('v.MOId'),
                            "plolist" : component.get('v.plolist'),
                            "addressRequired" : component.get('v.addressRequired'),
                            
                        },function(newCmp, status, errorMessage){
                            if (status === "SUCCESS") {
                                var body = component.find("body");
                                body.set("v.body", newCmp);
                            }
                        });
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                        let errors = response.getError();
                        let message = 'Unknown error';
                        console.log('Error : ',response.getError());
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            message = errors[0].message;
                        }
                        component.set('v.exceptionError',message); 
                    }
                });
                $A.enqueueAction(saveAction);
                
            }
        }
        catch(e){console.log('exception:',e);} 
    },
    
    Back2showPO :function(component, event, helper) {
        $A.createComponent("c:ShowCreatedPO",{
            "CreatedPOPOLIs":component.get('v.ALLPO'),
            "channelId" : component.get('v.channelId'),
            "dChannelId" : component.get('v.dChannelId'),
            "ChannelName" : component.get('v.ChannelName'),
            "dChannelName" : component.get('v.dChannelName'),
            "fromAP" : component.get('v.fromAP'),
            "poliWrap" : component.get('v.poliWrap'),
            "submitApproval" : component.get('v.submitApproval'),
            "showfileUpload" : component.get('v.showfileUpload'),
            "showAllocations" : component.get('v.showAllocations'),
            "MOId" : component.get('v.MOId'),
            "plolist" : component.get('v.plolist'),
            "addressRequired" : component.get('v.addressRequired'),
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
        
    },
    
    updateTotalPriceqty :function(cmp, event, helper) {
        var qty = event.getSource().get('v.value');
        if(qty <0){
            cmp.set('v.exceptionError',$A.get('$Label.c.PH_Enter_a_valid_Qty'));
        }
        else{
            if(qty == null || qty == '' || qty == 0){
                cmp.set('v.exceptionError',$A.get('$Label.c.PH_Enter_a_valid_Qty'));
            }
            var ind = event.getSource().get('v.title');
            const index = ind.split('-', 2);
            var POliindex = index[0];
            var poindex = index[1];
            var poliList =[];
            poliList=cmp.get("v.AllPOs.POlist");
            for(var x in poliList){
                if(x == poindex){
                    for(var i in poliList[x].POLIs){
                        if(i == POliindex) {
                            poliList[x].POLIs[i].ERP7__Tax__c = (!$A.util.isEmpty(poliList[x].POLIs[i].ERP7__Tax__c)) && (!$A.util.isUndefinedOrNull(poliList[x].POLIs[i].ERP7__Tax__c)) ? poliList[x].POLIs[i].ERP7__Tax__c : 0;
                            poliList[x].POLIs[i].ERP7__Tax_Rate__c = (!$A.util.isEmpty(poliList[x].POLIs[i].ERP7__Tax_Rate__c)) && (!$A.util.isUndefinedOrNull(poliList[x].POLIs[i].ERP7__Tax_Rate__c)) ? poliList[x].POLIs[i].ERP7__Tax_Rate__c : poliList[x].PO.taxrate;
                            var TotalTax = poliList[x].POLIs[i].ERP7__Tax_Rate__c;
                            poliList[x].POLIs[i].ERP7__Tax__c = parseFloat(((poliList[x].POLIs[i].ERP7__Unit_Price__c * parseFloat(qty))/100) * TotalTax).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            poliList[x].POLIs[i].ERP7__Active__c = false;
                            poliList[x].POLIs[i].ERP7__Total_Price__c = (parseFloat(qty) * parseFloat( poliList[x].POLIs[i].ERP7__Unit_Price__c)) + parseFloat(poliList[x].POLIs[i].ERP7__Tax__c);
                            if(qty > 0 && poliList[x].POLIs[i].ERP7__Unit_Price__c > 0){
                                if(poliList[x].POLIs[i].TotalAAPercentage == undefined || poliList[x].POLIs[i].TotalAAPercentage == null || poliList[x].POLIs[i].TotalAAPercentage == '' )poliList[x].POLIs[i].TotalAAPercentage=0;
                            } 
                        }
                        else{
                            poliList[x].POLIs[i].ERP7__Active__c = false;
                        }
                    }
                }
            }
            cmp.set("v.AllPOs.POlist",poliList);
            helper.updateAmounts(cmp);
            helper.updateACafterchange(cmp, event, poindex,POliindex);
        }
    },
    updateTotalPrice :function(cmp, event, helper) {
        var unitprice = event.getSource().get('v.value');
        if(unitprice <0){
            cmp.set('v.exceptionError',$A.get('$Label.c.PH_Enter_a_valid_unit_price'));
        }
        else{
            if(unitprice == null || unitprice == '' || unitprice == 0){
                cmp.set('v.exceptionError',$A.get('$Label.c.PH_Enter_a_valid_unit_price'));
            }
            var ind = event.getSource().get('v.title');
            const index = ind.split('-', 2);
            var POliindex = index[0];
            var poindex = index[1];
            var poliList =[];
            poliList=cmp.get("v.AllPOs.POlist");
            for(var x in poliList){
                if(x == poindex){
                    for(var i in poliList[x].POLIs){
                        if(i == POliindex) {
                            poliList[x].POLIs[i].ERP7__Tax__c = (!$A.util.isEmpty(poliList[x].POLIs[i].ERP7__Tax__c)) && (!$A.util.isUndefinedOrNull(poliList[x].POLIs[i].ERP7__Tax__c)) ? poliList[x].POLIs[i].ERP7__Tax__c : 0;
                            poliList[x].POLIs[i].ERP7__Active__c = false;
                            poliList[x].POLIs[i].ERP7__Tax_Rate__c = (!$A.util.isEmpty(poliList[x].POLIs[i].ERP7__Tax_Rate__c)) && (!$A.util.isUndefinedOrNull(poliList[x].POLIs[i].ERP7__Tax_Rate__c)) ? poliList[x].POLIs[i].ERP7__Tax_Rate__c : 0;
                            var TotalTax = poliList[x].POLIs[i].ERP7__Tax_Rate__c;
                            poliList[x].POLIs[i].ERP7__Tax__c = parseFloat(((parseFloat(unitprice) * parseFloat(poliList[x].POLIs[i].ERP7__Quantity__c))/100) * TotalTax).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            poliList[x].POLIs[i].ERP7__Total_Price__c = (parseFloat(unitprice) * parseFloat( poliList[x].POLIs[i].ERP7__Quantity__c)) + parseFloat(poliList[x].POLIs[i].ERP7__Tax__c);
                            if(unitprice > 0 && poliList[x].POLIs[i].ERP7__Quantity__c > 0){
                                if(poliList[x].POLIs[i].TotalAAPercentage == undefined || poliList[x].POLIs[i].TotalAAPercentage == null || poliList[x].POLIs[i].TotalAAPercentage == '')poliList[x].POLIs[i].TotalAAPercentage=0;
                            } 
                        }
                        else{
                            poliList[x].POLIs[i].ERP7__Active__c = false;
                        }
                    }
                }
            }
            cmp.set("v.AllPOs.POlist",poliList);
            helper.updateAmounts(cmp);
            helper.updateACafterchange(cmp, event, poindex,POliindex);
        }
    },
    updateTotalTax :function(cmp, event, helper) {
        var TotalTax = event.getSource().get('v.value');
        if(TotalTax == null || TotalTax == '' || TotalTax <=0)TotalTax=0;
        
        var ind = event.getSource().get('v.title');
        const index = ind.split('-', 2);
        var POliindex = index[0];
        var poindex = index[1];
        var poliList =[];
        poliList=cmp.get("v.AllPOs.POlist");
        for(var x in poliList){
            if(x == poindex){
                for(var i in poliList[x].POLIs){
                    if(i == POliindex) {
                        poliList[x].POLIs[i].ERP7__Active__c = false;
                        poliList[x].POLIs[i].ERP7__Tax__c = parseFloat(((poliList[x].POLIs[i].ERP7__Unit_Price__c * poliList[x].POLIs[i].ERP7__Quantity__c)/100) * TotalTax).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                        poliList[x].POLIs[i].ERP7__Total_Price__c = (parseFloat(poliList[x].POLIs[i].ERP7__Unit_Price__c) * parseFloat( poliList[x].POLIs[i].ERP7__Quantity__c)) + parseFloat(poliList[x].POLIs[i].ERP7__Tax__c);
                        
                    }
                    else{
                        poliList[x].POLIs[i].ERP7__Active__c = false;
                    }
                }
            }
        }
        cmp.set("v.AllPOs.POlist",poliList);
        helper.updateFromTax(cmp,poindex);
    },
    toggle : function(cmp, event, helper) {
        var items = cmp.get("v.AllPOs.POlist"), index = event.getSource().get("v.value");
        items[index].expanded = !items[index].expanded;
        for(var x in items){
            if(x != index && items[x].expanded == true)items[x].expanded =false;
        }
        cmp.set("v.AllPOs.POlist", items);
    },
    
    lookupClickProduct : function(component, event, helper) {
        
        var currindex = event.currentTarget.name;
        const index = currindex.split('-', 2);
        var POliindex = index[0];
        
        var poindex = index[1];
        component.set('v.POIndex',poindex);
        component.set('v.POLIIndex',POliindex);
        var prodlist = component.get('v.AllPOs.POlist');
        var currProdId = '';
        var currVenId = '';
        var fromApprovedVendor = false;
        
        for(var x in prodlist){
            
            if(x == poindex){
                currVenId = prodlist[x].PO.ERP7__Vendor__c;
                for(var i in prodlist[x].POLIs){
                    if(i == POliindex){
                        prodlist[x].POLIs[i].ERP7__Active__c = true;
                        currProdId = prodlist[x].POLIs[i].ERP7__Product__c;
                    }  
                }
                
            }
            
        }
        console.log('fromApprovedVendor : ',fromApprovedVendor);
        if(!$A.util.isEmpty(currProdId) && !$A.util.isEmpty(currVenId) ){
            var getProductVendors = component.get('c.getProdDetails');
            getProductVendors.setParams({
                ProductId : currProdId
            });
            getProductVendors.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    for(var x in prodlist){
                        if(x == poindex){
                            for(var i in prodlist[x].POLIs){
                                if(i == POliindex){
                                    prodlist[x].POLIs[i].Name = response.getReturnValue().Name;
                                    fromApprovedVendor =  response.getReturnValue().ERP7__Purchase_From_Approved_Vendor__c;
                                    //helper.getStockdetails(component,event,currProdId,poindex,POliindex,component.get('v.dChannelId'));
                                }
                                
                            }
                        }
                    }
                    console.log('fromApprovedVendor after: ',fromApprovedVendor);
                    if(fromApprovedVendor) helper.getupdateVen(component, event, helper,POliindex,poindex);
                    else component.set('v.poliWrap.appven',{});
                    component.set('v.AllPOs.POlist',prodlist);
                }
            });
            $A.enqueueAction(getProductVendors);
            
        }
        
        
        
    },
    lookupClickCostCard: function(component,event, helper) {
        var currindex = event.currentTarget.name;
        const index = currindex.split('-', 2);
        var POliindex = index[0]; 
        var poindex = index[1];
        component.set('v.POIndex',poindex);
        component.set('v.POLIIndex',POliindex);
        var poindex = component.get('v.POIndex');
        var POliindex =  component.get('v.POLIIndex');
        var prodlist = component.get('v.AllPOs.POlist');
        var currProdId = '';
        var currVenId = '';
        var qry = ' ';
        var hasCode = false;
        for(var x in prodlist){
            
            if(x == poindex){
                currVenId = prodlist[x].PO.ERP7__Vendor__c;
                for(var i in prodlist[x].POLIs){
                    if(i == POliindex){
                        prodlist[x].POLIs[i].ERP7__Active__c = true;
                        currProdId = prodlist[x].POLIs[i].ERP7__Product__c;
                        hasCode = prodlist[x].POLIs[i].hasCode;
                        //scurrProdId = prodlist[x].POLIs[i].ERP7__Product__c;
                        qry = 'And ERP7__Product__c = \'' + prodlist[x].POLIs[i].ERP7__Product__c + '\'';
                    }  
                }
            }
        }
        //var qry = ' ';
        //console.log('currProdId',currProdId);
        //if (currProdId != undefined && currProdId != '') qry = 'And ERP7__Product__c = \'' + currProdId + '\'';
        if (currVenId != undefined && currVenId != '') qry += ' AND ERP7__Supplier__c =\'' + currVenId + '\'';
        qry += ' AND ERP7__Cost__c >\=\ 0    And ERP7__Active__c = true And ERP7__Quantity__c >\=\ 0 And ERP7__Minimum_Quantity__c >\=\ 0 And ERP7__Start_Date__c <\=\ TODAY And ERP7__End_Date__c >\=\ TODAY';
        //alert(qry);
        component.set("v.qry", qry);
        console.log('qry',qry);
        if(currProdId != '' && hasCode != true){
            var action = component.get("c.fetchProdCode");
            action.setParams({
                "prodId": currProdId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue() != null){
                        var prodcode = response.getReturnValue();
                        console.log('Apex Result prodcode:',prodcode);
                        //component.set('v.prodCode',prodcode);
                        for(var x in prodlist){
                            
                            if(x == poindex){
                                for(var i in prodlist[x].POLIs){
                                    if(i == POliindex){
                                        prodlist[x].POLIs[i].hasCode = true;
                                        prodlist[x].POLIs[i].prodCode = prodcode;
                                    }  
                                }
                            }
                        }
                        component.set('v.AllPOs.POlist',prodlist);
                    }
                }else{
                    console.log('Error: ',response.getError());
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    getPrice: function(component, event, helper) {
        try {
            var poindex = component.get('v.POIndex');
            var POliindex =  component.get('v.POLIIndex');
            var prodlist = component.get('v.AllPOs.POlist');
            var currProdId = '';
            var currVenId = ''; var currCostCard = '';
            
            for(var x in prodlist){
                
                if(x == poindex){
                    currVenId = prodlist[x].PO.ERP7__Vendor__c;
                    for(var i in prodlist[x].POLIs){
                        if(i == POliindex){
                            prodlist[x].POLIs[i].ERP7__Active__c = true;
                            currProdId = prodlist[x].POLIs[i].ERP7__Product__c;
                            currCostCard = prodlist[x].POLIs[i].ERP7__Cost_Card__c
                        }  
                    }
                }
            }
            
            if(currCostCard != null && currCostCard !='' && currCostCard != undefined) {
                var action = component.get("c.fetchPrice");
                
                
                action.setParams({
                    "ccId": currCostCard
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {
                        if(response.getReturnValue() != null){
                            var res = response.getReturnValue();
                            for(var x in prodlist){
                                
                                if(x == poindex){
                                    currVenId = prodlist[x].PO.ERP7__Vendor__c;
                                    for(var i in prodlist[x].POLIs){
                                        if(i == POliindex){
                                            prodlist[x].POLIs[i].ERP7__Unit_Price__c = (res.ERP7__Cost__c > 0 && res.ERP7__Cost__c != null && res.ERP7__Cost__c != '') ? res.ERP7__Cost__c : "0";
                                            prodlist[x].POLIs[i].ERP7__Quantity__c = (prodlist[x].POLIs[i].ERP7__Quantity__c == 0 || prodlist[x].POLIs[i].ERP7__Quantity__c == null || prodlist[x].POLIs[i].ERP7__Quantity__c == undefined || prodlist[x].POLIs[i].ERP7__Quantity__c == '') ? res.ERP7__Quantity__c : prodlist[x].POLIs[i].ERP7__Quantity__c;
                                            prodlist[x].POLIs[i].ERP7__Total_Price__c  = parseFloat(prodlist[x].POLIs[i].ERP7__Quantity__c) * parseFloat( prodlist[x].POLIs[i].ERP7__Unit_Price__c);
                                            if(currProdId != '') prodlist[x].POLIs[i].ERP7__Vendor_product_Name__c = (res.ERP7__Vendor_Part_Number__c == null || res.ERP7__Vendor_Part_Number__c == '') ? res.ERP7__Product__r.ERP7__Vendor_product_Name__c : res.ERP7__Vendor_Part_Number__c;
                                            
                                        }  
                                    }
                                }
                            }
                            component.set('v.AllPOs.POlist',prodlist);
                        }
                        else{
                        }
                    }
                    else{
                    }
                });
                $A.enqueueAction(action);
            }else{
                for(var x in prodlist){
                    if(x == poindex){
                        for(var i in prodlist[x].POLIs){
                            if(i == POliindex){
                                console.log('prodcode being set:',prodlist[x].POLIs[i].prodCode);
                                if(prodlist[x].POLIs[i].prodCode != '') prodlist[x].POLIs[i].ERP7__Vendor_product_Name__c = prodlist[x].POLIs[i].prodCode;
                            }
                        }
                    }
                }
                component.set('v.AllPOs.POlist',prodlist);
                
            }
            for(var x in prodlist){
                if(x == poindex){
                    for(var i in prodlist[x].POLIs){
                        if(i == POliindex){
                            if(prodlist[x].POLIs[i].ERP7__Cost_Card__c != null && prodlist[x].POLIs[i].ERP7__Cost_Card__c !='' && prodlist[x].POLIs[i].ERP7__Cost_Card__c != undefined){
                                setTimeout(function() {
                                    helper.updateAmounts(component);
                                    helper.updateACafterchange(component, event, poindex, POliindex);
                                }, 2000);
                            }
                        }
                    }
                }
            }
            
        } catch (ex) {}
    },
    Back2MultiPO : function(cmp, event, helper) {
        console.log('plolist',cmp.get('v.plolist'));
        var bool1 = false;
        if(cmp.get("v.MOId")){
            bool1 = true;
        }  else bool1 = false;
        $A.createComponent("c:MultiplePurchaseOrders",{
            "poliWrap":cmp.get('v.plolist'),
            "fromAP" : true,
            "showAllocations" : cmp.get('v.showAllocations'),
            "FromMO" : false,
            "MOId" : cmp.get('v.MOId'),
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = cmp.find("body");
                body.set("v.body", newCmp);
                
            }
        });
        /* var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:MultiplePurchaseOrders",
                componentAttributes: {
                    "poliWrap":cmp.get('v.plolist'),
                    "fromAP" : cmp.get('v.fromAP'),
                    "showAllocations" : cmp.get('v.showAllocations'),
                    "MOId" : cmp.get('v.MOId'),
                }
            });
            evt.fire();*/
        
    },
    
    changeAddress : function(component,event,helper){ 
        // $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var polist= component.get("v.AllPOs.POlist");
        var index = event.currentTarget.getAttribute("data-index");
        var Polii=polist[index].PO.ERP7__Vendor_Address__c;
        var ven=polist[index].PO.ERP7__Vendor__c;
        console.log('Polii',Polii);
        if(Polii != undefined && Polii != null && Polii != ''){
            console.log('inside if');
            //var getPO = component.get('c.venAddress');
            //getPO.setParams({
            // Polii : Polii
            // });
            var getPO = component.get("c.checkforTax");
            getPO.setParams({
                "addId":Polii,
                "AccId":ven
            });
            
            getPO.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    if(response.getReturnValue()>0){
                        console.log('getReturnValue ', response.getReturnValue());  
                        polist[index].PO.taxrate = response.getReturnValue();
                        for (var x in polist[index].POLIs){
                            var qty = (!$A.util.isEmpty(polist[index].POLIs[x].ERP7__Quantity__c)) && (!$A.util.isUndefinedOrNull(polist[index].POLIs[x].ERP7__Quantity__c)) ? polist[index].POLIs[x].ERP7__Quantity__c : 0;
                            var unitprice = (!$A.util.isEmpty(polist[index].POLIs[x].ERP7__Unit_Price__c) && !$A.util.isUndefinedOrNull(polist[index].POLIs[x].ERP7__Unit_Price__c)) ? polist[index].POLIs[x].ERP7__Unit_Price__c : 0;
                            var taxamt = 0;
                            var taxrate = response.getReturnValue();
                            //var taxrate = response.getReturnValue().ERP7__Tax_Rate__c;
                            if(taxrate > 0 && unitprice > 0 && qty > 0) taxamt = parseFloat(((unitprice * qty)/100) * taxrate).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            var totalPrice = parseFloat(qty * unitprice) + parseFloat(taxamt);
                            polist[index].POLIs[x].ERP7__Tax_Rate__c=taxrate;
                            polist[index].POLIs[x].ERP7__Tax__c=taxamt;
                            polist[index].POLIs[x].ERP7__Total_Price__c=totalPrice;
                        }
                        
                        component.set("v.AllPOs.POlist",polist);
                        helper.updateAmounts(component);
                        // $A.util.addClass(cmp.find('mainSpin'), "slds-hide"); 
                        
                    }
                    else{
                        console.log('or else');
                        polist[index].PO.taxrate = 0;
                        for (var x in polist[index].POLIs){
                            var qty = (!$A.util.isEmpty(polist[index].POLIs[x].ERP7__Quantity__c)) && (!$A.util.isUndefinedOrNull(polist[index].POLIs[x].ERP7__Quantity__c)) ? polist[index].POLIs[x].ERP7__Quantity__c : 0;
                            var unitprice = (!$A.util.isEmpty(polist[index].POLIs[x].ERP7__Unit_Price__c) && !$A.util.isUndefinedOrNull(polist[index].POLIs[x].ERP7__Unit_Price__c)) ? polist[index].POLIs[x].ERP7__Unit_Price__c : 0;
                            var taxamt = 0;
                            var taxrate = 0;
                            var totalPrice = parseFloat(qty * unitprice);
                            polist[index].POLIs[x].ERP7__Tax_Rate__c=taxrate;
                            polist[index].POLIs[x].ERP7__Tax__c=taxamt;
                            polist[index].POLIs[x].ERP7__Total_Price__c=totalPrice;
                        }
                        
                        component.set("v.AllPOs.POlist",polist); 
                        //  $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        
                    }
                    
                }
                else{
                    var errors = response.getError();
                    console.log("fetchProductDesc error : ", errors);
                }
            });
            $A.enqueueAction(getPO);
        }
    },
    
    displayAccounts : function(component,event,helper){
        try{
            $A.util.removeClass(component.find('mainSpin'), "slds-hide");//added by Asra
            component.set("v.displayAccount",true);
            
            var index = event.currentTarget.getAttribute("data-index");
            console.log("POindex-: " + index);
            
            var Pindex = event.currentTarget.getAttribute("data-PIndex");
            console.log("POLI index-: " + Pindex);
            
            var polist= component.get("v.AllPOs.POlist");
            console.log("POlist: before " , component.get("v.AllPOs.POlist")); 
            var auto= polist[index].PO.AutoAccountAllocations;
            var Polii=polist[index].POLIs[Pindex]; 
            var allPoli=polist[index].POLIs;
            var accCat = '';
            if(Polii.isAccCategoryChanged == false){
                var catglist= component.get("v.PoliCategoryList");
                console.log('catglist~>',catglist);
                var accCat = catglist[0];
            }
            console.log('accCat~>',accCat);
            console.log('Polii.ERP7__Account_Category__c~>'+polist[index].POLIs[Pindex].ERP7__Account_Category__c);
            console.log("Particular Polii: before " , Polii," AutoAccountAllocations",auto);
            
            var str = '';
            
            for(var i in polist){
                if(i == index){
                    console.log('inhere');
                    if(polist[i].POLIs != undefined && polist[i].POLIs != null){
                        for(var x in polist[i].POLIs){
                            if(x == Pindex){
                                console.log('inhere2');
                                str = polist[i].POLIs[x].ERP7__Product__c;
                                if(polist[i].POLIs[x].Accounts == undefined || polist[i].POLIs[x].Accounts == null) {
                                    polist[i].POLIs[x].Accounts = [];
                                }
                                
                            }
                        }
                    }
                }
            }
            component.set("v.AllPOs.POlist",polist);
            
            console.log("POlist: after " , component.get("v.AllPOs.POlist")); 
            polist = component.get("v.AllPOs.POlist");
            
            Polii = polist[index].POLIs[Pindex];
            console.log("Particular Polii: after " , Polii);
            console.log('index:'+index+ ', Pindex :' +Pindex);
            console.log('str~>'+str);
            console.log("polii.isAccCategoryChanged " ,Polii.isAccCategoryChanged);
            console.log("allPoli? " ,allPoli);
            
            var getPO = component.get('c.fetchProductDesc');
            getPO.setParams({
                productId : str
            });
            getPO.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var assignDefaultItemCOA = false;
                    var assignDefaultItemAccCategory = false;
                    
                    if (response.getReturnValue() != null){
                        console.log('resp fetchProductDesc~>',response.getReturnValue());
                        
                        if(Polii.isAccCategoryChanged == false || $A.util.isEmpty(Polii.ERP7__Chart_of_Account__c) || $A.util.isUndefinedOrNull(Polii.ERP7__Chart_of_Account__c)){
                            assignDefaultItemCOA = true;
                        }
                        if(assignDefaultItemCOA == false){
                            if(Polii.Accounts != undefined && Polii.Accounts != null){
                                if(Polii.Accounts.length > 0){
                                    //dont assignDefaultItemCOA
                                }else assignDefaultItemCOA = true;
                            }else assignDefaultItemCOA = true;
                        }
                        if(!$A.util.isEmpty(response.getReturnValue().ERP7__Inventory_Account__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().ERP7__Inventory_Account__c)){
                            component.set("v.defaultProdAccA",response.getReturnValue().ERP7__Inventory_Account__c);
                            if(assignDefaultItemCOA) Polii.ERP7__Chart_of_Account__c = response.getReturnValue().ERP7__Inventory_Account__c;
                        }
                        
                        if(Polii.isAccCategoryChanged == false || $A.util.isEmpty(Polii.ERP7__Account_Category__c) || $A.util.isUndefinedOrNull(Polii.ERP7__Account_Category__c)){
                            assignDefaultItemAccCategory = true;
                        }
                        if(assignDefaultItemAccCategory == false){
                            if(Polii.Accounts != undefined && Polii.Accounts != null){
                                if(Polii.Accounts.length > 0){
                                    //dont assignDefaultItemAccCategory
                                }else assignDefaultItemAccCategory = true;
                            }else assignDefaultItemAccCategory = true;
                        }
                        if(!$A.util.isEmpty(response.getReturnValue().ERP7__Project__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().ERP7__Project__c)){
                            component.set("v.defaultProdAnalA",response.getReturnValue().ERP7__Project__c);
                            if(!$A.util.isEmpty(response.getReturnValue().ERP7__Project__r.ERP7__Account_Category__c) && !$A.util.isUndefinedOrNull(response.getReturnValue().ERP7__Project__r.ERP7__Account_Category__c)){
                                if(assignDefaultItemAccCategory) Polii.ERP7__Account_Category__c= response.getReturnValue().ERP7__Project__r.ERP7__Account_Category__c;
                            }
                        }
                    }  
                    
                    var TotalAAPercentage = 0;
                    if(Polii.Accounts != undefined && Polii.Accounts != null){
                        if(Polii.Accounts.length > 0){
                            var itemAccs = Polii.Accounts;
                            for(var i in itemAccs){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                    if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                                }
                            }
                        }
                    }
                    component.set("v.TotalAAPercentage",TotalAAPercentage);
                    Polii.TotalAAPercentage = TotalAAPercentage;
                    
                    console.log('arshad TotalAAPercentage~>'+component.get("v.TotalAAPercentage")+' typeof~>'+typeof component.get("v.TotalAAPercentage"));
                    var remainingTotalAAPercent = parseFloat(100 - component.get("v.TotalAAPercentage")).toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    console.log('arshad remainingTotalAAPercent~>'+remainingTotalAAPercent+' typeof~>'+typeof remainingTotalAAPercent);
                    
                    component.set("v.displayAccount", true);
                    var poliList = [];
                    var polList = [];
                    if(Polii.Accounts != undefined && Polii.Accounts != null) polList = Polii.Accounts;
                    console.log('polList before~>'+polList.length);
                    
                    //change below part!
                    var pol = [];
                    pol = allPoli;
                    var indexed = pol.length;
                    //var poliIndex = parseInt(Pindex + 1);console.log('index:'+index+ ', Pindex :' +Pindex);
                    var poliIndex = index + "." + Pindex;
                    console.log('poliIndex :',poliIndex); // Output: (0 . 1)
                    console.log('working?1');
                    console.log('Polii Acc?',Polii.Accounts);
                    if(pol != null && pol > 0 ) poliList = pol[indexed-1].Accounts;
                    console.log('working?2');
                    console.log('inherebefore');
                    if(auto){
                        var coaId = '';
                        var projId = '';
                        
                        
                        if(pol.length > 0){
                            console.log('Auto pol[0]~>'+JSON.stringify(pol[0]));
                            if(pol[0].Accounts != null && pol[0].Accounts != undefined){
                                if(pol[0].Accounts.length > 0){
                                    if(pol[0].Accounts[0].ERP7__Project__c != undefined && pol[0].Accounts[0].ERP7__Project__c != null && pol[0].Accounts[0].ERP7__Project__c != ''){
                                        projId = pol[0].Accounts[0].ERP7__Project__c;
                                    }
                                }
                            }
                            console.log('projId~>'+projId);
                            if(pol[0].ERP7__Chart_of_Account__c != null && pol[0].ERP7__Chart_of_Account__c != undefined && pol[0].ERP7__Chart_of_Account__c != ''){
                                coaId = pol[0].ERP7__Chart_of_Account__c;
                            }
                            console.log('coaId~>'+coaId);
                            Polii.ERP7__Chart_of_Account__c= coaId;
                            if(pol[0].ERP7__Account_Category__c != null && pol[0].ERP7__Account_Category__c != undefined && pol[0].ERP7__Account_Category__c != ''){
                                Polii.ERP7__Account_Category__c= pol[0].ERP7__Account_Category__c;
                                //accCat = pol[0].ERP7__Account_Category__c;
                            }
                        }
                        
                        if(remainingTotalAAPercent > 0){
                            polList.push({sObjectType :'ERP7__Dimension__c', ERP7__Chart_of_Account__c : coaId, ERP7__Project__c : projId, ERP7__Sort_Order__c:parseFloat(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: ((parseFloat(parseFloat(Polii.ERP7__Quantity__c) * parseFloat(Polii.ERP7__Unit_Price__c)) * remainingTotalAAPercent)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")) });
                            console.log('polList: ',polList);
                        }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);         
                    }
                    else{
                        console.log('autoallocation false');
                        
                        if(remainingTotalAAPercent > 0){
                            polList.push({sObjectType :'ERP7__Dimension__c', ERP7__Chart_of_Account__c : Polii.ERP7__Chart_of_Account__c, ERP7__Project__c : (assignDefaultItemAccCategory) ? component.get("v.defaultProdAnalA") : '', ERP7__Sort_Order__c:parseFloat(poliIndex), ERP7__Allocation_Percentage__c :remainingTotalAAPercent, ERP7__Allocation_Amount__c: ((parseFloat(parseFloat(Polii.ERP7__Quantity__c) * parseFloat(Polii.ERP7__Unit_Price__c)) * remainingTotalAAPercent)/100).toFixed($A.get("$Label.c.DecimalPlacestoFixed")) });
                            console.log('polList: ',polList);                        	
                        }else console.log('arshad new dimension not added because remainingTotalAAPercent~>'+remainingTotalAAPercent);    
                    }
                    
                    console.log('polList after~>'+polList.length);
                    Polii.Accounts = polList;
                    
                    component.set("v.AllPOs.POlist",polist);
                    //component.set("v.AllPOs.POlist",polist);
                    console.log("POlist: after atlast " , component.get("v.AllPOs.POlist")); 
                    
                    var TotalAAPercentage2 = 0;
                    if(Polii.Accounts != undefined && Polii.Accounts != null){
                        if(Polii.Accounts.length > 0){
                            var itemAccs = Polii.Accounts;
                            for(var i in itemAccs){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                    if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage2 += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                                }
                            }
                        }
                    }
                    component.set("v.TotalAAPercentage",TotalAAPercentage2);
                    Polii.TotalAAPercentage = TotalAAPercentage2;
                    component.set("v.AllPOs.POlist",polist);
                }
                else{
                    var errors = response.getError();
                    console.log("fetchProductDesc error : ", errors);
                }
                $A.util.addClass(component.find('mainSpin'), "slds-hide");//added on 21/11
            });
            $A.enqueueAction(getPO);
            
        }catch(e){
            console.log('err~>'+e);
        }
    },
    //deleteAnalyAcc : function(component, event, helper) {
    //component.set("v.displayAccount",false);
    // component.set("v.TotalAAPercentage",0);
    // },
    /*  deleteAnalyAcc :function(component, event, helper) {
        try{
            var polist =component.get("v.AllPOs.POlist");
            var polindex = event.getSource().get('v.ariaControls'); 
            var poindex = event.getSource().get('v.ariaDescribedBy');
            var index = event.getSource().get('v.name');
            console.log('inside deleteAnalyAcc poli index',polindex);
            console.log('poindex',poindex);
            for(var x in polist){
                if(x == poindex){
                    console.log('x in');
                    var polis = polist[x].POLIs;
                    for(var y in polis){
                        if(y == polindex){
                            console.log('y in');
                            var TotalAAPercentage = 0;
                            var poliList =[]; 
                            poliList = polis[y].Accounts;
                            for(var z in poliList){
                                if(z == index) {
                                    console.log('z in');
                                   poliList.splice(index,1);
                                    if(poliList[z] != undefined){
                                        if(poliList[z].ERP7__Allocation_Percentage__c != undefined && poliList[z].ERP7__Allocation_Percentage__c != null && poliList[z].ERP7__Allocation_Percentage__c != ''){
                                            if(poliList[z].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(poliList[z].ERP7__Allocation_Percentage__c);
                                        }
                                    }
                                }
                            }
                            console.log('TotalAAPercentage : ',TotalAAPercentage);
                            if(polis[y] != undefined) polis[y].TotalAAPercentage = TotalAAPercentage;
                        }
                    }
                }
            }
            //component.set("v.AllPOs.POlist",polist);
            console.log('ALLPOS : ',component.get("v.AllPOs.POlist"));
            component.set("v.renderpoliaccounts",true);
         /*   var Polii=polist[poindex].POLIs[polindex];
            var poliList =[]; 
            poliList = Polii.Accounts;
            console.log('poliList before delete length poitems cmp~>'+poliList.length);
            if(index != undefined && index != null){
                component.set("v.renderpoliaccounts",false);
                delete poliList[index].ERP7__Project__c;
                console.log('poliList before delete poitems cmp ~>'+JSON.stringify(poliList));
                poliList.splice(index,1);  
            }

            console.log('poliList after delete poitems cmp 11 ~>',JSON.stringify(Polii.Accounts));
            console.log('poliList after delete poitems cmp 11 after ~>',JSON.stringify(poliList));
            Polii.Accounts = poliList;
            //component.set("v.AllPOs.POlist",polist);
            console.log('poliList after delete poitems cmp 1122 ~>',JSON.stringify(Polii.Accounts));
            if(poliList.length <= 0 && Polii.Accounts.length > 0){
                Polii.Accounts = null;
            }
            component.set("v.renderpoliaccounts",true);
            console.log('v.item.Accounts after delete length poitems cmp~>'+Polii.Accounts.length);
            console.log('v.item.Accounts after delete poitems cmp ~>'+JSON.stringify(Polii.Accounts));
            
            var TotalAAPercentage = 0;
            if(Polii.Accounts != undefined && Polii.Accounts != null){
                if(Polii.Accounts.length > 0){
                    var itemAccs = Polii.Accounts;
                    for(var i in itemAccs){
                        console.log('itemAccs[i] : ',JSON.stringify(itemAccs[i]));
                        if(itemAccs[i].ERP7__Project__c === '' && itemAccs[i].ERP7__Allocation_Percentage__c == undefined && itemAccs[i].sObjectType == undefined) {
                            itemAccs.splice(i,1);  
                            console.log('remove deleted items');
                        }
                        if(itemAccs[i] != undefined){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                            }
                        }
                        
                        
                    }
                }else{
                    console.log('inhere1');
                    Polii.ERP7__Chart_of_Account__c = null;
                    var defvalue = '';
                    var PoliCategoryList = component.get("v.PoliCategoryList");
                    if(PoliCategoryList != undefined && PoliCategoryList != null){
                        if(PoliCategoryList.length > 0){
                            defvalue = PoliCategoryList[0];
                        }
                    }
                    if(defvalue != '') Polii.ERP7__Account_Category__c = defvalue;
                    console.log('inhere2');
                    console.log('component.get("v.item.ERP7__Chart_of_Account__c")~>'+Polii.ERP7__Chart_of_Account__c);
                    console.log('component.get("v.item.ERP7__Account_Category__c")~>'+Polii.ERP7__Account_Category__c);
                }
            }
            console.log('TotalAAPercentage : ',TotalAAPercentage);
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            Polii.TotalAAPercentage = TotalAAPercentage;
            //component.set("v.AllPOs.POlist",polist);
            component.set("v.renderpoliaccounts",true); 
            
        } catch (e) { console.log('deleteAnalyAcc err~>'+e); }
    },*/
    deleteAnalyAcc :function(component, event, helper) {
        try{
            var polist =component.get("v.AllPOs.POlist");
            var polindex = event.getSource().get('v.ariaControls'); 
            var poindex = event.getSource().get('v.ariaDescribedBy');
            var index = event.getSource().get('v.name');
            console.log('inside deleteAnalyAcc poli index',polindex);
            console.log('poindex',poindex);
            var Polii=polist[poindex].POLIs[polindex];
            var poliList =[]; 
            poliList = Polii.Accounts;
            var demId = poliList[index].Id;
            console.log('poliList before delete length poitems cmp~>'+poliList.length);
            if(index != undefined && index != null){
                component.set("v.renderpoliaccounts",false);
                delete poliList[index].ERP7__Project__c;
                console.log('poliList before delete poitems cmp ~>'+JSON.stringify(poliList));
                poliList.splice(index,1);  
            }
            if(component.get("v.fromCreatePO")){
                var action = component.get('c.deleteDimension');
                action.setParams({
                    Demid : demId
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if(state==='SUCCESS'){ 
                        console.log('success');
                    }
                });
                $A.enqueueAction(action);
            }
            
            console.log('poliList after delete poitems cmp 11 ~>',JSON.stringify(Polii.Accounts));
            console.log('poliList after delete poitems cmp 11 after ~>',JSON.stringify(poliList));
            Polii.Accounts = poliList;
            //component.set("v.AllPOs.POlist",polist);
            console.log('poliList after delete poitems cmp 1122 ~>',JSON.stringify(Polii.Accounts));
            if(poliList.length <= 0 && Polii.Accounts.length > 0){
                Polii.Accounts = null;
            }
            console.log('v.item.Accounts after delete length poitems cmp~>'+Polii.Accounts.length);
            console.log('v.item.Accounts after delete poitems cmp ~>'+JSON.stringify(Polii.Accounts));
            
            var TotalAAPercentage = 0;
            if(Polii.Accounts != undefined && Polii.Accounts != null){
                if(Polii.Accounts.length > 0){
                    var itemAccs = Polii.Accounts;
                    for(var i in itemAccs){
                        console.log('itemAccs[i] : ',JSON.stringify(itemAccs[i]));
                        if(itemAccs[i].ERP7__Project__c === '' && itemAccs[i].ERP7__Allocation_Percentage__c == undefined && itemAccs[i].sObjectType == undefined) {
                            itemAccs.splice(i,1);  
                            console.log('remove deleted items');
                        }
                        if(itemAccs[i] != undefined){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                                if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                            }
                        }
                        
                        
                    }
                }else{
                    console.log('inhere1');
                    Polii.ERP7__Chart_of_Account__c = null;
                    var defvalue = '';
                    var PoliCategoryList = component.get("v.PoliCategoryList");
                    if(PoliCategoryList != undefined && PoliCategoryList != null){
                        if(PoliCategoryList.length > 0){
                            defvalue = PoliCategoryList[0];
                        }
                    }
                    if(defvalue != '') Polii.ERP7__Account_Category__c = defvalue;
                    console.log('inhere2');
                    console.log('component.get("v.item.ERP7__Chart_of_Account__c")~>'+Polii.ERP7__Chart_of_Account__c);
                    console.log('component.get("v.item.ERP7__Account_Category__c")~>'+Polii.ERP7__Account_Category__c);
                }
            }
            console.log('TotalAAPercentage : ',TotalAAPercentage);
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            polist[poindex].POLIs[polindex].TotalAAPercentage = TotalAAPercentage;
            console.log(' POLI III : ',polist[poindex].POLIs[polindex].TotalAAPercentage);
            //component.set("v.AllPOs.POlist",polist);
            component.set("v.renderpoliaccounts",true);
            
        } catch (e) { console.log('deleteAnalyAcc err~>'+e); }
    },
    
    
    resetAA : function(component, event, helper) {
        try{
            console.log('inside resetAA');
            var index = event.getSource().get("v.title");
            console.log("POindex-: " + index);
            
            var Pindex = event.getSource().get("v.name");
            console.log("POLI index-: " + Pindex);
            
            var getCat = event.getSource().get("v.value");
            console.log("getCat: " , getCat);
            var polist =component.get("v.AllPOs.POlist");
            var Polii=polist[index].POLIs[Pindex];
            var TotalAAPercentage = 0;
            if(Polii.Accounts != undefined && Polii.Accounts != null){
                if(Polii.Accounts.length > 0){
                    var itemAccs = Polii.Accounts;
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            Polii.TotalAAPercentage = TotalAAPercentage;
            
            Polii.ERP7__Chart_of_Account__c = null;
            var poliList =[]; 
            poliList=Polii.Accounts;
            for(var x in poliList){
                poliList[x].ERP7__Project__c = null;
                //poliList[x].ERP7__Account_Category__c = getCat;
            }
            console.log("poliList: " , poliList);
            Polii.Accounts = poliList;
            Polii.isAccCategoryChanged=true;
            component.set("v.AllPOs.POlist",polist);
            /*var polist =component.get("v.AllPOs.POlist");
            var value = event.getSource().get('v.value');
            var Polii=polist[0].POLIs[0];
            Polii.ERP7__Account_Category__c=value;
            console.log('Polii', Polii);
            console.log('value', value);
            console.log('Polii ERP7__Account_Category__c', Polii.ERP7__Account_Category__c);  
            component.set("v.AllPOs.POlist",polist);
            console.log('AllPOs', component.get("v.AllPOs.POlist"));*/
        } catch (e) { console.log('resetAA err~>'+e); }
    },    
    
    updateACTaxAmount : function(component,event,helper){
        try{
            var TotalAAPercentage = 0;
            var index = event.getSource().get("v.title");
            console.log("POindex-: " + index);
            
            var Pindex = event.getSource().get("v.name");
            console.log("POLI index-: " + Pindex);
            var polist =component.get("v.AllPOs.POlist");
            var value = event.getSource().get('v.value');
            var Polii=polist[index].POLIs[Pindex];
            console.log('value', value);
            if(Polii.Accounts != undefined && Polii.Accounts != null){
                console.log('1');
                if(Polii.Accounts.length > 0){
                    console.log('2');
                    var itemAccs = Polii.Accounts;
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            console.log('3');
            Polii.TotalAAPercentage=TotalAAPercentage;
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            
            if(Polii.ERP7__Total_Price__c != '' && Polii.ERP7__Total_Price__c != null && Polii.ERP7__Total_Price__c != undefined){
                var aaacount = []; aaacount = Polii.Accounts;
                if(aaacount != null && aaacount != undefined){
                    console.log('4');
                    if(aaacount.length > 0){
                        for(var a in aaacount){
                            if(aaacount[a].ERP7__Allocation_Percentage__c != undefined && aaacount[a].ERP7__Allocation_Percentage__c != null && aaacount[a].ERP7__Allocation_Percentage__c != ''){
                                if(aaacount[a].ERP7__Allocation_Percentage__c > 0){
                                    if(!$A.util.isEmpty(Polii.ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(Polii.ERP7__Quantity__c) && !$A.util.isEmpty(Polii.ERP7__Unit_Price__c) && !$A.util.isUndefinedOrNull(Polii.ERP7__Unit_Price__c)){
                                        aaacount[a].ERP7__Allocation_Amount__c = parseFloat((parseFloat(Polii.ERP7__Quantity__c) * parseFloat(Polii.ERP7__Unit_Price__c)) * aaacount[a].ERP7__Allocation_Percentage__c)/100;
                                        aaacount[a].ERP7__Allocation_Amount__c = aaacount[a].ERP7__Allocation_Amount__c.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                    }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                                    //if(component.get("v.item.ERP7__Tax__c") == null || component.get("v.item.ERP7__Tax__c") == undefined || component.get("v.item.ERP7__Tax__c") == ''){
                                    //    aaacount[a].ERP7__Allocation_Amount__c = parseFloat(component.get("v.item.ERP7__Total_Price__c") * aaacount[a].ERP7__Allocation_Percentage__c)/100;
                                    //} else aaacount[a].ERP7__Allocation_Amount__c = parseFloat( parseFloat(component.get("v.item.ERP7__Total_Price__c") - component.get("v.item.ERP7__Tax__c")) * aaacount[a].ERP7__Allocation_Percentage__c)/100;
                                }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                            }else aaacount[a].ERP7__Allocation_Amount__c = 0;
                        }
                    }
                }
                Polii.Accounts = aaacount; 
                component.set("v.AllPOs.POlist",polist);
                console.log('Polii with TotalAAPercentage?',Polii);
                console.log('component.set("v.AllPOs.POlist",polist);~>',component.set("v.AllPOs.POlist",polist));
            }
        } catch (e) { console.log('updateACTaxAmount err~>',e); }
    },
    
    updateACTaxPerentage : function(component,event,helper){
        try{
            var index = event.getSource().get("v.title");
            console.log("POindex-: " + index);
            
            var Pindex = event.getSource().get("v.name");
            console.log("POLI index-: " + Pindex);
            var polist =component.get("v.AllPOs.POlist");
            var value = event.getSource().get('v.value');
            var Polii=polist[index].POLIs[Pindex];
            console.log('Polii', Polii);
            if(Polii.ERP7__Total_Price__c != '' && Polii.ERP7__Total_Price__c != null && Polii.ERP7__Total_Price__c != undefined){
                var aaacount = [];
                aaacount = Polii.Accounts;
                for(var a in aaacount){
                    if(aaacount[a].ERP7__Allocation_Amount__c != undefined && aaacount[a].ERP7__Allocation_Amount__c != null && aaacount[a].ERP7__Allocation_Amount__c != ''){
                        if(aaacount[a].ERP7__Allocation_Amount__c > 0){
                            var percent = 0;
                            if(!$A.util.isEmpty(Polii.ERP7__Quantity__c) && !$A.util.isUndefinedOrNull(Polii.ERP7__Quantity__c) && !$A.util.isEmpty(Polii.ERP7__Unit_Price__c) && !$A.util.isUndefinedOrNull(Polii.ERP7__Unit_Price__c)){
                                percent = parseFloat(parseFloat(aaacount[a].ERP7__Allocation_Amount__c) / parseFloat(parseFloat(Polii.ERP7__Quantity__c) * parseFloat(Polii.ERP7__Unit_Price__c)))*100;
                                aaacount[a].ERP7__Allocation_Percentage__c = percent.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                            //if(component.get("v.item.ERP7__Tax__c") == null || component.get("v.item.ERP7__Tax__c") == undefined || component.get("v.item.ERP7__Tax__c") == ''){
                            //    percent = parseFloat(aaacount[a].ERP7__Allocation_Amount__c / component.get("v.item.ERP7__Total_Price__c"))*100;
                            //}else percent = parseFloat(aaacount[a].ERP7__Allocation_Amount__c / parseFloat(component.get("v.item.ERP7__Total_Price__c") - component.get("v.item.ERP7__Tax__c")))*100;
                            
                        }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                    }else aaacount[a].ERP7__Allocation_Percentage__c = 0;
                }
                Polii.Accounts = aaacount;
                component.set("v.AllPOs.POlist",polist); 
            }
            
            var TotalAAPercentage = 0;
            if(Polii.Accounts != undefined && Polii.Accounts != null){
                if(Polii.Accounts.length > 0){
                    var itemAccs = Polii.Accounts;
                    for(var i in itemAccs){
                        if(itemAccs[i].ERP7__Allocation_Percentage__c != undefined && itemAccs[i].ERP7__Allocation_Percentage__c != null && itemAccs[i].ERP7__Allocation_Percentage__c != ''){
                            if(itemAccs[i].ERP7__Allocation_Percentage__c > 0) TotalAAPercentage += parseFloat(itemAccs[i].ERP7__Allocation_Percentage__c);
                        }
                    }
                }
            }
            component.set("v.TotalAAPercentage",TotalAAPercentage);
            Polii.TotalAAPercentage = TotalAAPercentage;
            component.set("v.AllPOs.POlist",polist);
        } catch (e) { console.log('updateACTaxPerentage err~>'+e); }
    },
handleFilesChange: function(component, event, helper) {
    try {
        // Get the row index from the title attribute
        var index = event.getSource().get("v.title");
        var templist = component.get("v.AllPOs.POlist");
        var auto = templist[index].PO;
        var Llist = auto.Llist || [];
        var fName = auto.fileName || [];
        var fileInput = event.getSource().get("v.files");
        var fileName = 'No File Selected..';

        // Validation variables
        var singleFileMaxSize = 2 * 1024 * 1024; // 2 MB in bytes
        var totalFileMaxSize = 6 * 1024 * 1024; // 6 MB in bytes
        var totalSize = 0;

        if (fileInput && fileInput.length > 0) {
            // Calculate the current total size of already uploaded files
            for (let i = 0; i < Llist.length; i++) {
                totalSize += Llist[i].size;
            }

            // Loop through newly selected files and validate sizes
            for (let i = 0; i < fileInput.length; i++) {
                let file = fileInput[i];

                // Check individual file size
                if (file.size > singleFileMaxSize) {
                    alert('File "' + file.name + '" exceeds the 2 MB size limit.');
                    return; // Exit the function
                }

                // Add file size to total size
                totalSize += file.size;

                // Check cumulative file size
                if (totalSize > totalFileMaxSize) {
                    alert('The total size of all files exceeds the 6 MB limit.');
                    return; // Exit the function
                }

                // Add file to the list if within limits
                if (!fName.includes(file.name)) {
                    fName.push(file.name);
                    Llist.push(file);
                }
            }

            // Update file names for display
            fileName = fName.join(', ');
        } else {
            console.log('No files selected.');
        }

        // Update the specific row in the PO list
        auto.Llist = Llist;
        auto.fileName = fName;
        component.set("v.AllPOs.POlist", templist);

    } catch (e) {
        console.log('AttachmentList err~>', e);
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
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
            try{
                var action = component.get("c.DeleteAttachment");
                action.setParams({
                    attachId: RecordId,
                    parentId: parentId,
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        console.log("DeleteRecordAT resp: ", JSON.stringify(response.getReturnValue()));
                        component.set('v.uploadedFile',response.getReturnValue());
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
                    }
                    else{
                        $A.util.addClass(component.find('mainSpin'), "slds-hide");
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
    imageError: function(component,event,helper){
        console.log('imageError called');
        event.target.style.display = 'none';
    },
    
    removeAttachment : function(component, event, helper) { 
        var index = event.currentTarget.getAttribute("data-index");
        console.log('index',index);
        var templist = component.get("v.AllPOs.POlist");
        var auto= templist[index].PO;
        var fileName = auto.fileName;
        console.log('auto.fileName',auto.fileName);
        var fillList=auto.Llist;
        console.log('auto.fillList bfr',auto.Llist);
        console.log('auto.fileName bfr',auto.fileName);
        fillList.shift();
        fileName.shift();
        console.log('auto.fillList aftr',auto.Llist);
        console.log('auto.fileName aftr',fileName);
        component.set("v.AllPOs.POlist",templist);
        /* var fileName = 'No File Selected..';
        var index = event.currentTarget.getAttribute("data-index");
        console.log('index',index);
        var templist = component.get("v.AllPOs.POlist");
        var auto= templist[index].PO;
        auto.fileName=fileName;
        console.log('auto.fileName',auto.fileName);
        var fillList=auto.fillList;
        console.log('auto.fillList bfr',auto.fillList);
        fillList.splice(0, fillList.length); 
        console.log('auto.fillList aftr',auto.fillList);
        component.set("v.AllPOs.POlist",templist);*/
        
    },
    changeProject: function(component, event, helper) { 
        var currindex = event.currentTarget.name;
        const index = currindex.split('-', 2);
        var POindex = event.currentTarget.getAttribute("data-index");
        var POliindex = index[0];
        var accountindex = index[1];
        console.log('PO index',POindex);
        console.log('POli index',POliindex);
        console.log('Acc index',accountindex);
        var polist= component.get("v.AllPOs.POlist");
        var currAcc=polist[POindex].POLIs[POliindex].Accounts[accountindex];
        console.log('currPO:',polist[POindex]);
        console.log('currPoli:',polist[POindex].POLIs[POliindex]);
        console.log('currAcc:',currAcc);
        
    },
    add: function(component, event, helper) {
        console.log('add called');
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        var POind = event.getSource().get('v.title');
        component.set('v.AddPOInd',POind);
        var poliwrp = component.get('v.AllPOs.POlist');
        var vendId = poliwrp[POind].PO.ERP7__Vendor__c;
        component.set('v.POVendId',vendId);
        var taxx =poliwrp[POind].PO.taxrate;
        component.set('v.defaultTaxRate',taxx);
        component.set('v.listOfProducts',[]);
        component.set('v.selectedListOfProducts',[]);
        component.set('v.searchItem','');
        component.set('v.seachItemFmily','');
        component.set('v.addProductsMsg','');
        helper.getDependentPicklistsFamily(component, event, helper);
        var action = component.get("c.getProducts");
        action.setParams({
            "venId":vendId,
            "searchString": component.get('v.searchItem'),
            "searchFamily": component.get('v.seachItemFmily'),
            "DCId": component.get('v.dChannelId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('response getProducts : ',response.getReturnValue());
                console.log('setting listOfProducts here1');
                component.set('v.listOfProducts',response.getReturnValue().wrapList);
                
                //Added by Arshad 03 Aug 2023
                try{
                    var standProds = component.get('v.listOfProducts');
                    
                    // for(var x in standProds)  Commented by Parveez on 27 Sept 2023
                    for(var x = 0; x < standProds.length; x++){
                        standProds[x].ERP7__Lead_Time_Days__c = standProds[x].prod.ERP7__Purchase_Lead_Time_days__c;
                        standProds[x].ERP7__Vendor__c = vendId;
                         if(standProds[x].prod.ERP7__Approved_Vendors__r != undefined && standProds[x].prod.ERP7__Approved_Vendors__r != null && standProds[x].prod.ERP7__Approved_Vendors__r != ''){
                             for(var y = 0; y < standProds[x].prod.ERP7__Approved_Vendors__r.length; y++){
                                 if(standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Vendor__c == vendId){
                                    standProds[x].ERP7__Lead_Time_Days__c = (standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Lead_Time__c == '' || standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Lead_Time__c == null) ? standProds[x].prod.ERP7__Purchase_Lead_Time_days__c : standProds[x].prod.ERP7__Approved_Vendors__r[y].ERP7__Lead_Time__c; 
                                 }
                             }
                         }
                        if(standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != ''){
                            console.log('in here1 standProds[x].selCostCardId~>'+standProds[x].selCostCardId);
                            var res = standProds[x].selectedCostCard;
                            console.log('standProds[x].selectedCostCard res~>',res);
                            
                            standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                            standProds[x].VendorPartNumber = res.ERP7__Vendor_Part_Number__c;
                            if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                            
                            console.log('defaultTaxRate~>'+component.get("v.defaultTaxRate"));
                            if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                            
                            let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                            console.log('tax  bfr:  ',tax);
                            
                            tax = tax * standProds[x].quantity;
                            
                            standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                            
                            if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                            console.log('unitPrice : ',standProds[x].unitPrice);
                            console.log('quantity : ',standProds[x].quantity);
                            console.log('taxAmount : ',standProds[x].taxAmount);
                            console.log('taxPercent : ',standProds[x].taxPercent);
                            
                            standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                            console.log('TotalPrice : ',standProds[x].TotalPrice);
                        }
                    }
                    console.log('setting listOfProducts here11');
                    component.set('v.listOfProducts',standProds);
                }catch(e){
                    console.log('err~>',e);
                }
                var msg = response.getReturnValue().Msg;
                console.log('Msg----?',msg);
                if(msg != null || msg != '' || msg != undefined) component.set('v.addProductsMsg',response.getReturnValue().Msg);
                console.log('Msg----?',component.get('v.addProductsMsg'));
                component.set('v.globalProdSearch',response.getReturnValue().globalSearch);
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }else{
                console.log('Error addNew:',response.getError());
                component.set("v.exceptionError",response.getError());
                $A.util.addClass(component.find('mainSpin'), "slds-hide");
            }
            component.set("v.showAddProducts",true);
            component.set("v.showStandardProducts",true);
        });
        $A.enqueueAction(action);
        
        /* var poliList = [];
        if(component.get("v.poli") != null) poliList = component.get("v.poli");
        poliList.unshift({sObjectType :'ERP7__Purchase_Line_Items__c',ItemsinStock : 0.0, demand: 0.0,AwaitingStock :0.0, Accounts : [], Category:'', AccAccount:''});
        component.set("v.poli",poliList);
        console.log('pli : '+JSON.stringify(component.get("v.poli")));*/
    },
    fetchProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.searchItem'));
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        helper.getSearchProducts(component);
    },
    backToMainPage : function(component, event, helper) {
        component.set("v.showAddProducts",false);
    },
    closeaddProductsMsg : function(component, event, helper) {
        component.set('v.addProductsMsg','');
    },
    fetchFamilyProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.seachItemFmily'));
        if(component.get('v.seachItemFmily') == '--None--') component.set('v.seachItemFmily','');
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        //helper.getSearchProducts(component);
        helper.familyFieldChange(component, event, helper);
    },
    fetchSubFamilyProducts : function(component, event, helper) {
        console.log('searchItem : ',component.get('v.subItemFmily'));
        if(component.get('v.subItemFmily') == '--None--') component.set('v.subItemFmily','');
        var globalsearch = component.get('v.globalProdSearch');
        console.log('globalsearch : ',globalsearch);
        helper.getSearchProducts(component);
    },
    handleCheckbox: function(component, event, helper) {
        let checkedval = event.getSource().get("v.checked");
        let index = event.getSource().get("v.name");
        var selectedProds = component.get('v.selectedListOfProducts');
        console.log('selectedProds bfr : ',selectedProds);
        if (checkedval && index != null && index != undefined && index != '') {
            console.log('in 1');
            let standProds = component.get('v.listOfProducts');
            for (let i = 0; i < standProds.length; i++) {
                if (i == index || standProds[i].prod.Id == index) {
                    selectedProds.push(standProds[i]);
                }
            }
            component.set('v.selectedListOfProducts', selectedProds);
        } else if (checkedval == false && index != null && index != undefined && index != '') {
            if(selectedProds != undefined && selectedProds != null && selectedProds != []){
                for (let i = selectedProds.length - 1; i >= 0; i--) {
                    if (selectedProds[i].prod.Id == index) {
                        selectedProds.splice(i, 1);
                    }
                }
                component.set('v.selectedListOfProducts', selectedProds); 
            }
        }
        console.log('selectedProds : ',selectedProds);
    },
    
    handleQuantity : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            ///for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].quantity = parseFloat(value);
                    if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                    if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(0);
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here2');
            component.set('v.listOfProducts',standProds);
        }
    },
    
    handleUnitPrice : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].unitPrice  = parseFloat(value);
                    if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                    if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    console.log('unitPrice : ',standProds[x].unitPrice);
                    console.log('quantity : ',standProds[x].quantity);
                    console.log('taxAmount : ',standProds[x].taxAmount);
                    console.log('taxPercent : ',standProds[x].taxPercent);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here3');
            component.set('v.listOfProducts',standProds);
        }
    },
    
    handletaxPercent : function(component, event, helper) {
        let value= event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        if(value != null && value != undefined && value != '' && index != null && index != undefined){
            let standProds = component.get('v.listOfProducts');
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                if(x == index){
                    console.log('in');
                    standProds[x].taxPercent = parseFloat(value);
                    if(standProds[x].unitPrice == null || standProds[x].unitPrice == '' || standProds[x].unitPrice == undefined) standProds[x].unitPrice = parseFloat(0);
                    if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                    let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                    console.log('tax  bfr:  ',tax);
                    tax = tax * standProds[x].quantity;
                    standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                    if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                    standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                    console.log('TotalPrice : ',standProds[x].TotalPrice);
                }
            }
            console.log('setting listOfProducts here4');
            component.set('v.listOfProducts',standProds);
        }
    },
    addProducts : function(component, event, helper) {
        console.log('addProducts callled');
        
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
        
        try{
            component.set('v.successMsg','');
            let customProds = component.get('v.ClistOfProducts');
            let standProds = component.get('v.selectedListOfProducts');
            let productsToAdd = [];
            console.log('Tesetth ');
            var totalAmount = 0.0;
            var tax = 0.0;
            var subtotal = 0.0;
            var totalTax = 0.0;
            //for(var x in standProds){
            for(var x = 0; x < standProds.length; x++){
                let poliadd = {};
                //  if(standProds[x].checkSelected){
                poliadd.AwaitingStock = standProds[x].AwaitStock;
                poliadd.demand = standProds[x].demand; 
                poliadd.ItemsinStock = standProds[x].stock;
                poliadd.ERP7__Product__c = standProds[x].prod.Id;
                poliadd.Name = standProds[x].prod.Name;
                poliadd.ERP7__Cost_Card__c = (standProds[x].selCostCardId != undefined && standProds[x].selCostCardId != null && standProds[x].selCostCardId != '') ? standProds[x].selCostCardId : ''; //added by arshad
                console.log('poliadd.ERP7__Cost_Card__c~>'+poliadd.ERP7__Cost_Card__c);
                poliadd.ERP7__Quantity__c = standProds[x].quantity;
                poliadd.ERP7__Vendor_product_Name__c = (standProds[x].VendorPartNumber == null || standProds[x].VendorPartNumber == '' ||  standProds[x].VendorPartNumber == undefined) ? standProds[x].prod.ERP7__Vendor_product_Name__c : standProds[x].VendorPartNumber;
                poliadd.ERP7__Unit_Price__c = (standProds[x].unitPrice > 0) ? standProds[x].unitPrice :"0";
                poliadd.ERP7__Tax_Rate__c = standProds[x].taxPercent;
                poliadd.ERP7__Tax__c = standProds[x].taxAmount;
                poliadd.ERP7__Total_Price__c = standProds[x].TotalPrice;
                poliadd.ERP7__Vendor__c =  standProds[x].ERP7__Vendor__c ;
                poliadd.TotalAAPercentage=0;
                poliadd.isAccCategoryChanged = false;
                poliadd.ERP7__Description__c = standProds[x].prod.Description;
                poliadd.ERP7__Lead_Time_Days__c = standProds[x].ERP7__Lead_Time_Days__c ; 
                //poliadd.ERP7__Lead_Time_Days__c = standProds[x].prod.ERP7__Purchase_Lead_Time_days__c;
                subtotal = subtotal + (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice));
                totalAmount = totalAmount + (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                tax = (poliadd.ERP7__Unit_Price__c/100)*poliadd.ERP7__Tax_Rate__c;
                tax = (tax) * poliadd.ERP7__Quantity__c;
                totalTax = totalTax + tax;
                console.log('poliadd : ',poliadd);
                productsToAdd.push(poliadd); 
                /*var prodlist = component.get('v.plolist.poli');
                console.log('standProds[x].AwaitStock',JSON.stringify(standProds[x].AwaitStock));
                prodlist.unshift({pli:{ERP7__Product__c: standProds[x].prod.Id, Name:standProds[x].prod.Name}, AwaitingStocks: standProds[x].AwaitStock, Demand: standProds[x].demand, Stock: standProds[x].stock});
                component.set('v.plolist.poli',prodlist);
                console.log('prodlist',prodlist);*/
                // } 
            }
            var prodlist = component.get('v.plolist.poli');
            var add = true;
            for(var i in productsToAdd){
                for(var x in prodlist) {
                    if(productsToAdd[i].ERP7__Product__c == prodlist[x].pli.ERP7__Product__c){
                        add= false;
                    }
                } 
                if(add){
                    prodlist.unshift({pli:{ERP7__Product__c: productsToAdd[i].ERP7__Product__c, Name:productsToAdd[i].Name}, AwaitingStocks: productsToAdd[i].AwaitingStock, Demand: productsToAdd[i].demand, Stock: productsToAdd[i].ItemsinStock});                    
                }
            }
            
            console.log('Tedwewrsetth ');
            var NameLabel = $A.get('$Label.c.Enter_Name');
            //for(var y in customProds){
            for(var y = 0; y < customProds.length; y++){
                let poliadd = {};
                if(customProds[y].Name != null && customProds[y].Name != undefined && customProds[y].Name != '' && customProds[y].Name != NameLabel){
                    poliadd.Name = customProds[y].Name;
                    poliadd.ERP7__Quantity__c = customProds[y].quantity;
                    poliadd.ERP7__Unit_Price__c = (customProds[y].unitPrice > 0) ? customProds[y].unitPrice : "0";
                    poliadd.ERP7__Tax_Rate__c = customProds[y].taxPercent;
                    poliadd.ERP7__Tax__c = customProds[y].taxAmount;
                    poliadd.ERP7__Total_Price__c = customProds[y].TotalPrice;
                    poliadd.ERP7__Description__c = customProds[y].Description;
                    poliadd.CustomProd = customProds[y].CustomProd;
                    subtotal = subtotal + (parseFloat(customProds[y].quantity) * parseFloat(customProds[y].unitPrice));
                    totalAmount = totalAmount + (parseFloat(customProds[y].quantity) * parseFloat(customProds[y].unitPrice)) + parseFloat(customProds[y].taxAmount);
                    tax = (poliadd.ERP7__Unit_Price__c/100)*poliadd.ERP7__Tax_Rate__c;
                    tax = (tax) * poliadd.ERP7__Quantity__c;
                    totalTax = totalTax + tax;
                    productsToAdd.push(poliadd);
                }
            }
            
            console.log('productsToAdd : ',productsToAdd.length);
            if(productsToAdd.length > 0){
                var POind = component.get('v.AddPOInd');
                let poliwrp = component.get('v.AllPOs.POlist');
                let polilst = poliwrp[POind].POLIs;
                //let polilst = component.get('v.poli');
                console.log('polilst bfr: ',polilst.length);
                //if(component.get('v.poli') != null && component.get('v.poli') != undefined) polilst = component.get('v.poli');
                polilst = polilst.concat(productsToAdd);
                console.log('polilst after: ',polilst.length);
                poliwrp[POind].POLIs = polilst ;
                console.log('polilst after: ',poliwrp);
                component.set('v.AllPOs.POlist',poliwrp);
                console.log('polilst after: ',polilst);
                console.log('AllPOs.POlist after: ',component.get('v.AllPOs.POlist'));
                component.set('v.showAddProducts',false);
                /*component.set('v.TotalAmount',totalAmount);
                component.set("v.PO.ERP7__Total_Amount__c",totalAmount);
                component.set("v.SubTotal",subtotal);
                component.set("v.TotalTax",totalTax);*/
                
                component.set('v.successMsg','Products addedd successfully!');
                window.setTimeout( $A.getCallback(function() {  component.set('v.successMsg',''); }),5000);
            }
            else{
                component.set('v.addProductsMsg','Please select products to add!');
                window.setTimeout( $A.getCallback(function() {  component.set('v.addProductsMsg',''); }), 5000 );
            }
        }
        catch(err){
            console.log('error : ',err);
        }
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
        helper.updateAmounts(component);
    },
    closeError : function (component, event) {
        component.set("v.exceptionError",'');
        component.set("v.successMsg",'');
    },
    handleCostCardChange: function(component, event, helper) {
        try{
            console.log('handleCostCardChange called');
            
            var index = event.currentTarget.getAttribute("data-index");
            console.log("handleCostCardChange index-: " + index);
            
            if(index != undefined && index != null){
                var standProds = component.get('v.listOfProducts');
                
                var value = (standProds[index].selCostCardId != undefined && standProds[index].selCostCardId != null && standProds[index].selCostCardId != '') ? standProds[index].selCostCardId : '';
                console.log('handleCostCardChange value~>' + value);
                
                if(value != ''){
                    console.log('getPrice calling value~>'+value);
                    var action = component.get("c.fetchPrice2");
                    action.setParams({
                        "ccId": value
                    });
                    action.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            if(response.getReturnValue() != null){
                                var res = response.getReturnValue().costcard;
                                console.log('res~>',res);
                                if (res != null) {
                                    
                                    //for(var x in standProds){
                                    for(var x = 0; x < standProds.length; x++){
                                        if(x == index){
                                            console.log('in here1 res.ERP7__Cost__c~>'+res.ERP7__Cost__c);
                                            standProds[x].selectedCostCard = res;
                                            if(res.ERP7__Vendor_Part_Number__c != null && res.ERP7__Vendor_Part_Number__c != '' && res.ERP7__Vendor_Part_Number__c != undefined) standProds[x].VendorPartNumber = res.ERP7__Vendor_Part_Number__c;
                                            else standProds[x].VendorPartNumber = res.ERP7__Product__r.ERP7__Vendor_product_Name__c;
                                            standProds[x].unitPrice  = parseFloat(res.ERP7__Cost__c);
                                            
                                            if(standProds[x].quantity == null || standProds[x].quantity == '' || standProds[x].quantity == undefined) standProds[x].quantity = parseFloat(0);
                                            
                                            console.log('defaultTaxRate~>'+component.get("v.defaultTaxRate"));
                                            if(standProds[x].taxPercent == null || standProds[x].taxPercent == '' || standProds[x].taxPercent == undefined) standProds[x].taxPercent = parseFloat(component.get("v.defaultTaxRate"));
                                            
                                            let tax = (standProds[x].unitPrice /100) * standProds[x].taxPercent;
                                            console.log('tax  bfr:  ',tax);
                                            
                                            tax = tax * standProds[x].quantity;
                                            
                                            standProds[x].taxAmount = tax.toFixed($A.get("$Label.c.DecimalPlacestoFixed"));
                                            
                                            if(standProds[x].taxAmount == null || standProds[x].taxAmount == '' || standProds[x].taxAmount == undefined) standProds[x].taxAmount = parseFloat(0);
                                            console.log('unitPrice : ',standProds[x].unitPrice);
                                            console.log('quantity : ',standProds[x].quantity);
                                            console.log('taxAmount : ',standProds[x].taxAmount);
                                            console.log('taxPercent : ',standProds[x].taxPercent);
                                            
                                            standProds[x].TotalPrice = (parseFloat(standProds[x].quantity) * parseFloat(standProds[x].unitPrice)) + parseFloat(standProds[x].taxAmount);
                                            console.log('TotalPrice : ',standProds[x].TotalPrice);
                                        }
                                    }
                                    console.log('setting listOfProducts here3');
                                    component.set('v.listOfProducts',standProds);
                                }
                            } else{
                                console.log('getPrice response  null');
                            }
                            
                        }else{
                            console.log('getPrice Exception Occured~>',JSON.stringify(response.getError()));  
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        }catch(e){
            console.log('err~>',e);
        }
    },
})