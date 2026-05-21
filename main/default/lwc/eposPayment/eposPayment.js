import { LightningElement, api, track, wire } from 'lwc';
import Invoice_Document from '@salesforce/label/c.Invoice_Document';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CMP_CSS from '@salesforce/resourceUrl/CMP_CSS';
import PickPackShipResource from '@salesforce/resourceUrl/PickPackShipResource';
import bootStrap from '@salesforce/resourceUrl/bootStrap';
import SLDS from '@salesforce/resourceUrl/SLDS';
import eposcustom from '@salesforce/resourceUrl/eposcustom';
import ProjectWorkbench from '@salesforce/resourceUrl/ProjectWorkbench';
import fontawesome5 from '@salesforce/resourceUrl/fontawesome5';
//Apex Methods
import { refreshApex } from '@salesforce/apex';
import getInitailCardDetails from "@salesforce/apex/Epos.fetchInitialCardDetails";
import cardPayment from '@salesforce/apex/Epos.createCardPayment';
import upsertInvoice from '@salesforce/apex/Epos.updateInvoice';
import getInitialBankDetails from '@salesforce/apex/Epos.fetchInitialBankDetails';
import bankOrCashPayment from '@salesforce/apex/Epos.createBankOrCashPayment';
import getInitailApplyCredit from '@salesforce/apex/Epos.applyCreditInitial';
import applyCreditInvoice from "@salesforce/apex/Epos.applyCreditToInvoice";
import fetchApplyLoyaltyInitial from "@salesforce/apex/Epos.applyLoyaltyInitial";
import applyLoyalty from '@salesforce/apex/Epos.applyLoyalty';

//Labels &nbsp; {labels.Order}
import Order from '@salesforce/label/c.Order_RMA';
import Amount from '@salesforce/label/c.RequisitionToPurchaseOrder_PRLI_Amount';
import Paid from '@salesforce/label/c.Paid';
import Total_Due from '@salesforce/label/c.Order_Console_Total_Due';
import Credit from '@salesforce/label/c.Acc_Recev_Credit';
import Invoice_Name from '@salesforce/label/c.SupplierInvoicePDF_Invoice_Name';
import Type from '@salesforce/label/c.Type_ManageLeave';
import Total_Amount from '@salesforce/label/c.Total_Amount';
import Due_Amount from '@salesforce/label/c.Acc_Pay_Due_Amount';
import Action from '@salesforce/label/c.SalesOrderConsole_Action';
import Invoice_Doc from '@salesforce/label/c.EPOS_Invoice_Document';//ask
import Posted from '@salesforce/label/c.Acc_Recev_Posted';
import Date from '@salesforce/label/c.Date_ManageLeave';
import Invoice_Date from '@salesforce/label/c.Invoice_Invoice_Date';
import Paid_Amount from '@salesforce/label/c.Acc_Recev_Paid_Amount';
import Applied_Credit from '@salesforce/label/c.Acc_Pay_Applied_Credit';
import Invoice from '@salesforce/label/c.SalesOrderConsole_Invoice';
import not_found from '@salesforce/label/c.not_found';
import Payment from '@salesforce/label/c.Payment';
import Name from '@salesforce/label/c.StockTakeName';
import Create from '@salesforce/label/c.Transfer_Order_Create';
import Card from '@salesforce/label/c.SelectPaymentGateway_Card';
import Debit from '@salesforce/label/c.Acc_Recev_Debit';
import Cheque from '@salesforce/label/c.Cheque';
import Bank from '@salesforce/label/c.Select_Bank_Payment_Method_Bank';
import Cash_Payment from '@salesforce/label/c.Cash_Payment_Cash_Payment';
import Loyalty from '@salesforce/label/c.ProductConfiguration_Loyalty_Point';
import Apply_Credit from '@salesforce/label/c.Apply_Credit';
import Payment_Gateway from '@salesforce/label/c.SelectPaymentGateway_Payment_Gateway';
import Select_Payment_Gateway from '@salesforce/label/c.SelectpaymentGateway_Select_Payment_Gateway';
import Card_Holder_Name from '@salesforce/label/c.Card_Holder_Name';
import Card_Type from '@salesforce/label/c.Card_Type';
import Card_Number from '@salesforce/label/c.Card_Number';
import CVV from '@salesforce/label/c.DoPayment_CVV';
import Expiry_Month from '@salesforce/label/c.Expiry_Month';
import Expiry_Year from '@salesforce/label/c.Expiry_Year';
import Reference_No from '@salesforce/label/c.Reference_No';
import Payment_Amount from '@salesforce/label/c.Acc_Pay_Payment_Amount';
import Billing_Address from '@salesforce/label/c.Billing_Address';
import Address_line_1 from '@salesforce/label/c.Address_line_1';
import Address_line_2 from '@salesforce/label/c.Address_line_2';
import City from '@salesforce/label/c.City';
import Country from '@salesforce/label/c.UPS_Setup_Country';
import State_Province from '@salesforce/label/c.State_Province';
import Postal_Code from '@salesforce/label/c.UPS_Setup_Postal_Code';
import Pay_Now from '@salesforce/label/c.Pay_Now';
import Cancel from '@salesforce/label/c.Cancel_ManageLeave';
import Bank_Account from '@salesforce/label/c.Bank_Reconcilation_Bank_Account';
import Account from '@salesforce/label/c.Account_Outbound_logistics';
import AccountNumber from '@salesforce/label/c.Select_Bank_Payment_Method_Account_Number';
import Bank_Code from '@salesforce/label/c.Epos_Bank_Code';
import Save from '@salesforce/label/c.Shipment_Save';
import Loyalty_Card from '@salesforce/label/c.CreateClubcard_Loyalty_Card';
import Points from '@salesforce/label/c.AddSubscription_Points';
import Available from '@salesforce/label/c.Available';
import Value from '@salesforce/label/c.Value';
import Invoice_Amount from '@salesforce/label/c.UPS_Setup_Invoice_Amount';
import Balance_Amount from '@salesforce/label/c.Acc_Pay_Balance_Amount';
import Available_Credit from '@salesforce/label/c.Acc_Pay_Available_Credit';
import Credit_Note from '@salesforce/label/c.Credit_Note';
import Balance from '@salesforce/label/c.Acc_Pay_Balance';
import Amount_to_be_Paid from '@salesforce/label/c.Amount_to_be_Paid';
import Due_Invoice_not_available from '@salesforce/label/c.Due_Invoice_not_available';
import Account_Holder_Name from '@salesforce/label/c.Account_Holder_Name';
import In_case_of_different_currency_change_the_currency_of_the_Order from '@salesforce/label/c.In_case_of_different_currency_change_the_currency_of_the_Order';
import Redeem_Points from '@salesforce/label/c.Redeem_Points';
import Apply_Loyalty from '@salesforce/label/c.Apply_Loyalty';
import Credit_Note_not_available from '@salesforce/label/c.Credit_Note_not_available';
import Search from '@salesforce/label/c.Search_Placeholder';
import Select from '@salesforce/label/c.Select';

export default class EposPayment extends LightningElement {
    @track labels={Select, Search, Credit_Note_not_available, Apply_Loyalty, Redeem_Points, In_case_of_different_currency_change_the_currency_of_the_Order, Account_Holder_Name, Due_Invoice_not_available, Amount_to_be_Paid,Order,Amount,Paid,Total_Due,Credit,Invoice_Name,Type,Total_Amount,Due_Amount,Action,Invoice_Doc,Posted,Date,Invoice_Date,Paid_Amount,Applied_Credit,Invoice,not_found,Payment,Name,Create,Card,Debit,Cheque,Bank,Cash_Payment,Loyalty,Apply_Credit,Payment_Gateway,Select_Payment_Gateway ,Card_Holder_Name,Card_Type,Card_Number,CVV,Expiry_Month,Expiry_Year,Reference_No,Payment_Amount,Billing_Address,Address_line_1,Address_line_2,City,Country,State_Province,Postal_Code,Pay_Now,Cancel,Bank_Account,Account,AccountNumber,Bank_Code,Save,Loyalty_Card,Points,Available,Value,Invoice_Amount,Balance_Amount,Available_Credit,Credit_Note,Balance};
    @api order = {};
    @api invoiceList = [];
    @api isInvoiceList = false;
    @api paymentList = [];
    @api isPaymentList = false;
    @api orderCurrency;
    errorList;
    spinner = false;

