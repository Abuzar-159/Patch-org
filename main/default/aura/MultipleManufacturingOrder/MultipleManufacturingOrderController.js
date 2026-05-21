({
    closeError : function(cmp,event){
        cmp.set("v.errorMsg",'');
    },
    
    doInit:function(cmp,event,helper){
        cmp.set("v.Spinner",true);
        var action=cmp.get("c.fetchChannelAndDist");
        action.setCallback(this,function(response){
            if(response.getState() =="SUCCESS"){
                var res=response.getReturnValue();
                cmp.set("v.errorMsg",res.errorMsg);
                if(!$A.util.isEmpty(res.currentSalepoint.Id) && !$A.util.isUndefinedOrNull(res.currentSalepoint.Id)){
                    if(res.DistributionChannels.length == 0){
                        cmp.set('v.errorMsg','Distribution Channel not found on Channel');
                    }
                }
                cmp.set('v.channelId',res.currentSalepoint.Id);
                cmp.set('v.dChannelId',res.DistributionChannels[0].Id);
                cmp.set("v.Spinner",false);
            }else{
                cmp.set("v.Spinner",false);
                console.log('Error :',response.getError());
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+'  '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    
	fetchAllProducts : function(cmp, event, helper) {
        cmp.set("v.Spinner",true);
        $A.util.removeClass(cmp.find("selectedModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("selectedModalBackDrop"), 'slds-backdrop_open');
        var action=cmp.get("c.fetchProducts");
        action.setParams({
            searchText:cmp.get("v.searchText"),
            show:cmp.get("v.show"),
            Offset:0,
            dChannelId:cmp.get("v.dChannelId")
        });
        action.setCallback(this, function(response){
            if(response.getState()=="SUCCESS"){
                var res=response.getReturnValue();
                cmp.set("v.errorMsg",res.errorMsg);
                cmp.set("v.Container",res);
                cmp.set("v.SOAccess",res.SOAccess);
                /*if(!$A.util.isEmpty(res.currentSalepoint.Id) && !$A.util.isUndefinedOrNull(res.currentSalepoint.Id))
                    cmp.set("v.channelId",res.currentSalepoint.Id);
                if(!$A.util.isEmpty(res.DistributionChannels[0].Id) && !$A.util.isUndefinedOrNull(res.DistributionChannels[0].Id))
                    cmp.set("v.dChannelId",res.DistributionChannels[0].Id);*/
                cmp.set("v.Spinner",false);
            }else{
                cmp.set("v.Spinner",false);
                console.log('Error:',response.getError());
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+'  '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
	},
    
    LoadNow : function(cmp, event, helper) {
        //window.scrollTo(0, 0);
        cmp.set("v.Spinner",true);
        var searchtext = cmp.get("v.searchText");
        var offset = cmp.get("v.Container.Offset");        
        if(searchtext == undefined) searchtext = "";        
       
        var action=cmp.get("c.fetchProducts");
        action.setParams({
            searchText:cmp.get("v.searchText"),
            show:cmp.get("v.show"),
            Offset:offset,
            dChannelId:cmp.get("v.dChannelId")
        });
        action.setCallback(this, function(response){
            if(response.getState()=="SUCCESS"){
                var res=response.getReturnValue();
                cmp.set("v.errorMsg",res.errorMsg);
                var selProdStockList=cmp.get("v.selProdStockList");
                for(var i in selProdStockList){
                    for(var j in res.prodStockList){
                        if(selProdStockList[i].prod.Id == res.prodStockList[j].prod.Id)
                            res.prodStockList[j].isSelected=true;
                    }
                }
                cmp.set("v.Container",res);
                cmp.set("v.Spinner",false);
            }else{
                cmp.set("v.Spinner",false);
                console.log('Error:',response.getError());
                var error=response.getError();
                cmp.set("v.errorMsg",error[0].message+'  '+error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
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
    
    multiMOPage : function(cmp,event,helper){
        cmp.set("v.Spinner",true);
        cmp.set("v.flows","multiMOPage");
        cmp.set("v.MOrder2Insert",[]);
        var selProdStockList=cmp.get("v.selProdStockList");
        var selProduct=[];
        for(var i in selProdStockList)
            if(selProdStockList[i].prod.Id !='')
                selProduct.push(selProdStockList[i].prod.Id);
        
        var action=cmp.get("c.fetchVersionAndRouting");
        action.setParams({
            prodList:selProduct
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var res=response.getReturnValue();
                cmp.set("v.errorMsg",res.errorMsg);
                //cmp.set("v.MOrderStatus", res.moStatus);
                var MOrder2Insert=res.MOrder2InsertList;
                var selProdStockList=cmp.get("v.selProdStockList");
                for(var i in MOrder2Insert){
                    for(var j in selProdStockList){
                        if(selProdStockList[j].prod.Id == MOrder2Insert[i].ERP7__Product__c){
                            MOrder2Insert[i].ERP7__Quantity__c=selProdStockList[j].prod.ERP7__MOQ__c;
                        }
                    }
                    
                }
                cmp.set("v.MOrder2Insert",MOrder2Insert);
                cmp.set("v.Spinner",false);
            }else{
                cmp.set("v.Spinner",false);
                var error=response.getError();
                console.log('Error :',error);
                cmp.set("v.errorMsg",error[0].message+'		',error[0].stackTrace);
            }
        });
        $A.enqueueAction(action);
    },
    
    backToInitial : function(cmp,event,helper){
        cmp.set("v.flows","initial");
    },
    
    createMO : function(cmp,event,helper){
        cmp.set("v.Spinner",true);
        var MOrder2Insert=cmp.get("v.MOrder2Insert");
        var isValid=helper.validateFields(cmp,event);
        if(isValid){
            var MOrder2InsertSend=[];
            for(var i in MOrder2Insert)
                if(MOrder2Insert[i].ERP7__Product__c != '')
                    MOrder2InsertSend.push(MOrder2Insert[i]);
            console.log('MOs : ',JSON.stringify(MOrder2InsertSend));
            var action=cmp.get("c.saveMO");
            action.setParams({
                MOrder2Insert:JSON.stringify(MOrder2InsertSend)
            });
            action.setCallback(this, function(resposne){
                if(resposne.getState() == "SUCCESS"){
                    var res=resposne.getReturnValue();
                    cmp.set("v.errorMsg",res.errorMsg);
                    
                    if(res.errorMsg ==''){
                        window.setTimeout(
                            $A.getCallback(function() {
                                var urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                    "url": "/lightning/n/ERP7__Work_Center_Capacity_Planning"
                                });
                                urlEvent.fire();
                            }), 300
                        );
                    }
                    
                    
                    /*var CreatedMOs=res.MOrder2InsertList;
                    cmp.set("v.CreatedMOs",CreatedMOs);
                    cmp.set("v.flows","MOListPage");*/
                    cmp.set("v.Spinner",false);
                }else{
                    cmp.set("v.Spinner",false);
                    var error=resposne.getError();
                    console.log('Error :',error);
                    cmp.set("v.errorMsg",error[0].message+'		',error[0].stackTrace);
                }
            });
            $A.enqueueAction(action);
        }else{cmp.set("v.Spinner",false);}
    },
    
    SelectItem : function(cmp,event,helper){
        cmp.set("v.Spinner",true);
        cmp.set('v.errorMsg','');
        var prodId=event.getSource().get("v.title");
        var isSelect=event.getSource().get("v.checked");
        var Container=cmp.get("v.Container");
        var selProdStockList=cmp.get("v.selProdStockList");
        
        if(!isSelect){
            for(var i in selProdStockList){
                if(selProdStockList[i].prod.Id ==prodId){
                    //selProdStockList.pop(selProdStockList[i]);
                    selProdStockList.splice(i, 1);
                }
            }
        }else{
            for(var i in selProdStockList){
                if(selProdStockList[i].prod.Id ==prodId){
                    cmp.set('v.errorMsg','Product Already Selected');
                    cmp.set("v.Spinner",false);
                    return;
                }
            }
            for(var i in Container.prodStockList){                
                if(isSelect && Container.prodStockList[i].prod.Id==prodId)
                    selProdStockList.push(Container.prodStockList[i]);
            }
        }
        
        
        /*for(var i in Container.prodStockList){
            if(selProdStockList.length > 0){
                if(Container.prodStockList[i].isSelected)
                    selProdStockList.push(Container.prodStockList[i]);
                for(var i in selProdStockList){
                    if(selProdStockList.prod.Id == Container.prodStockList[i].prod.Id && !Container.prodStockList[i].isSelected){
                        selProdStockList.pop(Container.prodStockList[i]);
                    }
                }
            }else{
                if(Container.prodStockList[i].isSelected)
                    selProdStockList.push(Container.prodStockList[i]);
            }
            
        }*/
        cmp.set("v.selProdStockList",selProdStockList);
        cmp.set("v.Spinner",false);
    },
    
    /*openModal:function(cmp,event){
        $A.util.addClass(cmp.find("selectedModal"), 'slds-fade-in-open');
        $A.util.addClass(cmp.find("selectedModalBackDrop"), 'slds-backdrop_open');
    },
    
    closeModal:function(cmp,event){
        $A.util.removeClass(cmp.find("selectedModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("selectedModalBackDrop"), 'slds-backdrop_open');
    },*/
    
    delOpenModal:function(cmp,event){  
        var itemToDel=event.getSource().get("v.title");
        cmp.set("v.itemToDel",itemToDel);
        $A.util.addClass(cmp.find("delModal"),"slds-fade-in-open");
        $A.util.addClass(cmp.find("delModalBackdrop"),"slds-backdrop_open");        
    },
    
    delcloseModal: function(component, event, helper) {
        $A.util.removeClass(component.find("delModal"),"slds-fade-in-open");
        $A.util.removeClass(component.find("delModalBackdrop"),"slds-backdrop_open");
    },
    
    removeItem: function(component,event,helper){
        //var prodId=event.getSource().get("v.title");
        var prodId=component.get("v.itemToDel");
        var selProdStockList=component.get("v.selProdStockList");
        for(var i in selProdStockList){
            if(selProdStockList[i].prod.Id ==prodId){
                selProdStockList.splice(i, 1);
            }
        }
        var MOrder2Insert=[];
        MOrder2Insert=component.get("v.MOrder2Insert");
        
       for(var i in MOrder2Insert){
           if(MOrder2Insert[i].ERP7__Product__c == prodId){
               MOrder2Insert.splice(i, 1);  
           }
                
        }
        component.set("v.selProdStockList",selProdStockList);
        component.set("v.MOrder2Insert",MOrder2Insert);
        
       
        $A.util.removeClass(component.find("delModal"),"slds-fade-in-open");
        $A.util.removeClass(component.find("delModalBackdrop"),"slds-backdrop_open");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Item deleted successfully.",
            "type":"success"
        });
        toastEvent.fire();
        
        component.LoadNow();
    },
    
    /*navigateHome : function(cmp,event,helper){
      	cmp.set("v.flows","initial");
        $A.get('e.force:refreshView').fire();
    },*/
    
    /*hideDiv : function(cmp,event,helper){
        
    },*/
    
    /*updateSel : function(cmp,event,helper){
        
        
        $A.util.removeClass(cmp.find("selectedModal"), 'slds-fade-in-open');
        $A.util.removeClass(cmp.find("selectedModalBackDrop"), 'slds-backdrop_open');
    },*/
})