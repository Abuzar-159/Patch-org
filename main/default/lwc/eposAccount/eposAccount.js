import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateAccInfo from "@salesforce/apex/Epos.updateAccInfo";
import insertNewAcc from "@salesforce/apex/Epos.insertNewAcc";
import insertContact from "@salesforce/apex/Epos.insertContact";
import getDependentMap from "@salesforce/apex/Epos.getDependentMap";
import createNewAddress from "@salesforce/apex/Epos.createNewAddress";

//Label &nbsp; {labels.Create}&nbsp;{labels.Account}
import Company from '@salesforce/label/c.Company';
import Phone from '@salesforce/label/c.Phone_AddTimeCardEntry';
import Profile from '@salesforce/label/c.SalesOrderNewCustomerAndContact_Profile';
import Account from '@salesforce/label/c.Account_Outbound_logistics';
import AccountNumber from '@salesforce/label/c.Select_Bank_Payment_Method_Account_Number';
import VAT_Registration_No from '@salesforce/label/c.SupplierRegistration_VAT_Registration_No';
import Create from '@salesforce/label/c.Transfer_Order_Create';
import Contact from '@salesforce/label/c.ContractConsole_Contact';
import Address from '@salesforce/label/c.PurchaseOrderPDF_Address';
import Name from '@salesforce/label/c.StockTakeName';
import Order_Profile from '@salesforce/label/c.UPS_Order_Profile';
import Description from '@salesforce/label/c.MOsetupProductName';
import Cancel from '@salesforce/label/c.Cancel_ManageLeave';
import First_Name from '@salesforce/label/c.ContractConsole_First_Name';
import Last_Name from '@salesforce/label/c.ContractConsole_Last_Name';
import Mobile_Number from '@salesforce/label/c.UPS_Setup_Mobile_Number';
import Address_line_1 from '@salesforce/label/c.Address_line_1';
import Address_line_2 from '@salesforce/label/c.Address_line_2';
import City from '@salesforce/label/c.City';
import Country from '@salesforce/label/c.UPS_Setup_Country';
import State_Province from '@salesforce/label/c.State_Province';
import Postal_Code from '@salesforce/label/c.UPS_Setup_Postal_Code';
import Search from '@salesforce/label/c.Search_Placeholder';
import Address_Line from '@salesforce/label/c.UPS_Address_Line';
import Billing_Address from '@salesforce/label/c.CreateCustomer_Billing_Address';
import Shipping_Address from '@salesforce/label/c.CreateCustomer_Shipping_Address';
import Update from '@salesforce/label/c.Update';
import Is_Person_Account from '@salesforce/label/c.Is_Person_Account';
import Create_Account from '@salesforce/label/c.Create_Account';
import Create_Contact from '@salesforce/label/c.Create_Contact';
import Create_Address from '@salesforce/label/c.Create_Address';
import Is_Primary from '@salesforce/label/c.Is_Primary';
import Select from '@salesforce/label/c.Select';

export default class EposAccount extends LightningElement {
    @track labels={Select, Is_Primary,Create_Address, Create_Contact,Create_Account, Is_Person_Account, Update, Shipping_Address, Billing_Address, Address_Line, Search,Country,State_Province, Postal_Code,City,Address_line_2, Address_line_1, Mobile_Number, Last_Name, First_Name, Cancel, Description, Company,Phone, Profile, Account ,AccountNumber, VAT_Registration_No, Create, Contact, Address, Name, Order_Profile};
    @api order;
    @api accountid;
    @api contactid;
    copyOrderForSave;
    accProfileFilter = " ERP7__Record_Type_Name__c ='Customer'";
    ordProfileFilter = " ERP7__Record_Type_Name__c ='Order_Profile'";
    errorMsg;
    showUpdateAccInfo = false;
    isCreateNewAccount = false;
    newAccError;
    addressToInsert = { ERP7__Customer__r: { Id: '', Name: '' }, ERP7__Contact__r: { Id: '', Name: '' },ERP7__Is_Billing_Address__c:false,ERP7__Is_Shipping_Address__c:false,ERP7__Primary__c:false };
    disableCreateAcc = true;
    spinner = false;
    isCreateNewContact = false;
    newConError;
    disableCreateCon = true;
    conToInsert = { Account: { Id: '', Name: '' } };
    ConAccFilter = "ERP7__Account_Type__c ='Customer'";
    //disableCreateCon = true;

