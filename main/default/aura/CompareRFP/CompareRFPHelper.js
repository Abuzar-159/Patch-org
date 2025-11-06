({
	setRfpDetails : function(component, event, reqIndex, resIndex) {
        $A.util.removeClass(component.find('mainSpin'), "slds-hide");
      
		var action = component.get("c.fetchAllSupDetails");
        action.setParams({
            reqId : component.get("v.requestId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                try{
                    $A.util.addClass(component.find('mainSpin'), "slds-hide");
                   
                    if(response.getReturnValue().errorMsg == ''){
                        console.clear();
                        
                        var supList = response.getReturnValue().supplierList;
                        var totalscore = 0.00;
                        var totalrating = 0.00;
                        console.log('res: ',supList);
                        for(var i in supList){                                
                            totalscore=0.00;
                            totalrating=0.00;
                            for(var j in supList[i].supResList){
                                if(supList[i].supResList[j].ERP7__Score__c != undefined) totalscore += supList[i].supResList[j].ERP7__Score__c;
                                if(supList[i].supResList[j].ERP7__Actual_Rating__c != undefined) totalrating += Number(supList[i].supResList[j].ERP7__Actual_Rating__c);
                            }
                            //alert(totalrating);
                            if(totalscore > 0 && supList[i].supResList.length > 0) supList[i].avgScore = totalscore/(supList[i].supResList.length);
                            if(totalscore > 0 && supList[i].supResList.length > 0) supList[i].avgRating = totalrating/(supList[i].supResList.length);
                            console.log('supList[',i,'].supResList.length: ',supList[i].supResList.length);
                        }
                        
                        
                        /*ratingElement = Array.isArray(ratingElement) ? ratingElement[0].getElement() : ratingElement.getElement();
                        alert(supList[0].avgRating);
                        var ratng = supList[0].avgRating;
                        $( ratingElement ).raty({
                            starOff  : '/resource/RatingPlugin/images/star_off_darkgray.png',
                            starOn   : '/resource/RatingPlugin/images/star_on.png'
                        });
                        $(ratingElement).raty('set', { 
                            score: ratng,
                            readOnly: true 
                        });//
                        $(".star-rating").toggle();
                        */
                         
                        component.set("v.reqSuppliers", supList);
                        component.set("v.RFPWrap", response.getReturnValue());
                        component.set("v.request", response.getReturnValue().request);
                        component.set("v.showReceive", response.getReturnValue().showReceive);
                        console.log('coming?', component.get("v.showReceive"));
                        
                       
                    }
                    else{
                        component.set("v.exceptionError",response.getReturnValue().errorMsg);
                        setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                        component.set("v.allowReq",false);
                    }
                }
                catch(ex){
                    component.set("v.exceptionError", ex);
                }
                
            }
            else{
                var errors = response.getError();
                console.log("err -> ", errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.exceptionError",errors[0].message);
                         setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                    else if(errors[0].pageErrors[0].message){
                        component.set("v.exceptionError", errors[0].pageErrors[0].message);
                         setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                    }
                }
                else{
                    component.set("v.exceptionError","Unknown error");
                    setTimeout(
                            $A.getCallback(function() {
                                component.set("v.exceptionError","");
                            }), 3000
                        );
                }
            }
            $A.util.addClass(component.find('mainSpin'), "slds-hide");
        });
        $A.enqueueAction(action);
	},
})