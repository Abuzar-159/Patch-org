({
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
        console.log('getSecurityQuestion called');
        var userN = cmp.get("v.Username");		
        
        var action = cmp.get("c.getRandomSecurityQuestion");
        action.setParams({
            userName: userN
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 		
            if(response.getState() === 'SUCCESS'){
                console.log('jSON getSecurityQuestion resp~>'+JSON.stringify(response.getReturnValue()));
                var rtnValue = response.getReturnValue();	
                var ques = rtnValue.question;
                cmp.set("v.askForSecurityQuestion", true);
                cmp.set("v.securityQuestion", rtnValue.question);
                cmp.set("v.randomQuesNumber", rtnValue.randumNumber);
            }else{
                var errors = response.getError();
                console.log("getSecurityQuestion server error : ", errors);
            }
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
})