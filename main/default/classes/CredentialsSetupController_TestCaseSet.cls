@isTest
private class CredentialsSetupController_TestCaseSet {
    
     static testMethod void UnitTestCredentialsSetupController1() {
         Credentials__c cred = new Credentials__c(Name = 'Test Cred', Username_Login__c = 'Test uname', Password_Transkey__c = 'Test pass',
                               URL__c = 'Test url');
         insert cred;
         
         CredentialsSetupController cont = new CredentialsSetupController();
         Test.startTest();
             cont.selectedValue = 'Payment';
             cont.PaymentCred.Name = cred.Name;
             cont.PaymentCred.Username_Login__c = cred.Username_Login__c;
             cont.PaymentCred.Password_Transkey__c = cred.Password_Transkey__c;
             cont.PaymentCred.URL__c = cred.URL__c;
             cont.saveCredentials();
             
             cont.selectedValue = 'Shipment';
             cont.upscred.Name = cred.Name;
             cont.upscred.Username_Login__c = cred.Username_Login__c;
             cont.upscred.Password_Transkey__c = cred.Password_Transkey__c;
             cont.upscred.URL__c = cred.URL__c;
             cont.saveCredentials();
             
             cont.selectedValue = 'eComm';
             cont.eCommCred.Name = cred.Name;
             cont.eCommCred.Username_Login__c = cred.Username_Login__c;
             cont.eCommCred.Password_Transkey__c = cred.Password_Transkey__c;
             cont.eCommCred.URL__c = cred.URL__c;
             cont.saveCredentials();   
             cont.cancelCredential();
         
             cont.exceptionMsg = '';
             cont.credentialId = cred.Id;
             
             
            
             cont.selectedValue = 'Payment';
             try { cont.editCredential(); } catch(Exception e) {} 
             
             cont.selectedValue = 'Shipment';
             try { cont.editCredential();  } catch(Exception e) {}
             
             cont.selectedValue = 'eComm';
             try { cont.editCredential();  } catch(Exception e) {}
         
             cont.deleteCredential();
             System.assertEquals(cred.Name, 'Test Cred');
         Test.stopTest();
     }    
}