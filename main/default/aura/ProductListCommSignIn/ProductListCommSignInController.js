({
    
   /* hideSignIn : function(cmp, event, helper) {
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ hideRegister: true});
        evt.fire(); 
    }*/
     hidereset:function(cmp, event, helper){
         cmp.set("v.forgotPassword",false); //SupplierPortal
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ hideRegister: true});
        evt.fire(); 
    },
    signIn : function(cmp, event, helper){
        try{
            console.log('signIn called');
            cmp.set("v.errMsg","");
            cmp.set("v.mylabel1","");
            
            var urlReturn = helper.getParameterByName(cmp, event, 'returl');	//null
            urlReturn = window.location.href;	//current URL
            
            //community event content
            
            var validForm = cmp.find('FormVal').reduce(
                function(validSoFar,inputCmp) {
                    // Displays error messages for invalid fields
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar &&
                        inputCmp.get(
                        'v.validity'
                    ).valid;
                }, true);
            // If we pass error checking, do some real work
            console.log('Sign In here1');
            if (validForm) {
                // Get the Username from Component
                var user = cmp.get("v.Username");
                var Pass = cmp.get("v.Password");
                
                var action = cmp.get("c.checkPortal");
                var showSecQuestion = cmp.get("v.askForSecurityQuestion");
                action.setParams({
                    username: user,
                    password: Pass,
                    urlReturn: urlReturn,
                    navigateToSec: showSecQuestion
                });
                // Add callback behavior for when response is received
                action.setCallback(this,function(response) {
                    if(response.getState() === 'SUCCESS'){
                        console.log('jSON SIGNIN resp~>'+JSON.stringify(response.getReturnValue()));
                        var rtnValue = response.getReturnValue().url;
                        var ndqn = response.getReturnValue().needQuestion;
                        if (rtnValue.indexOf('failed') !== -1) {
                            console.log('Sign In here2');
                            cmp.set("v.errMsg",rtnValue);
                            //cmp.set("v.showError",true);
                        } else {
                            console.log('Sign In here3');
                            cmp.set("v.mainURL", rtnValue);
                            var showSequeriryQues = helper.needToGetASecurityQuestion(cmp, event, user);
                            //showSequeriryQues == true
                            
                            if (showSequeriryQues == true && ndqn == true) {
                                console.log('Sign In here4');
                                helper.getSecurityQuestion(cmp, event, rtnValue);
                            } else {
                                console.log('Sign In here5');
                                window.open(rtnValue, '_top');                           
                                var evt = $A.get("e.c:ProductListCommEvent");
                                evt.setParams({ hideRegister: true});
                                evt.fire();
                            }
                        }
                    }else{
                        var errors = response.getError();
                        console.log("SIGNIN server error : ", errors);
                    }
                });
                $A.enqueueAction(action);            
            }        
        }catch(e){
            console.log('error signin~>'+e);
        }
    },
    
    verifySequrityQuestion: function(cmp, event, helper) {
        helper.verifySequrityQuestionAndProceed(cmp, event);
    },
    
    passwordReset :function(cmp, event, helper){        
        cmp.set("v.forgotPassword",true);
        var Action = event.currentTarget.getAttribute('data-Action');
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ actionName: "Password Reset"});
        evt.fire(); 
        //cmp.set("v.forgotPassword",true);
    },
    
    submitresetPass : function(cmp, event, helper){
        
    },
    
    registerNow : function(cmp, event, helper){
        var Action = event.currentTarget.getAttribute('data-Action');
        var evt = $A.get("e.c:ProductListCommEvent");
        evt.setParams({ actionName: Action});
        evt.fire();
    },
    
    submitresetPass: function(cmp, event, helper) {
        cmp.set("v.errMsg","");
        cmp.set("v.mylabel","");
        
        
        var validResetForm1 = cmp.find("FormReset").get("v.validity");
        // If we pass error checking, do some real work
        if (validResetForm1.valid) {
            var Reuser1 = cmp.get("v.ResetUsername");
            var action = cmp.get("c.forgotPassowrd");
            action.setParams({
                username: Reuser1
            });
            action.setCallback(this, function(response) {
                var rtnValue = response.getReturnValue();
                cmp.set("v.mylabel1",rtnValue);
                
                if (rtnValue !== null) {
                    /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: rtnValue,
                            message: ' ',
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        */
                        cmp.set("v.errMsg",rtnValue);
                        // cmp.set("v.showError",true);
                        //cmp.set("v.isVisible", true);
                        //cmp.set("v.showSignIn", false);
                    }
            });
            $A.enqueueAction(action);
        }
    },
    
})