public with sharing class CredentialsSetupController {

    public Boolean newCred                 { get; set; }
    public Boolean errorMsg                { get; set; }
    public String  exceptionMsg            { get; set; }
    public String  credentialId            { get; set; }
    public String  selectedValue           { get; set; }
    public String  credentialFields        { get; set; }

    public Credentials__c upsCred          { get; set; }
    public Credentials__c PaymentCred      { get; set; }
    public Credentials__c PayPalCred       { get; set; }
    public Credentials__c fedexCred        { get; set; }
    public Credentials__c eCommCred        { get; set; }
    public Credentials__c ocrCred          { get; set; }   // OCR
    public Credentials__c editCredentials  { get; set; }
    public List<Credentials__c> existingList { get; set; }

    // Constructor
    public CredentialsSetupController() {
        try {
            credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            errorMsg         = false;
            newCred          = false;
            selectedValue    = 'Payment';

            PaymentCred      = new Credentials__c();
            PayPalCred       = new Credentials__c();
            upsCred          = new Credentials__c();
            fedexCred        = new Credentials__c();
            eCommCred        = new Credentials__c();
            ocrCred          = new Credentials__c();
            editCredentials  = new Credentials__c();
            existingList     = new List<Credentials__c>();

            if (Schema.sObjectType.ERP7__Credentials__c.isAccessible()) {
                UtilClass.FlSCheck(credentialFields.split(','), 'ERP7__Credentials__c');
            }
            fetchAvailableCredentials();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                e.getMessage() + ' Line Number @ : ' + e.getLineNumber()
            ));
        }
    }

    // Fetch existing credential list for the selected tab
    public void fetchAvailableCredentials() {
        try {
            if (selectedValue != null) {
                String searchString = '%' + String.escapeSingleQuotes(selectedValue) + '%';
                if (Schema.sObjectType.Credentials__c.isAccessible()) {
                    existingList = Database.query(
                        'SELECT ' + String.escapeSingleQuotes(credentialFields) +
                        ' FROM Credentials__c WHERE Type__c LIKE :searchString ORDER BY Name ASC'
                    );
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                e.getMessage() + ' Line Number @ : ' + e.getLineNumber()
            ));
        }
    }

    // Create/Update a credential record
    public PageReference saveCredentials() {
        Blob cryptoKey, userData, passwordData;

        if (selectedValue.equalsIgnoreCase('Payment')) {

            if (PaymentCred != null) {
                cryptoKey = Crypto.generateAesKey(256);
                if (cryptoKey != null && Schema.sObjectType.Credentials__c.fields.Encrypted_Key__c.isAccessible())
                    PaymentCred.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);

                if (editCredentials.Username_Login__c != null) {
                    if (editCredentials.Username_Login__c == PaymentCred.Username_Login__c) {
                        if (PaymentCred.Username_Login__c != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                            userData = Blob.valueOf(PaymentCred.Username_Login__c);
                    }
                    cryptoKey = EncodingUtil.convertFromHex(editCredentials.Encrypted_Key__c);
                } else {
                    if (PaymentCred.Username_Login__c != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                        userData = Blob.valueOf(PaymentCred.Username_Login__c);
                }

                if (editCredentials.Password_Transkey__c != null) {
                    if (editCredentials.Password_Transkey__c == PaymentCred.Password_Transkey__c) {
                        if (PaymentCred.Password_Transkey__c != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                            passwordData = Blob.valueOf(PaymentCred.Password_Transkey__c);
                    }
                    cryptoKey = EncodingUtil.convertFromHex(editCredentials.Encrypted_Key__c);
                } else {
                    if (PaymentCred.Password_Transkey__c != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                        passwordData = Blob.valueOf(PaymentCred.Password_Transkey__c);
                }

                if (userData != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                    PaymentCred.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
                if (passwordData != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                    PaymentCred.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));

                try {
                    if (!newCred) {
                        if (Schema.sObjectType.Credentials__c.isUpdateable())
                            DMLManager.updateAsUser(PaymentCred);
                    } else {
                        PaymentCred.Type__c = 'Payment';
                        if (Schema.sObjectType.Credentials__c.isCreateable())
                            DMLManager.insertAsUser(PaymentCred);
                    }
                    errorMsg = false;
                    fetchAvailableCredentials();
                    PaymentCred = new Credentials__c();
                } catch (Exception e) { /* swallow */ }
            }

        } else if (selectedValue.equalsIgnoreCase('Shipment')) {

            if (upsCred != null) {
                cryptoKey = Crypto.generateAesKey(256);
                if (cryptoKey != null && Schema.sObjectType.Credentials__c.fields.Encrypted_Key__c.isAccessible())
                    upsCred.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);

                if (editCredentials.Username_Login__c != null) {
                    if (editCredentials.Username_Login__c == upsCred.Username_Login__c) {
                        if (upsCred.Username_Login__c != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                            userData = Blob.valueOf(upsCred.Username_Login__c);
                    }
                    cryptoKey = EncodingUtil.convertFromHex(editCredentials.Encrypted_Key__c);
                } else {
                    if (upsCred.Username_Login__c != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                        userData = Blob.valueOf(upsCred.Username_Login__c);
                }

                if (editCredentials.Password_Transkey__c != null) {
                    if (editCredentials.Password_Transkey__c.equalsIgnoreCase(upsCred.Password_Transkey__c)) {
                        if (upsCred.Password_Transkey__c != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                            passwordData = Blob.valueOf(upsCred.Password_Transkey__c);
                    }
                    cryptoKey = EncodingUtil.convertFromHex(editCredentials.Encrypted_Key__c);
                } else {
                    if (upsCred.Password_Transkey__c != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                        passwordData = Blob.valueOf(upsCred.Password_Transkey__c);
                }

                if (userData != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                    upsCred.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
                if (passwordData != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                    upsCred.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));

                try {
                    if (!newCred) {
                        if (Schema.sObjectType.Credentials__c.isUpdateable())
                            DMLManager.updateAsUser(upsCred);
                    } else {
                        upsCred.Type__c = 'Shipment';
                        if (Schema.sObjectType.Credentials__c.isCreateable())
                            DMLManager.insertAsUser(upsCred);
                    }
                    errorMsg = false;
                    fetchAvailableCredentials();
                    upsCred = new Credentials__c();
                } catch (Exception e) { /* swallow */ }
            }

        } else if (selectedValue.equalsIgnoreCase('eComm')) {

            if (eCommCred != null) {
                try {
                    if (!newCred) {
                        if (Schema.sObjectType.Credentials__c.isUpdateable())
                            DMLManager.updateAsUser(eCommCred);
                    } else {
                        eCommCred.Type__c = 'eComm';
                        if (Schema.sObjectType.Credentials__c.isCreateable())
                            DMLManager.insertAsUser(eCommCred);
                    }
                    errorMsg = false;
                    fetchAvailableCredentials();
                    eCommCred = new Credentials__c();
                } catch (Exception e) { /* swallow */ }
            }

        } else if (selectedValue.equalsIgnoreCase('OCR')) {

            if (ocrCred != null) {
                // Map Endpoint (ERP7__End_Point__c) -> required standard URL__c
                if ((ocrCred.URL__c == null || ocrCred.URL__c == '') && ocrCred.ERP7__End_Point__c != null) {
                    ocrCred.URL__c = ocrCred.ERP7__End_Point__c;
                }

                try {
                    if (!newCred) {
                        if (Schema.sObjectType.Credentials__c.isUpdateable())
                            DMLManager.updateAsUser(ocrCred);
                    } else {
                        ocrCred.Type__c = 'OCR';
                        if (Schema.sObjectType.Credentials__c.isCreateable())
                            DMLManager.insertAsUser(ocrCred);
                    }
                    errorMsg = false;
                    fetchAvailableCredentials();
                    ocrCred = new Credentials__c();
                } catch (Exception e) { /* swallow */ }
            }
        }

        return null;
    }

    // Prepare edit form for existing credential
    public PageReference editCredential() {
        errorMsg = true;

        try {
            Blob cryptoKey, decryptedData, decryptedPass;

            if (credentialId != null && String.isNotEmpty(credentialId)) {
                if (Schema.sObjectType.Credentials__c.isAccessible()) {
                    editCredentials = Database.query(
                        'SELECT ' + String.escapeSingleQuotes(credentialFields) +
                        ' FROM Credentials__c WHERE Id = \'' + String.escapeSingleQuotes(credentialId) + '\''
                    );
                }

                if (selectedValue.equalsIgnoreCase('Payment')) {
                    if (editCredentials.Encrypted_Key__c != null && Schema.sObjectType.Credentials__c.fields.Encrypted_Key__c.isAccessible())
                        cryptoKey = EncodingUtil.convertFromHex(editCredentials.Encrypted_Key__c);

                    if (editCredentials.Username_Login__c != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                        decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.convertFromHex(editCredentials.Username_Login__c));
                    if (editCredentials.Password_Transkey__c != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                        decryptedPass = Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.convertFromHex(editCredentials.Password_Transkey__c));

                    if (decryptedData != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                        editCredentials.Username_Login__c = decryptedData.toString();
                    if (decryptedPass != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                        editCredentials.Password_Transkey__c = decryptedPass.toString();

                    PaymentCred = editCredentials;
                    newCred = false;

                } else if (selectedValue.equalsIgnoreCase('Shipment')) {
                    if (editCredentials.Encrypted_Key__c != null && Schema.sObjectType.Credentials__c.fields.Encrypted_Key__c.isAccessible())
                        cryptoKey = EncodingUtil.convertFromHex(editCredentials.Encrypted_Key__c);
                    if (editCredentials.Username_Login__c != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                        decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.convertFromHex(editCredentials.Username_Login__c));
                    if (editCredentials.Password_Transkey__c != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                        decryptedPass = Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.convertFromHex(editCredentials.Password_Transkey__c));

                    if (decryptedData != null && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())
                        editCredentials.Username_Login__c = decryptedData.toString();
                    if (decryptedPass != null && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible())
                        editCredentials.Password_Transkey__c = decryptedPass.toString();

                    upsCred = editCredentials;
                    newCred = false;

                } else if (selectedValue.equalsIgnoreCase('eComm')) {
                    eCommCred = editCredentials;
                    newCred = false;

                } else if (selectedValue.equalsIgnoreCase('OCR')) {
                    // Show stored URL in the Endpoint field when editing
                    if (editCredentials.URL__c != null
                        && (editCredentials.ERP7__End_Point__c == null || editCredentials.ERP7__End_Point__c == '')) {
                        editCredentials.ERP7__End_Point__c = editCredentials.URL__c;
                    }
                    ocrCred = editCredentials;
                    newCred = false;
                }

            } else {
                PaymentCred = new Credentials__c();
                upsCred     = new Credentials__c();
                PayPalCred  = new Credentials__c();
                fedexCred   = new Credentials__c();
                eCommCred   = new Credentials__c();
                ocrCred     = new Credentials__c();
                newCred     = true;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                e.getMessage() + ' Line Number @ : ' + e.getLineNumber()
            ));
        }
        return null;
    }

    // Delete existing credential
    public PageReference deleteCredential() {
        try {
            if (credentialId != null && Schema.sObjectType.Credentials__c.isDeletable())
                DMLManager.deleteAsUser(new Credentials__c(Id = credentialId));
            fetchAvailableCredentials();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                e.getMessage() + ' Line Number @ : ' + e.getLineNumber()
            ));
        }
        return null;
    }

    public PageReference cancelCredential() {
        errorMsg = false;
        return null;
    }
}