({
    // To register the user ... Call the Server side method and initiate the user registration process.
    registerUser : function (cmp, event) {
        
        var tempEmail = cmp.get('v.emailInfo');
        var firstName = cmp.get("v.firstNameInfo");
        var middleName = cmp.get("v.middleNameInfo");
        var lastName = cmp.get("v.lastNameInfo");
        var passInfo = 'Test'; //cmp.get("v.passValue");
        var newsLetterSubscription = cmp.get("v.newsLetter");        
        
        var action = cmp.get("c.registerUserSelf");
        action.setParams({
            'email': tempEmail,
            'firstName': firstName,
            'middleName': middleName,
            'lastName': lastName,
            'pass':passInfo,
            newLetterSub:newsLetterSubscription
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();            
            
            if (result === "User Created Successfully"){
                
                cmp.set("v.registerSuccess", true);
                /* $A.createComponent("EventRoK:Register_Success",{
                                   "PortalUser":false
                            },function(newCmp, status, errorMessage){
                                //alert(status);
                                //alert(errorMessage);
                                if (status === "SUCCESS") {
                                    var body = cmp.find("body");
                                    body.set("v.body", newCmp);
                                }
                            });*/
            }
            else{
                if (result != undefined && result != null)
                {	
                    if (result.indexOf('INVALID_EMAIL_ADDRESS') >= 0)
                    {
                        result = 'Please provide a valid email address';        
                    }
                }
                cmp.set("v.errMsg",result);
                try{
                    var errors = response.getError(); 
                    if(errors.length>0) console.log('registerUser errors==>'+errors[0].message); //errors[0].pageErrors[0].message
                }catch(exp){console.log('registerUser exception==>'+exp);}    
                
                
            }
        });
        $A.enqueueAction(action);
    },
})