    newAddError;
    isCreateNewAddress = false;
    addressToInsert = { ERP7__Customer__r: { Id: '', Name: '' }, ERP7__Contact__r: { Id: '', Name: '' } };
    disableCreateAdd = true;
    AddConFilter = "AccountId ='" + this.accountid + "'";
    disableAddCon = true;

    depnedentFieldMap;
    listControllingValues;
    bDisabledDependentFld = true;
    listDependingValues;


    handleAccComp(event) {
        try {
            console.log('copyOrderForSave:', this.copyOrderForSave);
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.ERP7__Company__c = event.currentTarget.value;
            this.showUpdateAccInfo = true;
        } catch (e) { console.log('Error:', e); }
    }

    handleAccURL(event) {
        try {
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.Website = event.currentTarget.value;
            this.showUpdateAccInfo = true;
        } catch (e) { console.log('Error:', e); }
    }

    handleAccPhone(event) {
        try {
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.Phone = event.currentTarget.value;
            this.showUpdateAccInfo = true;
        } catch (e) { console.log('Error:', e); }

    }

    handleAccFax(event) {
        try {
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.Fax = event.currentTarget.value;
            this.showUpdateAccInfo = true;
        } catch (e) { console.log('Error:', e); }
    }


    removeAccProfile(event) {
        try {
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.ERP7__Account_Profile__c = undefined;
            this.showUpdateAccInfo = true;
            this.accProfileSelected = this.order.Account.ERP7__Account_Profile__c ? true : false;
        } catch (e) { console.log('Error:', e); }
    }

    selectAccProfile(event) {
        try {
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.ERP7__Account_Profile__c = event.detail.Id;
            this.copyOrderForSave.Account.ERP7__Account_Profile__r.Id = event.detail.Id;
            this.copyOrderForSave.Account.ERP7__Account_Profile__r.Name = event.detail.Name;
            this.accProfileSelected = this.order.Account.ERP7__Account_Profile__c ? true : false;
            this.showUpdateAccInfo = true;
        } catch (e) { console.log('Error:', e); }
    }
    accProfileSelected = false;
    /*get accProfileSelected() {
        if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
        return this.copyOrderForSave.Account.ERP7__Account_Profile__c ? true : false;
    }*/
    get accProfileUrl() {
        if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
        return '/' + this.copyOrderForSave.ERP7__Account_Profile__c;
    }

    handleAccNo(event) {
        try {
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.AccountNumber = event.currentTarget.value;
            this.showUpdateAccInfo = true;
        } catch (e) { console.log('Error:', e); }
    }
    handleTaxReg(event) {
        try {
            if (!this.copyOrderForSave) this.copyOrderForSave = JSON.parse(JSON.stringify(this.order));
            this.copyOrderForSave.Account.ERP7__VAT_registration_number__c = event.currentTarget.value;
            this.showUpdateAccInfo = true;
        } catch (e) { console.log('Error:', e); }
    }

