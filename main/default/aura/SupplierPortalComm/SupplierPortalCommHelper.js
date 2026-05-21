({
	showSignIn : function(cmp, event){
        cmp.set("v.showSignIn", true);
        cmp.set("v.Action", 'Register');
        var Action = cmp.get("v.Action");
        if (Action == 'Register') cmp.set("v.ActionName", 'Register an account');
        cmp.set("v.Spinner", false);
    },
    
    profile :function(cmp,event){
        var UserName;
        var action = cmp.get("c.getProfileId");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('comm prof json~>'+JSON.stringify(response.getReturnValue()));
                cmp.set("v.imageURL",response.getReturnValue().imageURL);
                var UserName = response.getReturnValue().name;
                var UserID=response.getReturnValue().profId;
                var AccId=response.getReturnValue().acc.Id;
                if(response.getReturnValue().acc.Id != undefined) cmp.set("v.AccId",response.getReturnValue().acc.Id);
                 console.log("AccId from SupplierPortalComm", cmp.get("v.AccId"));
                if(UserName != $A.get("$Label.c.Supplier_Community_Guest_User")){ //"ERP Supplier Portal Community Site Guest User"
                    cmp.set("v.PortalUser",true);
                    cmp.set("v.UserName1",UserName);
                    cmp.set("v.UserProfId",UserID );
                    var evt = $A.get("e.c:SupplierPortalCommEvent");
                    evt.setParams({"AccId":AccId});
                    evt.fire();
                }
                //component.set("v.Spinner", false); 
            }else{
                var errors = response.getError();
                console.log("getProfileId error in doInit : ", errors);
}
        });
        $A.enqueueAction(action);
    },
        getParameterByName: function(cmp, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);        
        if (!results) return null;
        if (!results[2]) return '';	
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    needToGetASecurityQuestion: function (cmp, event, username){
        var allCookies = document.cookie;							
        var cname = username + 'apex__sq=true';						
        var name = cname;											
        var decodedCookie = decodeURIComponent(document.cookie);	
        var ca = decodedCookie.split(';');							
        var boolReturn = true
        var cookieValue = '';
        
        for(var i = 0; i <ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                cookieValue = c.substring(name.length, c.length);
                return false;
            }
        }
        return true;
    },
    
    getSecurityQuestion: function (cmp, event, rtnValue){    
        var userN = cmp.get("v.Username");		
        
        var action = cmp.get("c.getRandomSecurityQuestion");
        action.setParams({
            userName: userN
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 			
            var rtnValue = response.getReturnValue();	
            var ques = rtnValue.question;
            cmp.set("v.askForSecurityQuestion", true);
            cmp.set("v.securityQuestion", rtnValue.question);
            cmp.set("v.randomQuesNumber", rtnValue.randumNumber);
            
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },
    
    addCookie: function (username){
       var d = new Date();
    		d.setTime(d.getTime() + (10 * 24 * 60 * 60 * 1000));
    		var expires = "expires="+d.toUTCString();
        var cvalue = 'apex__sq';
    			document.cookie = username + cvalue + "=true" + ";" + expires + ";path=/";
    },
    deleteCookie : function(username){
       var cvalue = 'apex__sq';
       document.cookie = username + cvalue + "=true" +
           ";expires=Thu, 01 Jan 1970 00:00:01 GMT";
	},
    
    verifySequrityQuestionAndProceed: function (cmp, event){
        cmp.set("v.errMsg",'');
        var secAnswerValue = cmp.get("v.securityAnswer");	 
        var sa = false;
        if(secAnswerValue == '' || secAnswerValue == undefined || secAnswerValue == null){
            sa = true; 
            cmp.set("v.errMsg",'* Please answer the security question');
        }
        if(!sa){
            cmp.set("v.errMsg",'');
            var action = cmp.get("c.verifiedSecurityQuestion");        	
            var userN = cmp.get("v.Username");
            var secAnswer =  cmp.get("v.securityAnswer");
            var randomNum   =   cmp.get("v.randomQuesNumber");
            action.setParams({
                userName: userN,
                securityAns:secAnswer,
                randomN:randomNum
            });
            
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
                var state = response.getState();  
                var rtnValue = response.getReturnValue();
                
                if (state == 'SUCCESS'){
                    if (rtnValue == 'Success'){                            
                        var selectedRadioOption = document.getElementById("tokenRadioId").checked;				
                        if (selectedRadioOption == true){
                            this.addCookie(userN);
                        }
                        else{
                            this.deleteCookie(userN)
                        } 
                        var redirectURL = cmp.get("v.mainURL");                            
                        window.open(redirectURL,'_top'); 
                    }
                    else{                            
                        cmp.set("v.errMsg","Invalid Answer, please try again");
                    }
                }
                else{	
                    cmp.set("v.errMsg","Invalid Answer, please try again");
                }                
            });
            $A.enqueueAction(action);
        }
    },
    
    registerUser : function (cmp, event) {
        
        var tempEmail = cmp.get('v.RegisteremailInfo');
        var firstName = cmp.get("v.RegisterfirstNameInfo");
        var middleName = cmp.get("v.RegistermiddleNameInfo");
        var lastName = cmp.get("v.RegisterlastNameInfo");
        var passInfo = 'Test'; //cmp.get("v.passValue");
        var newsLetterSubscription = cmp.get("v.RegisternewsLetter");        
        
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
                //cmp.set("v.errMsg1", JSON.stringify(response.getReturnValue()));
                //cmp.set("v.errMsg1", "User Limit has been exceeded");

                if (result != undefined && result != null)
                {	
                    if (result.indexOf('INVALID_EMAIL_ADDRESS') >= 0)
                    {
                        result = 'Please provide a valid email address';        
                    }
                }
                cmp.set("v.RegistererrMsg",result);
                cmp.set("v.RegistererrMsg","User Limit has been exceeded. Please contact your Administrator.");
                try{
                    var errors = response.getError(); 
                    if(errors.length>0) console.log('registerUser errors==>'+errors[0].message); //errors[0].pageErrors[0].message
                }catch(exp){console.log('registerUser exp==>'+exp);}    
                
                
            }
        });
        $A.enqueueAction(action);
    },
})