    isCardPaymentModal = false;
    isBankPaymentModal = false;
    isCashModal = false;
    isLoyaltyModal = false;
    isApplyCreditsModal = false;
    paymentError;
    @track PaymentMethod = {};
    CVV;

    @track invoiceToPay = [];
    isinvoiceToPay = false;

    @track paymentToUpsert = { ERP7__Total_Amount__c: 0 };
    @track paymentBillAdd = {};
    paymentGateway;
    selectedGateway = '';
    CountyList;
    CountryList;
    CardTypes;
    ExpiryMonth;
    ExpiryYear;
    //@api isMultiCurrency=false;

    accountTypes;
    COAFilter;//  "{! v.OrgId != ''?' AND ERP7__Organisation__c =\''+ v.OrgId+'\''+ ' AND ERP7__Payment_Account__c=true' : ' AND ERP7__Payment_Account__c=true'}";

    @track availableCredits;
    isavailableCredits = false;
    appliedCreditAmount = 0;
    balanceAmount = 0;

    loyaltyValue = 0;
    redeemPoints;
    loyalityCards;
    showApplyLoyaltySave = true;

    get COASelected() {
        return this.paymentToUpsert.ERP7__Payment_Account__c ? true : false;
    }
    get COAUrl() {
        return '/' + this.paymentToUpsert.ERP7__Payment_Account__c;
    }


    /*@wire(getInitialData)
    InitailDetails({ error, data }) {
        if (data) {
            console.log('inside eposPaymentinitial result eposPaymnet:', data);
            
            console.log('order:', this.order);
        } else if (error) {
            console.log('inside eposPayment initial result eposPaymnet:', error);
        }
    }*/
    connectedCallback() {
        console.log('inside eposPayment connectedCallback');

    }
    renderedCallback() {
        console.log('inside eposPayment renderedCallback');

        Promise.all([
                 loadStyle(this, CMP_CSS + '/CSS/global-axolt.css'),
                loadStyle(this, PickPackShipResource + '/assets/styles/erp_mark7_bootstrap.css'),
                loadStyle(this, bootStrap + '/css/bootstrap-4.1.css'),
                loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.css'),
                loadStyle(this, ProjectWorkbench + '/css/main-style.css'),
                loadStyle(this, fontawesome5 + '/fontawesome5/css/all.css'),
                loadStyle(this, eposcustom + '/assets/css/app.min.css'),
                loadStyle(this, eposcustom + '/assets/css/bootstrap.min.css'),
                loadStyle(this, eposcustom + '/assets/css/icons.min.css'),
        ])
            .then(() => {
                console.log('Static Resource Loaded epos Payment');
            })
            .catch(error => {
                console.log('inside eposPayment Static Resource Error', error);
            });
    }


    invoiceDocument(event) {
        let index = event.currentTarget.dataset.index;
        this.invoiceList[index].Id;
        var URL_INV = '';
        if (this.order.ERP7__Contact__c) {
            URL_INV = Invoice_Document;
            URL_INV += 'custId=' + this.order.ERP7__Contact__c + '&name=' + this.invoiceList[index].Name;
        }
        window.open(URL_INV, '_blank');
    }

    createInvoice() {
        window.open('/apex/ERP7__CreateInvoiceRecord?soid=' + this.order.Id, '_blank')
    }

    /*selectPaymentMode() {
        console.log('inside selectPaymentMode');
    }*/


    openCardPayModal() {
        try {
            console.log('inside openCardPayModal');
            this.spinner = true;
            //initial setup
            //this.checkAllInv = false;
            this.paymentError = undefined;
            this.PaymentMethod.ERP7__Name_on_Card__c = '';
            this.PaymentMethod.ERP7__Card_Number__c = '';
            this.CVV = '';
            this.paymentToUpsert.ERP7__Reference_Cheque_No__c = '';
            this.paymentToUpsert.ERP7__Total_Amount__c = 0;
            this.invoiceToPay = [];
            let invoiceToPayIndex = 0;
            this.selectedGateway = '';
            console.log('this.invoiceList:', this.invoiceList);

            for (let i in this.invoiceList) {
                if (this.invoiceList[i].ERP7__Total_Due__c > 0) {
                    this.invoiceToPay.push(JSON.parse(JSON.stringify(this.invoiceList[i])));
                    this.invoiceToPay[invoiceToPayIndex].trKey = this.invoiceToPay[invoiceToPayIndex].Id + i;
                    this.invoiceToPay[invoiceToPayIndex].checked = false;
                    this.invoiceToPay[invoiceToPayIndex].AmountToPaid = JSON.parse(JSON.stringify(this.invoiceList[i].ERP7__Total_Due__c));
                    //this.paymentToUpsert.ERP7__Total_Amount__c += parseFloat(this.invoiceToPay[invoiceToPayIndex].AmountToPaid);

                    if (this.invoiceList[i].ERP7__Posted__c) {
                        this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                    } else {
                        this.invoiceToPay[invoiceToPayIndex].disableCheckbox = true;
                        if (this.invoiceToPay[invoiceToPayIndex].RecordType.DeveloperName == 'Advance')
                            this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                    }
                    invoiceToPayIndex++;
                }

            }
            console.log('this.invoiceToPay:', JSON.stringify(this.invoiceToPay));
            if (this.invoiceToPay.length > 0) this.isinvoiceToPay = true;
            else this.isinvoiceToPay = false;

            console.log('this.paymentToUpsert.ERP7__Total_Amount__c:', this.paymentToUpsert.ERP7__Total_Amount__c);
            getInitailCardDetails()
                .then(result => {
                    console.log('result of getInitailCardDetails:', result);
                    this.CountyList = result.CountyList;
                    this.CountryList = result.CountryList;
                    this.CardTypes = result.CardTypes;
                    this.PaymentMethod.ERP7__CardType__c = result.CardTypes[0].value;
                    this.ExpiryMonth = result.ExpiryMonth;
                    this.PaymentMethod.ERP7__Card_Expiration_Month__c = result.ExpiryMonth[0].value;
                    this.ExpiryYear = result.ExpiryYear;
                    this.PaymentMethod.ERP7__Card_Expiration_Year__c = result.ExpiryYear[0].value;
                    this.paymentGateway = result.paymentGateways;
                    if (this.paymentGateway.length == 0) this.paymentError = 'Paymnet Credential Setup is not completed.';
                    if (this.paymentGateway.length == 1) this.selectedGateway = this.paymentGateway[0].value;

                    this.paymentBillAdd = this.order.ERP7__Bill_To_Address__r;
                    this.isCardPaymentModal = true;
                    this.spinner = false;
                })
                .catch(error => {
                    this.spinner = false;
                    this.errorList = Object.assign([], this.errorList);
                    if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                    if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
                })
        } catch (e) {
            this.spinner = false;
            console.log('Error:', e);
        }

    }
    closeCardPaymentModal() {
        this.isCardPaymentModal = false;
        const paymentEvent = new CustomEvent('payment', {});
        this.dispatchEvent(paymentEvent);
    }

    handlePaymentGateway(event) {
        this.selectedGateway = event.detail.value;
    }

    /*get orgSelected() {
        return this.order.ERP7__Organisation__r.Id != '' ? true : false;
    }
    get selectOrgUrl() {
        return '/' + this.order.ERP7__Organisation__r.Id;
    }

    selectOrg(event) {
        this.order.ERP7__Organisation__c = event.detail.Id;
        this.order.ERP7__Organisation__r = { Id: event.detail.Id, Name: event.detail.Name };
    }
    removeOrg() {
        this.order.ERP7__Organisation__c = null;
        this.order.ERP7__Organisation__r = { Id: '', Name: '' };
    }*/