    updateAccountInfo() {
        this.errorMsg = undefined;
        console.log('Account:', this.copyOrderForSave.Account);
        this.spinner = true;
        updateAccInfo({
            acc: JSON.stringify(this.copyOrderForSave.Account),
        })
            .then(result => {
                console.log('result:', result);
                if (result.includes('Account updated successfully')) {
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: result,
                    });
                    this.dispatchEvent(event);
                    this.spinner = false;
                    this.showUpdateAccInfo = false;
                } else {
                    this.errorMsg = result;
                    this.spinner = false;
                }
            })
            .catch(error => {
                console.log("Error:", error);
                this.spinner = false;
                this.errorMsg = error.body.message + '  Line:' + error.body.stackTrace;
            })
    }

    openCreateNewAccModal() {
        this.spinner = true;
        this.newAccError = undefined;
        this.accToInsert = { ERP7__Account_Profile__r: { Id: '', Name: '' }, ERP7__Order_Profile__r: { Id: '', Name: '' } };
        //this.accToInsert.ERP7__Account_Profile__r = { Id: '', Name: '' }
        //this.accToInsert.ERP7__Order_Profile__r = { Id: '', Name: '' }
        this.isCreateNewAccount = true;
        this.spinner = false;
    }

    closeCreateNewAccModal() {
        this.isCreateNewAccount = false;
    }

    handleNewAccName(event) {
        this.accToInsert.Name = event.currentTarget.value;
        this.disableCreateAcc = this.accToInsert.Name && this.accToInsert.Name != '' && this.accToInsert.ERP7__Account_Profile__c && this.accToInsert.ERP7__Account_Profile__r.id != "" && this.accToInsert.ERP7__Order_Profile__c && this.accToInsert.ERP7__Order_Profile__r.Id != '' ? false : true;
    }

    handleNewAccNumber(event) {
        this.accToInsert.AccountNumber = event.currentTarget.value;
    }

    removeNewAccProfile(event) {
        this.accToInsert.ERP7__Account_Profile__c = null;
        this.disableCreateAcc = this.accToInsert.Name && this.accToInsert.Name != '' && this.accToInsert.ERP7__Account_Profile__c && this.accToInsert.ERP7__Account_Profile__r.id != "" && this.accToInsert.ERP7__Order_Profile__c && this.accToInsert.ERP7__Order_Profile__r.Id != '' ? false : true;
    }
    selectNewAccProfile(event) {
        this.accToInsert.ERP7__Account_Profile__c = event.detail.Id;
        this.accToInsert.ERP7__Account_Profile__r = { Id: event.detail.Id, Name: event.detail.Name };
        this.disableCreateAcc = this.accToInsert.Name && this.accToInsert.Name != '' && this.accToInsert.ERP7__Account_Profile__c && this.accToInsert.ERP7__Account_Profile__r.id != "" && this.accToInsert.ERP7__Order_Profile__c && this.accToInsert.ERP7__Order_Profile__r.Id != '' ? false : true;
    }
    get NewAccProfileSelected() {
        return this.accToInsert.ERP7__Account_Profile__c ? true : false;
    }
    get NewAccProfileUrl() {
        return '/' + this.accToInsert.ERP7__Account_Profile__c;
    }

    removeNewOrdProfile() {
        this.accToInsert.ERP7__Order_Profile__c = null;
        this.disableCreateAcc = this.accToInsert.Name && this.accToInsert.Name != '' && this.accToInsert.ERP7__Account_Profile__c && this.accToInsert.ERP7__Account_Profile__r.id != "" && this.accToInsert.ERP7__Order_Profile__c && this.accToInsert.ERP7__Order_Profile__r.Id != '' ? false : true;
    }
    selectNewOrdProfile(event) {
        this.accToInsert.ERP7__Order_Profile__c = event.detail.Id;
        this.accToInsert.ERP7__Order_Profile__r = { Id: event.detail.Id, Name: event.detail.Name };
        this.disableCreateAcc = this.accToInsert.Name && this.accToInsert.Name != '' && this.accToInsert.ERP7__Account_Profile__c && this.accToInsert.ERP7__Account_Profile__r.id != "" && this.accToInsert.ERP7__Order_Profile__c && this.accToInsert.ERP7__Order_Profile__r.Id != '' ? false : true;
    }
    get NewAccOrdProfileSel() {
        return this.accToInsert.ERP7__Order_Profile__c ? true : false;
    }
    get NewOrdProfileUrl() {
        return '/' + this.accToInsert.ERP7__Order_Profile__c;
    }

    handleNewAccEmail(event) {
        this.accToInsert.ERP7__Email__c = event.currentTarget.value;
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (!this.accToInsert.ERP7__Email__c.match(emailRegex)) {
            this.newAccError = 'Enter a valid email address';
        } else {
            this.newAccError = undefined;
        }
    }

    handleNewAccPhone(event) {
        this.accToInsert.Phone = event.currentTarget.value;
    }

    handleNewAccFax(event) {
        this.accToInsert.Fax = event.currentTarget.value;
    }

    handleNewAccCompany(event) {
        this.accToInsert.ERP7__Company__c = event.currentTarget.value;
    }

    handleNewAccWebsite(event) {
        this.accToInsert.Website = event.currentTarget.value;
    }

    handleNewAccVAT(event) {
        this.accToInsert.ERP7__VAT_registration_number__c = event.currentTarget.value;
    }
    handleNewAccDes(event) {
        this.accToInsert.Description = event.currentTarget.value;
    }
    handleNewAccIsPer(event) {
        this.accToInsert.ERP7__Is_Person_Account__c = event.detail.checked;
    }

    newAccountSave() {
        this.newAccError = undefined;
        console.log('Account:', this.accToInsert);

        if (!this.accToInsert.Name || this.accToInsert.Name == "") {
            this.newAccError = 'Name Missing';
            return;
        }

        if (!this.accToInsert.ERP7__Account_Profile__c || this.accToInsert.ERP7__Account_Profile__r.Id == "") {
            this.newAccError = 'Account Profile Missing';
            return;
        }

        if (!this.accToInsert.ERP7__Order_Profile__c || this.accToInsert.ERP7__Order_Profile__r.Id == "") {
            this.newAccError = 'Order Profile Missing';
            return;
        }

        if (this.accToInsert.ERP7__Email__c && this.accToInsert.ERP7__Email__c != '') {
            const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if (!this.accToInsert.ERP7__Email__c.match(emailRegex)) {
                this.newAccError = 'Enter a valid email address';
                return;
            }
        }


        this.spinner = true;
        insertNewAcc({
            acc: JSON.stringify(this.accToInsert),
        })
            .then(result => {
                console.log('result:', result);
                if (!result.includes('Line No:')) {
										this.accountid = result;
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: 'Account Created successfully',
                    });
                    this.dispatchEvent(event);
                    const accCreatedEvent = new CustomEvent('accountcreated', {
                        detail: { Id: result }
                    });
                    this.dispatchEvent(accCreatedEvent);
                    this.spinner = false;
                    this.isCreateNewAccount = false;
                } else {
                    this.newAccError = result;
                    this.spinner = false;
                }
            })
            .catch(error => {
                console.log("Error:", error);
                this.spinner = false;
                this.newAccError = error.body.message + '  Line:' + error.body.stackTrace;
            })
    }

    openCreateNewConModal() {

        console.log('this.AccountId::~>',this.accountid);

        if(this.accountid == '' || this.accountid == null || this.accountid == undefined){

            console.log("Account Id is not Exist::");
            this.newConError = 'Select Account to create a contact';
            const event = new ShowToastEvent({
                title: 'Warning!',
                variant: 'warning',
                message:
                    'Please select an Account to create a contact',
            });
            this.dispatchEvent(event);
        }
        else{
            this.spinner = true;
            this.newConError = undefined;
            this.conToInsert = { Account: { Id:'', Name: '' } };
            this.isCreateNewContact = true;
            this.spinner = false;
            this.conToInsert.AccountId = this.accountid;
            this.conToInsert.Account.Id = this.accountid;
        }

    }

    closeCreateNewConModal() {
        this.isCreateNewContact = false;
    }

    removeNewConAcc(event) {
        this.conToInsert.AccountId = null;
        this.disableCreateCon = this.conToInsert.AccountId && this.conToInsert.LastName && this.conToInsert.LastName != "" ? false : true;
    }
    selectNewConAcc(event) {
        this.conToInsert.AccountId = event.detail.Id;
        this.conToInsert.Account.Id = event.detail.Id;
        this.conToInsert.Account.Name = event.detail.Name;
        this.disableCreateCon = this.conToInsert.AccountId && this.conToInsert.LastName && this.conToInsert.LastName != "" ? false : true;
    }
    get NewConAccSelected() {
        return this.conToInsert.AccountId ? true : false;
    }
    get NewConAccUrl() {
        return '/' + this.conToInsert.AccountId;
    }
    handleNewConFName(event) {
        this.conToInsert.FirstName = event.currentTarget.value;
    }
    handleNewConLName(event) {
        this.conToInsert.LastName = event.currentTarget.value;
        this.disableCreateCon = this.conToInsert.AccountId && this.conToInsert.LastName && this.conToInsert.LastName != "" ? false : true;
    }
    handleNewConCompany(event) {
        this.conToInsert.ERP7__Company__c = event.currentTarget.value;
    }
    handleNewConEmail(event) {
        this.conToInsert.Email = event.currentTarget.value;
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (this.conToInsert.Email && this.conToInsert.Email != '') {
            if (!this.conToInsert.Email.match(emailRegex)) {
                this.newConError = 'Enter a valid email address';
            } else {
                this.newConError = undefined;
            }
        } else {
            this.newConError = undefined;
        }

    }
    handleNewConPhone(event) {
        this.conToInsert.Phone = event.currentTarget.value;
    }
    handleNewConMobPhone(event) {
        this.conToInsert.MobilePhone = event.currentTarget.value;
    }
    handleNewConIsPrim(event) {
        this.conToInsert.ERP7__Primary__c = event.detail.checked;
    }

    newContactSave() {
        console.log('inside newContactSave');
        console.log('this.conToInsert:', this.conToInsert);
        this.newConError = undefined;
        if (!this.conToInsert.AccountId || this.conToInsert.Account == "") {
            this.newConError = 'Account Missing';
            return;
        }

        if (!this.conToInsert.LastName || this.conToInsert.LastName == "") {
            this.newConError = 'Last Name Missing';
            return;
        }

        if (this.conToInsert.Email && this.conToInsert.Email != '') {
            const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if (!this.conToInsert.Email.match(emailRegex)) {
                this.newConError = 'Enter a valid email address';
                return;
            }
        }

        this.spinner = true;
        insertContact({
            con: JSON.stringify(this.conToInsert),
        })
            .then(result => {
                console.log('result:', result);
                if (!result.includes('Line No:')) {
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: 'Contact Created successfully',
                    });
                    this.dispatchEvent(event);
                    const accCreatedEvent = new CustomEvent('contactcreated', {
                        detail: { Id: result, AccId: this.conToInsert.AccountId }
                    });
                    this.dispatchEvent(accCreatedEvent);
                    this.spinner = false;
                    this.isCreateNewContact = false;
                } else {
                    this.newConError = result;
                    this.spinner = false;
                }
            })
            .catch(error => {
                console.log("Error:", error);
                this.spinner = false;
                this.newConError = error.body.message + '  Line:' + error.body.stackTrace;
            })


    }
    
    openCreateNewAddModal() {
        this.newAddError = undefined;
        this.addressToInsert = { ERP7__Customer__r: { Id: '', Name: '' }, ERP7__Contact__r: { Id: '', Name: '' },ERP7__Is_Billing_Address__c:false,ERP7__Is_Shipping_Address__c:false,ERP7__Primary__c:false };
        this.spinner = true;
        getDependentMap({
            contrfieldApiName: 'ERP7__Country__c',
            depfieldApiName: 'ERP7__State__c',
        })
            .then(result => {
                console.log('result:', result);
                // once set #StoreResponse to depnedentFieldMap attribute 
                this.depnedentFieldMap = result;

                // create a empty array for store map keys(@@--->which is controller picklist values) 
                let listOfkeys = []; // for store all map keys (controller picklist values)
                let ControllerField = []; // for store controller picklist value to set on lightning:select. 

                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (let singlekey in this.depnedentFieldMap) {
                    listOfkeys.push(singlekey);
                }

                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push({value:'',label:'--- None ---'});
                }

                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({value:listOfkeys[i],label:listOfkeys[i]});
                }
                // set the ControllerField variable values to country(controller picklist field)
                this.listControllingValues = ControllerField;
                console.log('this.listControllingValues:',this.listControllingValues);
                this.spinner = false;
                this.isCreateNewAddress = true;
                this.addressToInsert.ERP7__Account__C = this.accountid;
                this.addressToInsert.ERP7__Contact__c = this.contactid;
            })
            .catch(error => {
                console.log("Error:", error);
                this.spinner = false;
                this.isCreateNewAddress = true;
                this.newAddError = error.body.message;
            })

    }
    closeCreateNewAddModal() {
        this.isCreateNewAddress = false;
    }

    removeNewAddAcc(event) {
        this.addressToInsert.ERP7__Customer__c = null;
        this.AddConFilter = " AccountId ='" + this.addressToInsert.ERP7__Customer__c + "'";
        this.disableAddCon = true;
        this.addressToInsert.ERP7__Contact__c = null;
        this.addressToInsert.ERP7__Contact__r.Id = '';
        this.addressToInsert.ERP7__Contact__r.Name = '';
        this.disableCreateAdd = this.addressToInsertERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
    }
    selectNewAddAcc(event) {
        this.addressToInsert.ERP7__Customer__c = event.detail.Id;
        this.addressToInsert.ERP7__Customer__r.Id = event.detail.Id;
        this.addressToInsert.ERP7__Customer__r.Name = event.detail.Name;
        this.AddConFilter = " AccountId ='" + this.addressToInsert.ERP7__Customer__c + "'";
				console.log('this.AddConFilter::~>',this.AddConFilter);
        this.disableAddCon = false;
        this.addressToInsert.ERP7__Contact__c = this.contactid;
        this.addressToInsert.ERP7__Contact__r.Id = this.contactid;
        //this.addressToInsert.ERP7__Contact__r.Name = '';
        this.disableCreateAdd = this.addressToInsertERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
    }
    get NewAddAccSelected() {
        return this.addressToInsert.ERP7__Customer__c ? true : false;
    }
    get NewAddAccUrl() {
        return '/' + this.addressToInsert.ERP7__Customer__c;
    }
    removeNewAddCon() {
        this.addressToInsert.ERP7__Contact__c = null;
        this.disableCreateAdd = this.addressToInsertERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
    }
    selectNewAddCon(event) {
        this.addressToInsert.ERP7__Contact__c = event.detail.Id;
        this.addressToInsert.ERP7__Contact__r.Id = event.detail.Id;
        this.addressToInsert.ERP7__Contact__r.Name = event.detail.Name;
        this.disableCreateAdd = this.addressToInsertERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
    }
    get NewAddConSelected() {
        return this.addressToInsert.ERP7__Contact__c ? true : false;
    }

    /*get AddConFilter(){
        return " AccountId =:'"+this.addressToInsert.ERP7__Customer__c+"'";
    }*/
    get NewAddConUrl() {
        return '/' + this.addressToInsert.ERP7__Contact__c;
    }

    handleNewAddLine1(event) {
        this.addressToInsert.ERP7__Address_Line1__c = event.currentTarget.value;
        this.disableCreateAdd = this.addressToInsert.ERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
    }
    handleNewAddLine2(event) {
        this.addressToInsert.ERP7__Address_Line2__c = event.currentTarget.value;
    }
    handleNewAddLine3(event) {
        this.addressToInsert.ERP7__Address_Line3__c = event.currentTarget.value;
    }
    handleNewAddCity(event) {
        this.addressToInsert.ERP7__City__c = event.currentTarget.value;
        this.disableCreateAdd = this.addressToInsert.ERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
    }
    handleNewAddPostal(event) {
        this.addressToInsert.ERP7__Postal_Code__c = event.currentTarget.value;
        this.disableCreateAdd = this.addressToInsert.ERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
    }
    handleNewAddCountry(event) {
        try {
            this.addressToInsert.ERP7__Country__c = event.detail.value;

            var controllerValueKey = this.addressToInsert.ERP7__Country__c; // get selected controller field value
            var depnedentFieldMap = this.depnedentFieldMap;

            if (controllerValueKey != '') {
                var ListOfDependentFields = depnedentFieldMap[controllerValueKey];

                if (ListOfDependentFields.length > 0) {
                    this.bDisabledDependentFld = false;
                    //helper.fetchDepValues(component, ListOfDependentFields);
                    var dependentFields = [];
                    dependentFields.push({value:'',label:'--- None ---'});
                    for (var i = 0; i < ListOfDependentFields.length; i++) {
                        dependentFields.push({value:ListOfDependentFields[i],label:ListOfDependentFields[i]});
                    }
                    // set the dependentFields variable values to store(dependent picklist field) on lightning:select
                    this.listDependingValues = dependentFields;
                } else {
                    this.bDisabledDependentFld = true;
                    this.listDependingValues = [{value:'',label:'--- None ---'}];
                }

            } else {
                this.listDependingValues = [{value:'',label:'--- None ---'}];
                this.bDisabledDependentFld = true;
            }

            this.disableCreateAdd = this.addressToInsert.ERP7__Customer__c && this.addressToInsert.ERP7__Contact__c && this.addressToInsert.ERP7__Address_Line1__c && this.addressToInsert.ERP7__Address_Line1__c != '' && this.addressToInsert.ERP7__City__c && this.addressToInsert.ERP7__City__c != '' && this.addressToInsert.ERP7__Postal_Code__c && this.addressToInsert.ERP7__Postal_Code__c != '' && this.addressToInsert.ERP7__Country__c && this.addressToInsert.ERP7__Country__c != '' ? false : true;
        } catch (e) { console.log('Error:', e); }
    }
    handleNewAddState(event) {
        this.addressToInsert.ERP7__State__c = event.detail.value;
    }
    handleNewAddIsBill(event) {
        this.addressToInsert.ERP7__Is_Billing_Address__c = event.detail.checked;
    }
    handleNewAddIsShip(event) {
        this.addressToInsert.ERP7__Is_Shipping_Address__c = event.detail.checked;
    }
    handleNewAddIsPrimary(event) {
        this.addressToInsert.ERP7__Primary__c = event.detail.checked;
    }
    newAddessSave() {
        try{
            console.log('this.addressToInsert:',this.addressToInsert);
            this.newAddError=undefined;

            if(!this.addressToInsert.ERP7__Customer__c || this.addressToInsert.ERP7__Customer__r.Id ==''){
                this.newAddError='Account Missing';
                return;
            }

            if(!this.addressToInsert.ERP7__Contact__c || this.addressToInsert.ERP7__Contact__r.Id ==''){
                this.newAddError='Contact Missing';
                return;
            }

            if(!this.addressToInsert.ERP7__Address_Line1__c || this.addressToInsert.ERP7__Address_Line1__c ==''){
                this.newAddError='Address Line1 Missing';
                return;
            }

            if(!this.addressToInsert.ERP7__City__c || this.addressToInsert.ERP7__City__c ==''){
                this.newAddError='City Missing';
                return;
            }

            if(!this.addressToInsert.ERP7__Postal_Code__c || this.addressToInsert.ERP7__Postal_Code__c ==''){
                this.newAddError='Postal Code Missing';
                return;
            }

            if(!this.addressToInsert.ERP7__Country__c || this.addressToInsert.ERP7__Country__c ==''){
                this.newAddError='Country Missing';
                return;
            }

            this.spinner = true;
            this.addressToInsert.Name=this.addressToInsert.ERP7__Address_Line1__c;
            this.addressToInsert.ERP7__Organisation__c=this.order.Account.ERP7__Organisation__c;
            this.addressToInsert.ERP7__Active__c=true;
            createNewAddress({
                addrs:JSON.stringify(this.addressToInsert),
            })
            .then(result=>{
                console.log('result:',result);
                if(!result.includes('Line No:')){
                    this.isCreateNewAddress = false;
                    this.spinner = false;
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: 'Address Created successfully',
                    });
                    this.dispatchEvent(event);
                    const accCreatedEvent = new CustomEvent('addresscreated', {
                        detail: { Id: result, isBilling:this.addressToInsert.ERP7__Is_Billing_Address__c, isShipping:this.addressToInsert.ERP7__Is_Shipping_Address__c, accId: this.addressToInsert.ERP7__Customer__c }
                    });
                    this.dispatchEvent(accCreatedEvent);
                }else{
                    this.newAddError=result;
                }
                this.spinner = false;
            })
            .catch(error=>{
                console.log('Error:',error);
                this.newAddError=error.body.message+'   '+error.body.stackTrace;
                this.spinner = false;
            })

        }catch(e){console.log('Error:',e);}

        

    }








    renderedCallback() {
        try {
            console.log('renderedCallback eposAccount');


            this.accProfileSelected = this.order.Account.ERP7__Account_Profile__c ? true : false;

            Promise.all([

            ])
                .then(() => {
                    console.log('Static Resource Loaded');
                })
                .catch(error => {
                    console.log('Static Resource Error', error);
                });
        } catch (e) {
            console.log('Error:', e);
        }
    }



}