    handlePayInvCheck(event) {
        console.log('event.detail.checked:', event.detail.checked);
        this.spinner = true;
        this.invoiceToPay[event.currentTarget.dataset.index].checked = event.detail.checked;
        console.log('this.paymentToUpsert.ERP7__Total_Amount__c:', this.paymentToUpsert.ERP7__Total_Amount__c);
        if (event.detail.checked)
            this.paymentToUpsert.ERP7__Total_Amount__c = (parseFloat(this.paymentToUpsert.ERP7__Total_Amount__c) + parseFloat(this.invoiceToPay[event.currentTarget.dataset.index].AmountToPaid)).toFixed(2);
        else
            this.paymentToUpsert.ERP7__Total_Amount__c = (parseFloat(this.paymentToUpsert.ERP7__Total_Amount__c) - parseFloat(this.invoiceToPay[event.currentTarget.dataset.index].AmountToPaid)).toFixed(2);

        //this.paymentToUpsert.ERP7__Total_Amount__c=(this.paymentToUpsert.ERP7__Total_Amount__c).toFixed(2);
        console.log('invoice:', JSON.stringify(this.invoiceToPay[event.currentTarget.dataset.index]));
        console.log('this.paymentToUpsert.ERP7__Total_Amount__c:', this.paymentToUpsert.ERP7__Total_Amount__c);
        try {
            if (this.isApplyCreditsModal) {
                this.balanceAmount = parseFloat(this.paymentToUpsert.ERP7__Total_Amount__c) - parseFloat(this.appliedCreditAmount);
                console.log('this.balanceAmount:', this.balanceAmount);
                for (let i in this.invoiceToPay) {
                    if (event.detail.checked) {
                        if (i != event.currentTarget.dataset.index) {
                            if (this.invoiceToPay[i].ERP7__Posted__c || this.invoiceToPay[i].RecordType.DeveloperName == 'Advance') {
                                this.invoiceToPay[i].disableCheckbox = true;
                            }

                        }


                    } else {
                        if (this.invoiceToPay[i].ERP7__Posted__c || this.invoiceToPay[i].RecordType.DeveloperName == 'Advance') {
                            this.invoiceToPay[i].disableCheckbox = false;
                        }

                    }
                }
            }
            this.spinner = false;
        } catch (e) {
            this.spinner = false;
            console.log('e:', e);
        }

    }

    handleCardName(event) {
        this.PaymentMethod.ERP7__Name_on_Card__c = event.currentTarget.value;
    }
    handleCardType(event) {
        this.PaymentMethod.ERP7__CardType__c = event.detail.value;
    }
    handleCardNumber(event) {
        this.PaymentMethod.ERP7__Card_Number__c = event.currentTarget.value;
    }
    handleCVV(event) {
        this.CVV = event.currentTarget.value;
    }
    handleCardExpMonth(event) {
        this.PaymentMethod.ERP7__Card_Expiration_Month__c = event.detail.value;
    }
    handleCardExpYear(event) {
        this.PaymentMethod.ERP7__Card_Expiration_Year__c = event.detail.value;
    }
    handleRefCheque(event) {
        this.paymentToUpsert.ERP7__Reference_Cheque_No__c = event.currentTarget.value;
    }

    handleBillLine1(event) {
        this.paymentBillAdd.ERP7__Address_Line1__c = event.currentTarget.value;
    }
    handleBillLine2(event) {
        this.paymentBillAdd.ERP7__Address_Line2__c = event.currentTarget.value;
    }
    handleBillCountry(event) {
        this.paymentBillAdd.ERP7__Country__c = event.detail.value;
    }
    handleBillCity(event) {
        this.paymentBillAdd.ERP7__City__c = event.currentTarget.value;
    }
    handleBillState(event) {
        this.paymentBillAdd.ERP7__State__c = event.currentTarget.value;
    }
    handleBillZip(event) {
        this.paymentBillAdd.ERP7__Postal_Code__c = event.currentTarget.value;
    }

    /*checkAllInv = false;
    checkAllInvToPay(event) {
        //refreshApex(this.invoiceToPay);
        console.log('event.detail.value:', event.detail.checked);

        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for (let i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = event.detail.checked;
        }
        this.checkAllInv = event.detail.checked;

        this.paymentToUpsert.ERP7__Total_Amount__c = 0;
        if (event.detail.checked == true) {
            for (let i in this.invoiceToPay) {
                this.invoiceToPay[i].checked = true;
                this.paymentToUpsert.ERP7__Total_Amount__c += parseFloat(this.invoiceToPay[i].AmountToPaid);
            }
        } else if (event.detail.checked == false) {
            for (let i in this.invoiceToPay) {
                this.invoiceToPay[i].checked = false;
            }
        }
    }*/

    handleInvDue(event) {
        console.log('event.currentTarget.value:', event.currentTarget.value);
        this.paymentError = undefined;
        for (let i in this.invoiceList) {
            if (this.invoiceList[i].Id == this.invoiceToPay[event.currentTarget.dataset.index].Id && parseFloat(this.invoiceList[i].ERP7__Total_Due__c) < parseFloat(event.currentTarget.value)) {
                this.paymentError = this.invoiceToPay[event.currentTarget.dataset.index].Name + ' : Amount Can not be greater than due amount';
            }
        }
        this.invoiceToPay[event.currentTarget.dataset.index].AmountToPaid = parseFloat(event.currentTarget.value);
        this.paymentToUpsert.ERP7__Total_Amount__c = 0;
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked)
                this.paymentToUpsert.ERP7__Total_Amount__c = (parseFloat(this.paymentToUpsert.ERP7__Total_Amount__c) + parseFloat(this.invoiceToPay[i].AmountToPaid)).toFixed(2);
        }
        this.balanceAmount = (parseFloat(this.paymentToUpsert.ERP7__Total_Amount__c) - parseFloat(this.appliedCreditAmount)).toFixed(2);
    }


    cardPaymentSave() {
        console.log('this.invoiceToPay:', this.invoiceToPay);
        this.paymentError = undefined;



        if (this.paymentGateway.length == 0) {
            this.paymentError = 'Paymnet Credential Setup is not completed.';
            return;
        }

        if (this.invoiceToPay.length == 0) {
            this.paymentError = 'Due Invoice not available to pay';
            return;
        }
        let count = 0;
        let ifSingleInv = '';
        //let invIdList = [];
        let invAndAmount = [];
        let invAndAmountIndex = 0;
        let salesInvCount = 0;
        let advInvCount = 0
        let isAdvance = false;
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked) {
                invAndAmount[invAndAmountIndex] = { Id: this.invoiceToPay[i].Id, ERP7__Invoice_Amount__c: this.invoiceToPay[i].AmountToPaid };
                invAndAmountIndex++;
                //invAndAmountMap.set(this.invoiceToPay[i].Id,this.invoiceToPay[i].AmountToPaid);
                //invIdList.push(this.invoiceToPay[i].Id);
                ifSingleInv = this.invoiceToPay[i].Id;
                count++;
                if (this.invoiceToPay[i].RecordType.DeveloperName == 'Advance') { advInvCount++; isAdvance = true; }
                if (this.invoiceToPay[i].RecordType.DeveloperName == 'Sale') salesInvCount++;
            }
        }
        if (salesInvCount > 0 && advInvCount > 0) {
            this.paymentError = 'Can not pay sale and advance invoices together.'
            return;
        }
        if (count == 1) this.paymentToUpsert.ERP7__Invoice__c = ifSingleInv;
        if (count == 0) {
            this.paymentError = 'Please select invoice to pay';
            return;
        }
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked && parseFloat(this.invoiceToPay[i].AmountToPaid) <= 0) {
                this.paymentError = this.invoiceToPay[i].Name + ' : Amount To Paid can not be zero or negative';
                return;
            }
            for (let j in this.invoiceList) {
                if (this.invoiceList[j].Id == this.invoiceToPay[i].Id && parseFloat(this.invoiceList[j].ERP7__Total_Due__c) < parseFloat(this.invoiceToPay[i].AmountToPaid)) {
                    this.paymentError = this.invoiceToPay[i].Name + ' : Amount Can not be greater than due amount';
                    return;
                }
            }

        }

        if (!this.PaymentMethod.ERP7__Name_on_Card__c || this.PaymentMethod.ERP7__Name_on_Card__c == '') {
            this.paymentError = 'Enter Card Holder Name';
            return;
        }
        if (!this.PaymentMethod.ERP7__CardType__c || this.PaymentMethod.ERP7__CardType__c == '') {
            this.paymentError = 'Select Card Type';
            return;
        }
        if (!this.PaymentMethod.ERP7__Card_Number__c || this.PaymentMethod.ERP7__Card_Number__c == '') {
            this.paymentError = 'Enter Card Number';
            return;
        }
        if (!this.CVV || this.CVV == '') {
            this.paymentError = 'Enter CVV';
            return;
        }
        if (!this.PaymentMethod.ERP7__Card_Expiration_Month__c || this.PaymentMethod.ERP7__Card_Expiration_Month__c == '') {
            this.paymentError = 'Select Expiry Month';
            return;
        }
        if (!this.PaymentMethod.ERP7__Card_Expiration_Year__c || this.PaymentMethod.ERP7__Card_Expiration_Year__c == '') {
            this.paymentError = 'Select Expiry Year';
            return;
        }
        if (!this.paymentToUpsert.ERP7__Total_Amount__c || this.paymentToUpsert.ERP7__Total_Amount__c <= 0) {
            this.paymentError = 'Payment Amount can not be zero or negative';
            return;
        }
        if (!this.paymentBillAdd.ERP7__Country__c || this.paymentBillAdd.ERP7__Country__c == '') {
            this.paymentError = 'Select Country';
            return;
        }
        if (!this.paymentBillAdd.ERP7__State__c || this.paymentBillAdd.ERP7__State__c == '') {
            this.paymentError = 'Select State/Province';
            return;
        }
        if (!this.selectedGateway || this.selectedGateway == '') {
            this.paymentError = 'Select Payment Gateway';
            return;
        }

        this.spinner = true;
        //if (!this.isMultiCurrency) delete this.order.CurrencyIsoCode;
        console.log('after multi');
        this.paymentToUpsert.ERP7__Account_Holder_Name__c = this.PaymentMethod.ERP7__Name_on_Card__c;
        if (isAdvance)
            this.paymentToUpsert.ERP7__Transaction_Type__c = 'AdvancePayment';
        else
            this.paymentToUpsert.ERP7__Transaction_Type__c = 'InvoicePayment';

        this.paymentToUpsert.ERP7__Order__c = this.order.Id;
        this.paymentToUpsert.ERP7__Accounts__c = this.order.AccountId;
        this.paymentToUpsert.ERP7__Amount__c = this.paymentToUpsert.ERP7__Total_Amount__c;

        if (this.order.ERP7__Contact__r.FirstName) this.paymentToUpsert.ERP7__First_Name__c = this.order.ERP7__Contact__r.FirstName;
        if (this.order.ERP7__Contact__r.LastName) this.paymentToUpsert.ERP7__Last_Name__c = this.order.ERP7__Contact__r.LastName;
        if (this.order.ERP7__Contact__r.Email) this.paymentToUpsert.ERP7__Email_Address__c = this.order.ERP7__Contact__r.Email;
        if (this.paymentBillAdd.ERP7__Address_Line1__c) this.paymentToUpsert.ERP7__Address_Line1__c = this.paymentBillAdd.ERP7__Address_Line1__c;
        if (this.paymentBillAdd.ERP7__Address_Line2__c) this.paymentToUpsert.ERP7__Address_Line2__c = this.paymentBillAdd.ERP7__Address_Line2__c;
        if (this.paymentBillAdd.ERP7__City__c) this.paymentToUpsert.ERP7__City__c = this.paymentBillAdd.ERP7__City__c;
        if (this.paymentBillAdd.ERP7__State__c) this.paymentToUpsert.ERP7__State__c = this.paymentBillAdd.ERP7__State__c;
        if (this.paymentBillAdd.ERP7__Country__c) this.paymentToUpsert.Country__c = this.paymentBillAdd.ERP7__Country__c;
        if (this.paymentBillAdd.ERP7__Postal_Code__c) this.paymentToUpsert.Zipcode__c = this.paymentBillAdd.ERP7__Postal_Code__c;
        if (this.order.ERP7__Organisation__c) this.paymentToUpsert.ERP7__Account__c = this.order.ERP7__Organisation__c;
        if (this.order.ERP7__Organisation_Business_Unit__c) this.paymentToUpsert.ERP7__Organisation_Business_Unit__c = this.order.ERP7__Organisation_Business_Unit__c;
        //this.paymentToUpsert.this.paymentToUpsert_Gateway__c = 'PayPal';

        console.log('this.order:', this.order);
        console.log('this.this.paymentToUpsert:', this.paymentToUpsert);
        console.log('this.PaymentMethod:', this.PaymentMethod);
        console.log('this.CVV:', this.CVV);
        console.log('this.paymentBillAdd:', this.paymentBillAdd);
        console.log('this.Payment Gateway:', this.selectedGateway);
        console.log('this.orderCurrency:', this.orderCurrency);
        console.log('invAndAmount:', invAndAmount);

        cardPayment({
            //ord: JSON.stringify(this.order),
            payments: JSON.stringify(this.paymentToUpsert),
            paymentMethods: JSON.stringify(this.PaymentMethod),
            CVV: this.CVV,
            billAddress: JSON.stringify(this.paymentBillAdd),
            selectedGateway: this.selectedGateway,
            myCur: this.orderCurrency,
            //invList: JSON.stringify(invIdList),
            invAndAmount: JSON.stringify(invAndAmount),
            resCode:1,
        })
            .then(result => {
                console.log('result of cardPayment:', result);

                if (result.includes('Payment Created Successfully')) {
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: result,
                    });
                    this.dispatchEvent(event);
                    const paymentEvent = new CustomEvent('payment', {});
                    this.dispatchEvent(paymentEvent);
                    this.isCardPaymentModal = false;
                    this.spinner = false;
                } else {
                    this.paymentError = result;
                    this.spinner = false;
                }
            })
            .catch(error => {
                this.paymentError = error;
                this.spinner = false;
                console.log('Error:',error);
                
            })

    }

    postInvoice(event) {
        console.log('inside postInvoice');
        this.spinner = true;
        this.paymentError = undefined;
        let index = event.currentTarget.dataset.index;
        let invId = this.invoiceToPay[index].Id;
        console.log('index:', invId);
        //Substract Invoice Amount from ERP7__Total_Amount__c
        if (this.invoiceToPay[index].checked) {
            this.paymentToUpsert.ERP7__Total_Amount__c -= parseFloat(this.invoiceToPay[index].AmountToPaid);
        }
        if (this.isApplyCreditsModal) {
            for (let i in this.invoiceToPay) {
                this.invoiceToPay[i].checked = false;
                if (this.invoiceToPay[i].ERP7__Posted__c || this.invoiceToPay[i].RecordType.DeveloperName == 'Advance') {
                    this.invoiceToPay[i].disableCheckbox = false;
                } else {
                    this.invoiceToPay[i].disableCheckbox = true;
                }
            }
            this.paymentToUpsert.ERP7__Total_Amount__c = 0;
            this.balanceAmount = 0;
            this.appliedCreditAmount = 0;
            getInitailApplyCredit({
                accId: this.order.AccountId,
            })
                .then(result => {
                    console.log('result:', result);
                    this.availableCredits = JSON.parse(JSON.stringify(result));
                    for (let i in this.availableCredits) {
                        this.availableCredits[i].credNote.credNoteurl = '/' + this.availableCredits[i].credNote.Id;
                        this.availableCredits[i].credNote.amountDue = (parseFloat(this.availableCredits[i].credNote.ERP7__Balance__c) - parseFloat(this.availableCredits[i].debitAmount)).toFixed(2);
                        this.availableCredits[i].credNote.maxValue = this.availableCredits[i].credNote.ERP7__Balance__c;
                    }

                    this.isavailableCredits = this.availableCredits.length > 0 ? true : false;
                })
                .catch(error => {
                    console.log('Error:', error);
                    if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                    if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
                })
            //this.balanceAmount=(parseFloat(this.paymentToUpsert.ERP7__Total_Amount__c)-parseFloat(this.invoiceToPay[index].AmountToPaid)).toFixed(2);
        }

        let postedValue;
        if (this.invoiceToPay[index].postLable == 'Post') postedValue = true;
        if (this.invoiceToPay[index].postLable == 'Unpost') postedValue = false;

        upsertInvoice({
            invId: invId,
            postedValue: postedValue,
        })
            .then(result => {
                console.log('result :', result);
                this.invoiceToPay[index] = result;
                this.invoiceToPay[index].invoiceurl = '/' + this.invoiceToPay[index].Id;
                if (this.invoiceToPay[index].ERP7__Posted__c) {
                    this.invoiceToPay[index].disableCheckbox = false;
                    this.invoiceToPay[index].isPosted = 'Yes';
                    this.invoiceToPay[index].postLable = 'Unpost';
                    this.invoiceToPay[index].isPostedClass = 'bgGreen';
                    this.invoiceToPay[index].trKey = this.invoiceToPay[index].Id + index;
                    this.invoiceToPay[index].AmountToPaid = JSON.parse(JSON.stringify(this.invoiceToPay[index].ERP7__Total_Due__c));
                    this.invoiceToPay[index].checked = false;

                }
                else {
                    this.invoiceToPay[index].disableCheckbox = true;
                    this.invoiceToPay[index].isPosted = 'No';
                    this.invoiceToPay[index].postLable = 'Post';
                    this.invoiceToPay[index].isPostedClass = 'bgRed';
                    this.invoiceToPay[index].trKey = this.invoiceToPay[index].Id + index;
                    this.invoiceToPay[index].AmountToPaid = JSON.parse(JSON.stringify(this.invoiceToPay[index].ERP7__Total_Due__c));
                    this.invoiceToPay[index].checked = false;

                }
                if (this.invoiceToPay[index].RecordType.DeveloperName == 'Advance')
                    this.invoiceToPay[index].isAdvance = true;
                else
                    this.invoiceToPay[index].isAdvance = false;

                    
                /*//For Updating posted invoiceList
                //const paymentEvent = new CustomEvent('payment', { });
                //this.dispatchEvent(paymentEvent);
                for (let i in this.invoiceList) {
                    if (this.invoiceList[i].Id == invId) {                        
                        this.invoiceList[i] = this.invoiceToPay[index];
                    }
                }*/
                this.spinner = false;
            })
            .catch(error => {
                console.log('Error:', error);
                this.paymentError = error;
                this.spinner = false;
                if (!this.errorList.includes(error.body.message)) this.errorList.push(error.body.message);
                    if (!this.errorList.includes(error.body.stackTrace) && error.body.stackTrace) this.errorList.push(error.body.stackTrace);
            })
    }

    openBankPaymentModal() {
        try {
            this.spinner = true;
            //initialize initails
            this.paymentError = undefined;
            this.paymentToUpsert.ERP7__Bank__c = '';
            this.paymentToUpsert.ERP7__Account_Holder_Name__c = '';
            this.paymentToUpsert.ERP7__Payment_Account__c = null;
            this.paymentToUpsert.ERP7__Account_Type__c = '';
            this.paymentToUpsert.ERP7__Account_Number__c = '';
            this.paymentToUpsert.ERP7__Bank_Code__c = '';
            this.paymentToUpsert.ERP7__Reference_Cheque_No__c = '';
            this.paymentToUpsert.ERP7__Total_Amount__c = 0;
            this.COAFilter = this.order.ERP7__Organisation__c ? "ERP7__Organisation__c ='" + this.order.ERP7__Organisation__c + "'  AND ERP7__Payment_Account__c=true" : ' ERP7__Payment_Account__c=true';

            this.invoiceToPay = [];
            let invoiceToPayIndex = 0;
            console.log('this.invoiceList:', this.invoiceList);

            for (let i in this.invoiceList) {
                if (this.invoiceList[i].ERP7__Total_Due__c > 0) {
                    this.invoiceToPay.push(JSON.parse(JSON.stringify(this.invoiceList[i])));
                    this.invoiceToPay[invoiceToPayIndex].trKey = this.invoiceToPay[invoiceToPayIndex].Id + i;
                    this.invoiceToPay[invoiceToPayIndex].checked = false;
                    this.invoiceToPay[invoiceToPayIndex].AmountToPaid = JSON.parse(JSON.stringify(this.invoiceList[i].ERP7__Total_Due__c));
                    //this.paymentToUpsert.ERP7__Total_Amount__c += parseFloat(this.invoiceToPay[invoiceToPayIndex].AmountToPaid);

                    if (this.invoiceList[i].ERP7__Posted__c) {
                        this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                    } else {
                        this.invoiceToPay[invoiceToPayIndex].disableCheckbox = true;
                        if (this.invoiceToPay[invoiceToPayIndex].RecordType.DeveloperName == 'Advance')
                            this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                    }
                    invoiceToPayIndex++;
                }
            }
            console.log('this.invoiceToPay:', JSON.stringify(this.invoiceToPay));

            if (this.invoiceToPay.length > 0) this.isinvoiceToPay = true;
            else this.isinvoiceToPay = false;

            console.log('this.paymentToUpsert.ERP7__Total_Amount__c:', this.paymentToUpsert.ERP7__Total_Amount__c);

            getInitialBankDetails()
                .then(result => {
                    this.accountTypes = result.accountsType;
                    this.paymentToUpsert.ERP7__Account_Type__c = result.accountsType[0].value;
                    this.isBankPaymentModal = true;
                    this.spinner = false;
                })
                .catch(error => {
                    this.spinner = false;
                    this.paymentError = error;
                })
        } catch (e) {
            this.spinner = false;
            console.log('Error:', e);
        }

    }

    closeBankPaymentModal() {
        this.isBankPaymentModal = false;
        const paymentEvent = new CustomEvent('payment', {});
        this.dispatchEvent(paymentEvent);
    }

    handleBankName(event) {
        this.paymentToUpsert.ERP7__Bank__c = event.currentTarget.value;
    }
    handleAHName(event) {
        this.paymentToUpsert.ERP7__Account_Holder_Name__c = event.currentTarget.value;
    }
    removeCOA(event) {
        this.paymentToUpsert.ERP7__Payment_Account__c = null;
    }
    selectCOA(event) {
        this.paymentToUpsert.ERP7__Payment_Account__c = event.detail.Id;
        //this.COASelected=true;
    }
    handleACtype(event) {
        this.paymentToUpsert.ERP7__Account_Type__c = event.detail.value;
    }
    handleACNumber(event) {
        this.paymentToUpsert.ERP7__Account_Number__c = event.currentTarget.value;
    }
    handleBankCode(event) {
        this.paymentToUpsert.ERP7__Bank_Code__c = event.currentTarget.value;
    }
    handleBankRefCheque(event) {
        this.paymentToUpsert.ERP7__Reference_Cheque_No__c = event.currentTarget.value;
    }

    bankPaymentSave() {
        console.log('this.invoiceToPay:', this.invoiceToPay);

        this.paymentError = undefined;

        if (this.invoiceToPay.length == 0) {
            this.paymentError = 'Due Invoice not available to pay';
            return;
        }
        let count = 0;
        let ifSingleInv = '';
        let invAndAmount = [];
        let invAndAmountIndex = 0;
        let salesInvCount = 0;
        let advInvCount = 0;
        let isAdvance = false;
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked) {
                invAndAmount[invAndAmountIndex] = { Id: this.invoiceToPay[i].Id, ERP7__Invoice_Amount__c: this.invoiceToPay[i].AmountToPaid };
                invAndAmountIndex++;
                ifSingleInv = this.invoiceToPay[i].Id;
                count++;
                if (this.invoiceToPay[i].RecordType.DeveloperName == 'Advance') { advInvCount++; isAdvance = true; }
                if (this.invoiceToPay[i].RecordType.DeveloperName == 'Sale') salesInvCount++;
            }
        }
        console.log('salesInvCount:', salesInvCount);
        console.log('advInvCount:', advInvCount);
        if (salesInvCount > 0 && advInvCount > 0) {
            this.paymentError = 'Can not pay sales and advance invoices together.';
            console.log('this.invoiceToPay1:', this.invoiceToPay);
            return;
        }
        if (count == 1) this.paymentToUpsert.ERP7__Invoice__c = ifSingleInv;
        if (count == 0) {
            this.paymentError = 'Please select invoice to pay';
            return;
        }
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked && parseFloat(this.invoiceToPay[i].AmountToPaid) <= 0) {
                this.paymentError = this.invoiceToPay[i].Name + ' : Amount To Paid can not be zero or negative';
                return;
            }
            for (let j in this.invoiceList) {
                if (this.invoiceList[j].Id == this.invoiceToPay[i].Id && parseFloat(this.invoiceList[j].ERP7__Total_Due__c) < parseFloat(this.invoiceToPay[i].AmountToPaid)) {
                    this.paymentError = this.invoiceToPay[i].Name + ' : Amount Can not be greater than due amount';
                    return;
                }
            }

        }

        if (!this.paymentToUpsert.ERP7__Reference_Cheque_No__c || this.paymentToUpsert.ERP7__Reference_Cheque_No__c == '') {
            this.paymentError = 'Missing Reference/Cheque No';
            return;
        }

        if (!this.paymentToUpsert.ERP7__Total_Amount__c || this.paymentToUpsert.ERP7__Total_Amount__c <= 0) {
            this.paymentError = 'Payment Amount can not be zero or negative';
            return;
        }

        this.spinner = true;

        if (isAdvance)
            this.paymentToUpsert.ERP7__Transaction_Type__c = 'AdvancePayment';
        else
            this.paymentToUpsert.ERP7__Transaction_Type__c = 'InvoicePayment';

        this.paymentToUpsert.ERP7__Order__c = this.order.Id;
        this.paymentToUpsert.ERP7__Accounts__c = this.order.AccountId;
        this.paymentToUpsert.ERP7__Amount__c = this.paymentToUpsert.ERP7__Total_Amount__c;
        if (this.order.ERP7__Contact__r.FirstName) this.paymentToUpsert.ERP7__First_Name__c = this.order.ERP7__Contact__r.FirstName;
        if (this.order.ERP7__Contact__r.LastName) this.paymentToUpsert.ERP7__Last_Name__c = this.order.ERP7__Contact__r.LastName;
        if (this.order.ERP7__Contact__r.Email) this.paymentToUpsert.ERP7__Email_Address__c = this.order.ERP7__Contact__r.Email;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line1__c) this.paymentToUpsert.ERP7__Address_Line1__c = this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line1__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line2__c) this.paymentToUpsert.ERP7__Address_Line2__c = this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line2__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__City__c) this.paymentToUpsert.ERP7__City__c = this.order.ERP7__Bill_To_Address__r.ERP7__City__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__State__c) this.paymentToUpsert.ERP7__State__c = this.order.ERP7__Bill_To_Address__r.ERP7__State__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Country__c) this.paymentToUpsert.ERP7__Country__c = this.order.ERP7__Bill_To_Address__r.ERP7__Country__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c) this.paymentToUpsert.ERP7__Zipcode__c = this.order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c;
        if (this.order.ERP7__Organisation__c) this.paymentToUpsert.ERP7__Account__c = this.order.ERP7__Organisation__c;
        if (this.order.ERP7__Organisation_Business_Unit__c) this.paymentToUpsert.ERP7__Organisation_Business_Unit__c = this.order.ERP7__Organisation_Business_Unit__c;

        this.paymentToUpsert.ERP7__Type__c = 'Debit';
        this.paymentToUpsert.ERP7__Payment_Type__c = 'Bank';
        this.paymentToUpsert.ERP7__Status__c = 'Paid';

        console.log('this.order:', this.order);
        console.log('this.this.paymentToUpsert:', this.paymentToUpsert);
        console.log('invAndAmount:', invAndAmount);

        if (this.paymentToUpsert.ERP7__Account_Type__c || this.paymentToUpsert.ERP7__Account_Type__c == '') delete this.paymentToUpsert.ERP7__Account_Type__c;

        bankOrCashPayment({
            payments: JSON.stringify(this.paymentToUpsert),
            invAndAmount: JSON.stringify(invAndAmount),
            paymentType: 'Bank',
        })
            .then(result => {
                console.log('result:', result);
                if (result.includes('Payment Created Successfully')) {
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: result,
                    });
                    this.dispatchEvent(event);
                    const paymentEvent = new CustomEvent('payment', {});
                    this.dispatchEvent(paymentEvent);
                    this.spinner = false;
                    this.isBankPaymentModal = false;
                }
            })
            .catch(error => {
                console.log('error:', error);
                this.paymentError = error;
                this.spinner = false;
            })



    }

    closeCashModal(event) {
        this.isCashModal = false;
        const paymentEvent = new CustomEvent('payment', {});
        this.dispatchEvent(paymentEvent);
    }

    openCashPaymentModal() {
        this.spinner = true;
        this.paymentError = undefined;
        this.paymentToUpsert.ERP7__Reference_Cheque_No__c = '';
        this.paymentToUpsert.ERP7__Total_Amount__c = 0;

        this.invoiceToPay = [];
        let invoiceToPayIndex = 0;
        console.log('this.invoiceList:', this.invoiceList);

        for (let i in this.invoiceList) {
            if (this.invoiceList[i].ERP7__Total_Due__c > 0) {
                this.invoiceToPay.push(JSON.parse(JSON.stringify(this.invoiceList[i])));
                //Here taking separate index because it will work with the second record as well.
                this.invoiceToPay[invoiceToPayIndex].trKey = this.invoiceToPay[invoiceToPayIndex].Id + i;
                this.invoiceToPay[invoiceToPayIndex].checked = false;
                this.invoiceToPay[invoiceToPayIndex].AmountToPaid = JSON.parse(JSON.stringify(this.invoiceList[i].ERP7__Total_Due__c));
                //this.paymentToUpsert.ERP7__Total_Amount__c += parseFloat(this.invoiceToPay[i].AmountToPaid);

                if (this.invoiceList[i].ERP7__Posted__c) {
                    this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                } else {
                    this.invoiceToPay[invoiceToPayIndex].disableCheckbox = true;
                    if (this.invoiceToPay[invoiceToPayIndex].RecordType.DeveloperName == 'Advance')
                        this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                }
                invoiceToPayIndex++;
            }
        }
        console.log('this.invoiceToPay:', JSON.stringify(this.invoiceToPay));

        if (this.invoiceToPay.length > 0) this.isinvoiceToPay = true;
        else this.isinvoiceToPay = false;

        console.log('this.paymentToUpsert.ERP7__Total_Amount__c:', this.paymentToUpsert.ERP7__Total_Amount__c);
        this.spinner = false;
        this.isCashModal = true;
        
    }
    cashPaymentSave() {
        this.paymentError = undefined;

        if (this.invoiceToPay.length == 0) {
            this.paymentError = 'Due Invoice not available to pay';
            return;
        }
        let count = 0;
        let ifSingleInv = '';
        let invAndAmount = [];
        let invAndAmountIndex = 0;
        let salesInvCount = 0;
        let advInvCount = 0;
        let isAdvance = false;
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked) {
                invAndAmount[invAndAmountIndex] = { Id: this.invoiceToPay[i].Id, ERP7__Invoice_Amount__c: this.invoiceToPay[i].AmountToPaid };
                invAndAmountIndex++;
                ifSingleInv = this.invoiceToPay[i].Id;
                count++;
                if (this.invoiceToPay[i].RecordType.DeveloperName == 'Advance') { advInvCount++; isAdvance = true; }
                if (this.invoiceToPay[i].RecordType.DeveloperName == 'Sale') salesInvCount++;
            }
        }
        if (salesInvCount > 0 && advInvCount > 0) {
            this.paymentError = 'Can not pay sales and advance invoices together.';
            return;
        }
        if (count == 1) this.paymentToUpsert.ERP7__Invoice__c = ifSingleInv;
        if (count == 0) {
            this.paymentError = 'Please select invoice to pay';
            return;
        }
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked && parseFloat(this.invoiceToPay[i].AmountToPaid) <= 0) {
                this.paymentError = this.invoiceToPay[i].Name + ' : Amount To Paid can not be zero or negative';
                return;
            }
            for (let j in this.invoiceList) {
                if (this.invoiceList[j].Id == this.invoiceToPay[i].Id && parseFloat(this.invoiceList[j].ERP7__Total_Due__c) < parseFloat(this.invoiceToPay[i].AmountToPaid)) {
                    this.paymentError = this.invoiceToPay[i].Name + ' : Amount Can not be greater than due amount';
                    return;
                }
            }

        }

        if (!this.paymentToUpsert.ERP7__Reference_Cheque_No__c || this.paymentToUpsert.ERP7__Reference_Cheque_No__c == '') {
            this.paymentError = 'Missing Reference No';
            return;
        }

        if (!this.paymentToUpsert.ERP7__Total_Amount__c || this.paymentToUpsert.ERP7__Total_Amount__c <= 0) {
            this.paymentError = 'Payment Amount can not be zero or negative';
            return;
        }

        this.spinner = true;

        if (isAdvance)
            this.paymentToUpsert.ERP7__Transaction_Type__c = 'AdvancePayment';
        else
            this.paymentToUpsert.ERP7__Transaction_Type__c = 'InvoicePayment';

        this.paymentToUpsert.ERP7__Order__c = this.order.Id;
        this.paymentToUpsert.ERP7__Accounts__c = this.order.AccountId;
        this.paymentToUpsert.ERP7__Amount__c = this.paymentToUpsert.ERP7__Total_Amount__c;
        if (this.order.ERP7__Contact__r.FirstName) this.paymentToUpsert.ERP7__First_Name__c = this.order.ERP7__Contact__r.FirstName;console.log('this.paymentToUpsert.ERP7__First_Name__c',this.paymentToUpsert.ERP7__First_Name__c);
        if (this.order.ERP7__Contact__r.LastName) this.paymentToUpsert.ERP7__Last_Name__c = this.order.ERP7__Contact__r.LastName;console.log('this.paymentToUpsert.ERP7__Last_Name__c',this.paymentToUpsert.ERP7__Last_Name__c);
        if (this.order.ERP7__Contact__r.Email) this.paymentToUpsert.ERP7__Email_Address__c = this.order.ERP7__Contact__r.Email;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line1__c) this.paymentToUpsert.ERP7__Address_Line1__c = this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line1__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line2__c) this.paymentToUpsert.ERP7__Address_Line2__c = this.order.ERP7__Bill_To_Address__r.ERP7__Address_Line2__c;console.log('this.paymentToUpsert.ERP7__Address_Line2__c',this.paymentToUpsert.ERP7__Address_Line2__c);
        if (this.order.ERP7__Bill_To_Address__r.ERP7__City__c) this.paymentToUpsert.ERP7__City__c = this.order.ERP7__Bill_To_Address__r.ERP7__City__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__State__c) this.paymentToUpsert.ERP7__State__c = this.order.ERP7__Bill_To_Address__r.ERP7__State__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Country__c) this.paymentToUpsert.ERP7__Country__c = this.order.ERP7__Bill_To_Address__r.ERP7__Country__c;
        if (this.order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c) this.paymentToUpsert.ERP7__Zipcode__c = this.order.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c;
        if (this.order.ERP7__Organisation__c) this.paymentToUpsert.ERP7__Account__c = this.order.ERP7__Organisation__c;
        if (this.order.ERP7__Organisation_Business_Unit__c) this.paymentToUpsert.ERP7__Organisation_Business_Unit__c = this.order.ERP7__Organisation_Business_Unit__c;console.log('this.paymentToUpsert.ERP7__Organisation_Business_Unit__c',this.paymentToUpsert.ERP7__Organisation_Business_Unit__c);

        this.paymentToUpsert.ERP7__Type__c = 'Debit';
        this.paymentToUpsert.ERP7__Payment_Type__c = 'Cash';
        this.paymentToUpsert.ERP7__Status__c = 'Paid';

        if (this.paymentToUpsert.ERP7__Account_Type__c || this.paymentToUpsert.ERP7__Account_Type__c == '') delete this.paymentToUpsert.ERP7__Account_Type__c;
				
				console.log('Payment To Upsert loading in to apex::~>',JSON.stringify(this.paymentToUpsert));
        console.log('invAndAmount loading in to apex::~>',JSON.stringify(invAndAmount));
				
        bankOrCashPayment({
            payments: JSON.stringify(this.paymentToUpsert),
            invAndAmount: JSON.stringify(invAndAmount),
            paymentType: 'Cash',
        })
            .then(result => {
                console.log('result:', result);
                if (result.includes('Payment Created Successfully')) {
                    this.isCashModal = false;
                    this.spinner = false;
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: result,
                    });
                    this.dispatchEvent(event);
                    const paymentEvent = new CustomEvent('payment', {});
                    this.dispatchEvent(paymentEvent);
                }
            })
            .catch(error => {
                console.log('error:', error);
                this.paymentError = error;
                this.spinner = false;
            })

    }


    openApplyCreditModal() {
        try {
            this.spinner = true;
            this.paymentError = undefined;
            this.paymentToUpsert.ERP7__Reference_Cheque_No__c = '';
            this.paymentToUpsert.ERP7__Total_Amount__c = 0;

            this.invoiceToPay = [];
            let invoiceToPayIndex = 0;
            console.log('this.invoiceList:', JSON.stringify(this.invoiceList));

            for (let i in this.invoiceList) {
                if (this.invoiceList[i].ERP7__Total_Due__c > 0) {
                    console.log('this.invoiceList[i]:', this.invoiceList[i]);
                    this.invoiceToPay.push(JSON.parse(JSON.stringify(this.invoiceList[i])));
                    this.invoiceToPay[invoiceToPayIndex].trKey = this.invoiceToPay[invoiceToPayIndex].Id + i;
                    this.invoiceToPay[invoiceToPayIndex].checked = false;
                    this.invoiceToPay[invoiceToPayIndex].AmountToPaid = JSON.parse(JSON.stringify(this.invoiceList[i].ERP7__Total_Due__c));
                    //this.paymentToUpsert.ERP7__Total_Amount__c += parseFloat(this.invoiceToPay[invoiceToPayIndex].AmountToPaid);

                    if (this.invoiceList[i].ERP7__Posted__c) {
                        this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                    } else {
                        this.invoiceToPay[invoiceToPayIndex].disableCheckbox = true;
                        if (this.invoiceToPay[invoiceToPayIndex].RecordType.DeveloperName == 'Advance')
                            this.invoiceToPay[invoiceToPayIndex].disableCheckbox = false;
                    }
                    invoiceToPayIndex++;
                }
            }
            console.log('this.invoiceToPay:', JSON.stringify(this.invoiceToPay));

            if (this.invoiceToPay.length > 0) this.isinvoiceToPay = true;
            else this.isinvoiceToPay = false;

            console.log('this.paymentToUpsert.ERP7__Total_Amount__c:', this.paymentToUpsert.ERP7__Total_Amount__c);

            getInitailApplyCredit({
                accId: this.order.AccountId,
            })
                .then(result => {
                    console.log('result:', result);
                    this.availableCredits = JSON.parse(JSON.stringify(result));
                    for (let i in this.availableCredits) {
                        this.availableCredits[i].credNote.credNoteurl = '/' + this.availableCredits[i].credNote.Id;
                        this.availableCredits[i].credNote.amountDue = (parseFloat(this.availableCredits[i].credNote.ERP7__Balance__c) - parseFloat(this.availableCredits[i].debitAmount)).toFixed(2);
                        this.availableCredits[i].credNote.maxValue = this.availableCredits[i].credNote.ERP7__Balance__c;
                    }

                    this.isavailableCredits = this.availableCredits.length > 0 ? true : false;
                    this.spinner = false;
                    this.isApplyCreditsModal = true;
                })
                .catch(error => {
                    this.spinner = false;
                    console.log('Error:', error);
                })
        } catch (e) {
            this.spinner = false;
            console.log('Error:', e);
        }

    }
    closeApplyCreditModal() {
        this.isApplyCreditsModal = false;
        const paymentEvent = new CustomEvent('payment', {});
        this.dispatchEvent(paymentEvent);
    }

    updateDebitAmount(event) {
        console.log('event.currentTarget.value:', event.currentTarget.value);
        if (event.currentTarget.value == '') {
            this.availableCredits[event.currentTarget.dataset.index].debitAmount = 0;
        } else {
            this.availableCredits[event.currentTarget.dataset.index].debitAmount = parseFloat(event.currentTarget.value).toFixed(2);
        }
        this.availableCredits[event.currentTarget.dataset.index].credNote.amountDue = (parseFloat(this.availableCredits[event.currentTarget.dataset.index].credNote.ERP7__Balance__c) - parseFloat(this.availableCredits[event.currentTarget.dataset.index].debitAmount)).toFixed(2);
        console.log('this.availableCredits[event.currentTarget.dataset.index]:', this.availableCredits[event.currentTarget.dataset.index]);
        this.appliedCreditAmount = 0;
        this.balanceAmount = 0;
        for (let i in this.availableCredits) {
            this.appliedCreditAmount = (parseFloat(this.appliedCreditAmount) + parseFloat(this.availableCredits[i].debitAmount)).toFixed(2);
            this.balanceAmount = (parseFloat(this.paymentToUpsert.ERP7__Total_Amount__c) - parseFloat(this.appliedCreditAmount)).toFixed(2);
        }

    }

    applyCreditSave() {
        this.paymentError = undefined;
        this.order.ERP7__Due_Amount__c

        this.paymentError = undefined;

        if (this.invoiceToPay.length == 0) {
            this.paymentError = 'Due Invoice not available to pay';
            return;
        }
        let count = 0;
        //let ifSingleInv = '';
        //let invAndAmountIndex = 0;
        //let salesInvCount = 0;
        //let advInvCount = 0;
        //let isAdvance = false;
        for (let i in this.invoiceToPay) {
            if (count > 0)
                break
            if (this.invoiceToPay[i].checked) {
                count++;
                //invAndAmount[invAndAmountIndex] = { Id: this.invoiceToPay[i].Id, ERP7__Invoice_Amount__c: this.invoiceToPay[i].AmountToPaid };
                //invAndAmountIndex++;
                //ifSingleInv = this.invoiceToPay[i].Id;

                //if (this.invoiceToPay[i].RecordType.DeveloperName == 'Advance') { advInvCount++; isAdvance = true; }
                //if (this.invoiceToPay[i].RecordType.DeveloperName == 'Sale') salesInvCount++;
            }
        }
        //if (salesInvCount > 0 && advInvCount > 0) {
        //this.paymentError = 'Can not redeem sales and advance invoices together.';
        //return;
        //}
        //if (count == 1) this.paymentToUpsert.ERP7__Invoice__c = ifSingleInv;
        if (count == 0) {
            this.paymentError = 'Please select invoice to apply credit';
            return;
        }
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked && parseFloat(this.invoiceToPay[i].AmountToPaid) <= 0) {
                this.paymentError = this.invoiceToPay[i].Name + ' : Amount To Paid can not be zero or negative';
                return;
            }
            for (let j in this.invoiceList) {
                if (this.invoiceList[j].Id == this.invoiceToPay[i].Id && parseFloat(this.invoiceList[j].ERP7__Total_Due__c) < parseFloat(this.invoiceToPay[i].AmountToPaid)) {
                    this.paymentError = this.invoiceToPay[i].Name + ' : Amount Can not be greater than due amount';
                    return;
                }
            }

        }

        if (!this.paymentToUpsert.ERP7__Total_Amount__c || this.paymentToUpsert.ERP7__Total_Amount__c <= 0) {
            this.paymentError = 'Invoice Amount can not be zero or negative';
            return;
        }

        /*if (this.appliedCreditAmount > this.paymentToUpsert.ERP7__Total_Amount__c) {
            this.paymentError = 'Applied Credit can not be greater than Invoice Amount';
            return;
        }*/

        if (this.balanceAmount < 0) {
            this.paymentError = 'Balance Amount can not be negative';
            return;
        }

        if (this.appliedCreditAmount <= 0) {
            this.paymentError = 'Applied Credit can not be zero or negative.';
            return;
        }

        this.spinner = true;
        let invoice2Update = {};
        for (let i in this.invoiceToPay) {
            if (this.invoiceToPay[i].checked) {
                invoice2Update.Id = this.invoiceToPay[i].Id;
                invoice2Update.ERP7__Order_S__c = this.invoiceToPay[i].ERP7__Order_S__c;
                invoice2Update.Name = this.invoiceToPay[i].Name;
                invoice2Update.ERP7__Account__c = this.invoiceToPay[i].ERP7__Account__c;
                invoice2Update.ERP7__Credit_Note_Issued__c = true;
                if (this.invoiceToPay[i].ERP7__Credit_Note__c)
                    invoice2Update.ERP7__Credit_Note__c = (parseFloat(this.invoiceToPay[i].ERP7__Credit_Note__c) + parseFloat(this.appliedCreditAmount)).toFixed(2);
                else
                    invoice2Update.ERP7__Credit_Note__c = parseFloat(this.appliedCreditAmount).toFixed(2);
            }
        }

        for (let i in this.availableCredits) {
            delete this.availableCredits[i].credNote.credNoteurl;
            delete this.availableCredits[i].credNote.amountDue;
            delete this.availableCredits[i].credNote.maxValue;
        }
        console.log('invoice2Update:', invoice2Update);
        applyCreditInvoice({
            inv: JSON.stringify(invoice2Update),
            creditNotes: JSON.stringify(this.availableCredits),
            totalDebitAmount: this.appliedCreditAmount,
        })
            .then(result => {
                console.log('result:', result);
                if (result.includes('Credit Applied Successfully')) {
                    const event = new ShowToastEvent({
                        variant: 'success',
                        message: result,
                    });
                    this.dispatchEvent(event);
                    this.isApplyCreditsModal = false;
                    this.spinner = false;
                    const paymentEvent = new CustomEvent('payment', {});
                    this.dispatchEvent(paymentEvent);
                }
            })
            .catch(error => {
                console.log('Error:', error);
                this.spinner = false;
            })


    }

    openApplyLoyalty() {
				console.log('accId:',this.order.AccountId);
        console.log(' org:',this.order.ECPQ__Organisation__c);
        fetchApplyLoyaltyInitial({
            accId: this.order.AccountId,
            org: this.order.ERP7__Organisation__c,
        })
            .then(result => {
                console.log("result of fetchApplyLoyaltyInitial:", result);
                this.loyalityCards = result;
                if (this.loyalityCards.length == 0)
                    this.paymentError = 'Loyalty Card not found';
                this.loyaltyValue = result.length > 0 ? (parseFloat(this.order.Account.ERP7__total_points__c) / parseFloat(result[0].ERP7__Points_Per_Unit_Amount__c)).toFixed(2) : 0;

                this.isLoyaltyModal = true;
            })
            .catch(error => {
                console.log('Error:', error);
            })
    }
    closeApplyLoyalty() {
        this.isLoyaltyModal = false;
        this.showApplyLoyaltySave = true;
    }
    handleRedeemPoint(event) {
        this.redeemPoints = event.currentTarget.value;
        if (this.redeemPoints == '')
            this.showApplyLoyaltySave = true;
        else
            this.showApplyLoyaltySave = false;
    }

    applyLoyaltySave() {
        try {
            if (!this.redeemPoints || this.redeemPoints == '') {
                this.paymentError = 'Enter Redeem Points';
                return;
            }
            if (this.loyalityCards.length == 0) {
                this.paymentError = 'Loyalty Card not found';
                return;
            }



            applyLoyalty({
                loyalityCards: JSON.stringify(this.loyalityCards),
                ordId: this.order.Id,
                loyaltyPoints: this.redeemPoints,
            })
                .then(result => {
                    console.log('result of applyLoyalty:', result);
                    if (result.includes('Loyalty Apply Successfully')) {
                        const event = new ShowToastEvent({
                            variant: 'success',
                            message: result,
                        });
                        this.dispatchEvent(event);
                        const paymentEvent = new CustomEvent('payment', {});
                        this.dispatchEvent(paymentEvent);
                        this.isLoyaltyModal = false;

                    }
                })
                .catch(error => {
                    console.log('Error:', error);
                })
        } catch (e) {
            console.log('Error:', e);
        }


    }



}