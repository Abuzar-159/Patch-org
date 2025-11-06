import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchToAddress from '@salesforce/apex/CanadaPost.fetchToAddress';
import fetchFromAddress from '@salesforce/apex/CanadaPost.fetchFromAddress';
import fetchingPackages from '@salesforce/apex/CanadaPost.fetchingPackages';
import getCredentialDetails from '@salesforce/apex/CanadaPost.getCredentialDetails';
import Shipping_Rate_Request from '@salesforce/apex/CanadaPost.Shipping_Rate_Request';
import Shipping_Request_Reply from '@salesforce/apex/CanadaPost.Shipping_Request_Reply';
import getServices from '@salesforce/apex/CanadaPost.getServices';
import Refund_Request_Reply from '@salesforce/apex/CanadaPost.Refund_Request_Reply';
import Void_Request_Reply from '@salesforce/apex/CanadaPost.Void_Request_Reply';
import Transmit_Request_Reply from '@salesforce/apex/CanadaPost.Transmit_Request_Reply';
import getStatusConfirmation from '@salesforce/apex/CanadaPost.getStatusConfirmation';
//import PickupAvailability_Reply from '@salesforce/apex/CanadaPost.PickupAvailability_Reply';
//import CreatePickup_Reply from '@salesforce/apex/CanadaPost.CreatePickup_Reply';
//import CancelPickup_Reply from '@salesforce/apex/CanadaPost.CancelPickup_Reply';
import Track_Request_Reply from '@salesforce/apex/CanadaPost.Track_Request_Reply';
//import Signature_Proof_Reply from '@salesforce/apex/CanadaPost.Signature_Proof_Reply';

export default class Canadapost extends LightningElement {
	@api ShipId = '';
	@api PackageIDs = [];
	@api fromShipment = false;
	@api fromPackage = false;
	@track shippingIcon = 'standard:work_order';
	@track PrcsShipIcon = 'utility:ad_set';
	@track truckIcon  = 'standard:work_order';
	@track shipment = { ERP7__Status__c: '' };
	@track Toaddress = '';
	@track fromAddress = '';
	@track myConsW = '';
	@track serviceVal = '';
	@track Statusoptions = [];
	isLoading = false;
	ShowGetRate = false;
	ShowTrackDetails = false;
	ShowTimeInCostTab = false;
	@track SignatureProofId = false;
	@track toAddressSelected = false;
	@track toAddressUrl = '';
	@track fromAddressSelected = false;
	@track fromAddressUrl = '';
	errorMsg = false;
	WrapperMsg = false;
	errorMsg1 = false;
	@track CP_Services = '';
	@track serviceOptions = [];
	@track quotes = [];
	@track selectedService = '';
	@track fromShip = false;

	connectedCallback() {
			try {
					this.ShowGetRate = true;
					this.isLoading = true;
					this.ShowTimeInCostTab = false;
					var today = new Date();
					var monthDigit = today.getMonth() + 1;
					var datetoday=today.getDate();
					if (monthDigit <= 9) { monthDigit = '0' + monthDigit; }
					if(today.getDate() <=9 ){ datetoday ='0' + +datetoday;}
					this.shipment.ERP7__Shipment_Date__c = today.getFullYear() + "-" + monthDigit + "-" + datetoday;//today.getDate();
					console.log('this.shipment.ERP7__Shipment_Date__c::', this.shipment.ERP7__Shipment_Date__c);
					this.serviceVal = this.shipment.ERP7__Services__c != null ? this.shipment.ERP7__Services__c : 'DC';

					console.log('ShowGetRate::', this.serviceVal);
					console.log('JSON.stringify(this.PackageID)' + JSON.stringify(this.PackageIDs));

					getCredentialDetails({ shipId: this.ShipId, retValue: this.retValue, packId: JSON.stringify(this.PackageIDs)}).then(result => {
							console.log('getCredentialDetails');
							try {
									this.errorMsg1 = result.wrapError;
									this.myConsW = result;
									this.retValue = result.retValue;
									this.fromAddress = result.fromAddress;
									console.log('result'+ JSON.stringify(result));
									console.log('this.fromAddress' + JSON.stringify(this.fromAddress));
									this.Toaddress = result.toAddress;
									if (this.Toaddress.Id) {
							this.toAddressSelected = true;
							this.toAddressUrl = '/' + this.Toaddress.Id;
						}
									if (this.fromAddress.Id) {
							this.fromAddressSelected = true;
							this.fromAddressUrl = '/' + this.fromAddress.Id;
						}
									console.log('this.Toaddress' + JSON.stringify(this.Toaddress));
									console.log('this.ShipId' + this.ShipId);
									this.fromShip = false;
									if (this.ShipId != 'undefined' && this.ShipId != null && this.ShipId != undefined && this.ShipId != '') {
										this.fromShip = true;
											console.log('Inside ShipId')
											this.shipment = result.Shipment;
											this.AttachId = result.AttachLabel.Id;
											this.SignatureProofId = result.spodLetter.Id;
											console.log('SignatureProofId'+this.SignatureProofId);
											this.fromAddress = result.fromAddress;
											console.log('this.fromAddress' + this.fromAddress);
											this.Toaddress = result.toAddress;
											this.packages = result.Packages;
											for (var x in this.packages) {
						this.packages[x].packUrl = '/' + this.packages[x].Id;
					}
											console.log('this.shipment' + JSON.stringify(this.shipment));
											this.bufferLabel = result.bufferLabel;
											if (result.Shipment.ERP7__Status__c == 'Shipped') {
													this.ShowGetRate = false;
													this.CP_Services = result.cpWrap;
													this.CP_Services.showAndHideMap3 = false;
													this.CP_Services.showAndHideMap2 = true;
													this.CP_Services.showAndHideMap11 = true;
											}
											if (result.Shipment.ERP7__Status__c == 'Picked Up') {
													this.ShowGetRate = false;
													this.CP_Services = result.cpWrap;
											}
											if (result.Shipment.ERP7__Status__c == 'Delivered') {
													this.ShowGetRate = false;
													this.CP_Services = result.cpWrap;
											}
											if (result.Shipment.ERP7__Status__c == 'Transmitted') {
													this.ShowGetRate = false;
													this.CP_Services = result.cpWrap;
													this.CP_Services.showAndHideMap3 = true;
													this.CP_Services.showAndHideMap2 = true;
													this.CP_Services.showAndHideMap11 = false;
											}
												console.log('this.CP_Services.showAndHideMap3' + this.CP_Services.showAndHideMap3);
												console.log('this.CP_Services.showAndHideMap2' + this.CP_Services.showAndHideMap2);
											console.log('this.CP_Services.showAndHideMap11' + this.CP_Services.showAndHideMap11);
									}
							} catch (e) {
									console.log('error' + e);
							}
							console.log('ShipmentRecTypeId' + this.retValue);
					})
							.catch(error => {
							console.log('error' + error);
							setTimeout(() => { this.isLoading = false;}, 2000);
							this.dispatchEvent(
									new ShowToastEvent({
											message: error.body.message + ' ' + error.stack + ' ' + error.name,
											variant: "error"
									})
							);
					});

				/*	getServices().then(result => {
							try {
									console.log('getServices');
									var options = [];
									for (let i in result) {
											options.push({ label: result[i], value: i });
									}
									if (options.length > 0) this.serviceOptions = options;
									console.log('serviceOptions : ', JSON.stringify(this.serviceOptions));
							} catch (e) {
									console.log('error' + e);
							}
					})
							.catch(error => {
							setTimeout(() => { this.isLoading = false;}, 2000);
							this.dispatchEvent(
									new ShowToastEvent({
											message: error.body.message + ' ' + error.stack + ' ' + error.name,
											variant: "error"
									})
							);
					})*/

					getStatusConfirmation().then(res => {
							var options = [];
							if (res != null && res.length > 0) {
									for (let i = 0; i < res.length; i++) {
											options.push({ label: res[i], value: res[i] });
											console.log(options);
									}
							}
							if (options.length > 0) this.Statusoptions = options;
							console.log('Statusoptions : ', JSON.stringify(this.Statusoptions));
					});

					if (this.ShipId == null || this.ShipId == '' || this.ShipId == 'undefined' || this.ShipId == undefined) {

							/*fetchToAddress({ packId: JSON.stringify(this.PackageIDs) }).then(result => {
									this.Toaddress = result;
									console.log('Toaddress' + JSON.stringify(this.Toaddress));
							})
									.catch(error => {
									console.log('error' + error);
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							});*/

						/*	fetchFromAddress({ packId: JSON.stringify(this.PackageIDs) }).then(result => {
									this.fromAddress = result;
									console.log('fromAddress' + JSON.stringify(this.fromAddress));
							})
									.catch(error => {
									console.log('error' + error);
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							});*/

							fetchingPackages({ packId: JSON.stringify(this.PackageIDs) }).then(result => {
									this.packages = result;
										for (var x in this.packages) {
						this.packages[x].packUrl = '/' + this.packages[x].Id;
					}
									console.log('packages' + JSON.stringify(this.packages));
							})
									.catch(error => {
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							});
					}
					setTimeout(() => { this.isLoading = false;}, 2000);
			} catch (e) {
					console.log('error' + e);
			}
	}

	renderedCallback() {
			console.log('renderedCallback')
			//setTimeout(() => { this.isLoading = false;}, 2000);
	}

	setshipmentdate(event) {
			this.shipment.ERP7__Shipment_Date__c = event.target.value;
			console.log(this.shipment.ERP7__Shipment_Date__c);
	}
	setpickdate(event) {
			this.shipment.ERP7__Package_Ready_Time__c = event.target.value;
			console.log(this.shipment.ERP7__Package_Ready_Time__c);
	}

	handleServiceChange(event) {
			this.shipment.ERP7__Services__c = event.detail.value;
	}

	handleChange(event) {
			this.shipment.ERP7__Status__c = event.detail.value;
	}

	handleStartChange(event) {
			this.shipment.ERP7__Preferred_Time__c = event.detail.value;
	}

	handleCloseChange(event) {
			this.shipment.ERP7__Closing_Time__c = event.detail.value;
	}

	getSelectedService(event) {
			console.log('getSelectedService');
			let checked = event.target.checked;
			console.log(checked);
			var index = event.currentTarget.dataset.recordId;
			console.log(index);
			for (let i = 0; i < this.CP_Services.length; i++) {
					this.CP_Services[i].Selected = false;
					if (i == index) {
							this.CP_Services[i].Selected = checked;
							console.log('this.CP_Services[i].serviceCode: ' + this.CP_Services[i].serviceCode);
							console.log('this.CP_Services[i].serviceCode: ' + this.CP_Services[i].serviceCode);
							console.log('value matched : ' + this.CP_Services[i].Selected);
							this.selectedService= this.CP_Services[i].serviceCode
					}
			}
			console.log('ShipService~>' + this.selectedService);
	}
	Refund_CP(){
			var viewLabel =  'https://www.canadapost-postescanada.ca/cpc/en/support/kb/business/commercial-billing/how-to-cancel-a-shipment-manifest-online';//'https://www.canadapost-postescanada.ca/information/app/ccm/business/som?execution=e1s1';//'https://www.canadapost-postescanada.ca/cpc/en/support/kb/business/commercial-billing/how-to-cancel-a-shipment-manifest-online';
			window.open(viewLabel, '_blank');
	}

	Refund_Request() {
			this.isLoading = true;
			this.errorMsg1 = '';
			this.CP_Services.UPSErrorMsg = '';

			var today = new Date();
			var monthDigit = today.getMonth() + 1;
			if (monthDigit <= 9) {
					monthDigit = '0' + monthDigit;
			}
			var packId = this.packages;
			var Toaddress = this.Toaddress.Id;
			var fAddress = this.fromAddress.Id;
			var myConsVariable = JSON.stringify(this.myConsW);
			var errorFlag = true;
			var errorMsg = '';

			if (this.shipment.ERP7__Status__c == null || this.shipment.ERP7__Status__c == '' || this.shipment.ERP7__Status__c == undefined) {
					errorFlag = false;
					errorMsg = 'The Shipment Is Unavailable.';
			}

			/*if (this.shipment.ERP7__Status__c != 'Shipped') {
					errorFlag = false;
					errorMsg = errorMsg + ' ' + 'Request To Cancel Shipment Cannot Be Processed.';
			}*/

			if (this.shipment.ERP7__Pickup_Requested__c == true) {
					errorFlag = false;
					errorMsg = errorMsg + ' ' + 'Shipment Pickup Is Active Thus, Request To Cancel The Shipment Cannot Be Processed.';
			}

			if (errorMsg != null || errorMsg == '') this.errorMsg1 == errorMsg;
			console.log('this.shipme' + JSON.stringify(this.shipment));
			if (errorFlag) {
					Refund_Request_Reply({
							Shipment: JSON.stringify(this.shipment),
							packList: packId,
							tAddress: Toaddress,
							fAddress: fAddress,
							myConsVar: myConsVariable
					})
							.then(result => {
							this.CP_Services = result;
							this.errorMsg1 = result.Error;
							//this.WrapperMsg = result.UPSErrorMsg;
							this.WrapperMsg ='The service ticket number/s: '+result.Shipment.ERP7__Message__c;
							this.AttachId = result.AttachLabel.Id;
							if (result.UPSErrorMsg == 'Shipment deleted successfully') {
									this.shipment = result.Shipment;
									this.ShowGetRate = false;
										this.dispatchEvent(
						new ShowToastEvent({
							message: 'Shipment deleted successfully',
							variant: "success"
							})
					); 
							}
							setTimeout(() => { this.isLoading = false;}, 2000);
							console.log('this.CP_Services' + JSON.stringify(this.CP_Services));
							console.log('this.errorMsg' + this.errorMsg);
							console.log('result.UPSErrorMsg' + result.UPSErrorMsg);
					})
							.catch(error => {
							console.log('error catch ' + JSON.stringify(error));
							setTimeout(() => { this.isLoading = false;}, 2000);
							this.dispatchEvent(
									new ShowToastEvent({
											message: error.body.message + ' ' + error.stack + ' ' + error.name,
											variant: "error"
									})
							);
					});
			} else {
					console.log('Cancel_Request no errorFlag false');
			}
	}
	Void_Request() {
			console.log('Inside');
			this.isLoading = true;
			this.errorMsg1 = '';
			this.CP_Services.UPSErrorMsg = '';

			var today = new Date();
			var monthDigit = today.getMonth() + 1;
			if (monthDigit <= 9) {
					monthDigit = '0' + monthDigit;
			}
			var packId = this.packages;
			var Toaddress = this.Toaddress.Id;
			var myConsVariable = JSON.stringify(this.myConsW);
			var errorFlag = true;
			var errorMsg = '';

			if (this.shipment.ERP7__Status__c == null || this.shipment.ERP7__Status__c == '' || this.shipment.ERP7__Status__c == undefined) {
					errorFlag = false;
					errorMsg = 'The Shipment Is Unavailable.';
			}

			if (this.shipment.ERP7__Status__c != 'Shipped') {
					errorFlag = false;
					errorMsg = errorMsg + ' ' + 'Request To Cancel Shipment Cannot Be Processed.';
			}

			if (this.shipment.ERP7__Pickup_Requested__c == true) {
					errorFlag = false;
					errorMsg = errorMsg + ' ' + 'Shipment Pickup Is Active Thus, Request To Cancel The Shipment Cannot Be Processed.';
			}

			if (errorMsg != null || errorMsg == '') this.errorMsg1 == errorMsg;
			console.log('this.shipme' + JSON.stringify(this.shipment));
			if (errorFlag) {
					Void_Request_Reply({
							Shipment: JSON.stringify(this.shipment),
							packList: packId,
							tAddress: Toaddress,
							myConsVar: myConsVariable
					})
							.then(result => {
							this.CP_Services = result;
							this.errorMsg1 = result.Error;
							//this.WrapperMsg = result.UPSErrorMsg;
							if (result.UPSErrorMsg == 'Shipment deleted successfully') {
									
									this.ShowGetRate = false;
									this.WrapperMsg='';
									this.shipment = result.Shipment;
									this.CP_Services.showAndHideMap11=false;
									this.CP_Services.showAndHideMap8=false;
									this.ShowTrackDetails=false;
										this.dispatchEvent(
						new ShowToastEvent({
							message: 'Shipment deleted successfully',
							variant: "success"
							})
					); 
							}else{
									this.WrapperMsg = result.UPSErrorMsg;
							}
							setTimeout(() => { this.isLoading = false;}, 2000);
							console.log('this.CP_Services' + JSON.stringify(this.CP_Services));
							console.log('this.errorMsg' + this.errorMsg);
							console.log('result.UPSErrorMsg' + result.UPSErrorMsg);
					})
							.catch(error => {
							console.log('error catch ' + JSON.stringify(error));
							setTimeout(() => { this.isLoading = false;}, 2000);
							this.dispatchEvent(
									new ShowToastEvent({
											message: error.body.message + ' ' + error.stack + ' ' + error.name,
											variant: "error"
									})
							);
					});
			} else {
					console.log('Cancel_Request no errorFlag false');
			}
	}
	Transmit_Request() {
			console.log('Inside');
			this.isLoading = true;
			this.errorMsg1 = '';
			this.CP_Services.UPSErrorMsg = '';

			var today = new Date();
			var monthDigit = today.getMonth() + 1;
			if (monthDigit <= 9) {
					monthDigit = '0' + monthDigit;
			}
			var packId = this.packages;
			var Toaddress = this.Toaddress.Id;
			var Fromaddress = this.fromAddress.Id;
			var myConsVariable = JSON.stringify(this.myConsW);
			var errorFlag = true;
			var errorMsg = '';

			if (this.shipment.ERP7__Status__c == null || this.shipment.ERP7__Status__c == '' || this.shipment.ERP7__Status__c == undefined) {
					errorFlag = false;
					errorMsg = 'The Shipment Is Unavailable.';
			}

			if (this.shipment.ERP7__Status__c != 'Shipped') {
					errorFlag = false;
					errorMsg = errorMsg + ' ' + 'Request To Cancel Shipment Cannot Be Processed.';
			}

			if (this.shipment.ERP7__Pickup_Requested__c == true) {
					errorFlag = false;
					errorMsg = errorMsg + ' ' + 'Shipment Pickup Is Active Thus, Request To Cancel The Shipment Cannot Be Processed.';
			}

			if (errorMsg != null || errorMsg == '') this.errorMsg1 == errorMsg;
			console.log('this.shipme' + JSON.stringify(this.shipment));
			if (errorFlag) {
					Transmit_Request_Reply({
							Shipment: JSON.stringify(this.shipment),
							packList: packId,
							tAddress: Toaddress,
							fAddress: Fromaddress,
							myConsVar: myConsVariable
					})
							.then(result => {
							//this.CP_Services = result;
							this.errorMsg1 = result.Error;
							this.WrapperMsg = result.UPSErrorMsg;
							if (result.UPSErrorMsg == 'Shipment transmitted successfully') {
									this.CP_Services.showAndHideMap2 = true;
									this.CP_Services.showAndHideMap11 = false;
											this.CP_Services.showAndHideMap3 = true;
									this.shipment = result.Shipment;
									//this.ShowGetRate = true;
									this.dispatchEvent(
						new ShowToastEvent({
							message: 'Shipment transmitted successfully',
							variant: "success"
							})
					); 
							}
							setTimeout(() => { this.isLoading = false;}, 2000);
							this.AttachId = result.AttachLabel.Id;
							console.log('this.CP_Services.showAndHideMap2' + this.CP_Services.showAndHideMap2);
							console.log('this.CP_Services.showAndHideMap11' + this.CP_Services.showAndHideMap11);
							console.log('this.CP_Services.showAndHideMap3' + this.CP_Services.showAndHideMap3);
							console.log('this.CP_Services' + JSON.stringify(this.CP_Services));
							console.log('this.errorMsg' + this.errorMsg);
							console.log('result.UPSErrorMsg' + result.UPSErrorMsg);
					})
							.catch(error => {
							console.log('error catch ' + JSON.stringify(error));
							setTimeout(() => { this.isLoading = false;}, 2000);
							this.dispatchEvent(
									new ShowToastEvent({
											message: error.body.message + ' ' + error.stack + ' ' + error.name,
											variant: "error"
									})
							);
					});
			} else {
					console.log('Cancel_Request no errorFlag false');
			}
	}

	Rate_Request() {
			try {
					this.errorMsg = '';
					this.WrapperMsg = '';
					this.errorMsg1 = '';
					this.isLoading = true;
					var today = new Date();
					var monthDigit = today.getMonth() + 1;
					if (monthDigit <= 9) {
							monthDigit = '0' + monthDigit;
					}
					var dayDigit = today.getDate();
					if (dayDigit <= 9) {
							dayDigit = '0' + dayDigit;
					}
					var todayDate = today.getFullYear() + '-' + monthDigit + '-' + dayDigit;
					var fromAddress = this.fromAddress.Id;
					var Toaddress = this.Toaddress.Id;
					var shipmentDate = this.shipment.ERP7__Shipment_Date__c;
					var ShipService = this.selectedService;//this.shipment.ERP7__Services__c;
					var errorFlag = true;
					var errorMsg = '';
					
					console.log('ShipService~>' + ShipService);

					console.log('todayDate~>' + todayDate);
					console.log('shipmentDate ~>' + shipmentDate);

					if (this.Toaddress.ERP7__Postal_Code__c == '' || this.Toaddress.ERP7__Postal_Code__c == null) {
							errorFlag = false;
							errorMsg = 'To Address Postal Code Unavailable.';
					}

					if (this.Toaddress.ERP7__Country__c == '' || this.Toaddress.ERP7__Country__c == null) {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'To Address Country Unavailable.';
					}

					if (this.fromAddress.ERP7__Postal_Code__c == '' || this.fromAddress.ERP7__Postal_Code__c == null) {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'From Address Postal Code Unavailable.';
					}

					if (this.fromAddress.ERP7__Country__c == '' || this.fromAddress.ERP7__Country__c == null) {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'From Address Country Unavailable.';
					}

					if (this.shipment.ERP7__Status__c == 'Shipped' || this.shipment.ERP7__Status__c == 'Delivered') {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'This Package Has Already Been ' + this.shipment.ERP7__Status__c + '.';
					}

					if (this.shipment.ERP7__Shipment_Date__c < todayDate) {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'The Shipment Date Should Not Be In Past.';
					}

					if (errorMsg != null || errorMsg != '') this.errorMsg1 = errorMsg;

					if (errorFlag) {
							this.errorMsg = '';
							console.log('Shipping_Rate_Request 1~>');
							Shipping_Rate_Request({
									packList: this.packages,
									fromAdd: fromAddress,
									tAddress: Toaddress,
									shipDate: shipmentDate,
									ShipService: ShipService,
									myConsVar: JSON.stringify(this.myConsW)
							})
									.then(result => {
									/*var res= JSON.stringify(result);
									console.log('Result 1: ' + res);
									console.log('Result 2:' + result);
									console.log('Result 3:' + res.quotes);
									console.log('Shipping_Rate_Request');*/
									console.log('Apex Result:', result);
									//this.quotes = result.quotes;
									//console.log('quotes:' + quotes);
									if(result.quotes != undefined || result.quotes != null || result.quotes !=''){
											this.CP_Services = result.quotes;
											this.ShowTimeInCostTab = true;//result.time_in_cost_tab;
											this.ShowGetRate = false;
									}else{
									this.errorMsg1 = result.errorMessage;
									console.log('this.errorMsg' + this.errorMsg1);
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.WrapperMsg = result.errorMessage;
									console.log('this.WrapperMsg' + this.WrapperMsg);
											
									}
									//this.errorMsg1 = result.errorMessage;
									setTimeout(() => { this.isLoading = false;}, 2000);
								//	this.WrapperMsg = result.errorMessage;
									console.log('this.CP_Services' + JSON.stringify(this.CP_Services));
									console.log('this.ShowTimeInCostTab' + this.ShowTimeInCostTab);
									console.log('result ErrorUPSErrorMsg' + result.UPSErrorMsg);
							})
									.catch(error => {
										console.log('error catch ' , error);
									console.log('error catch ' + JSON.stringify(error));
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: 'error',//error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							})
							console.log('Shipping_Rate_Request after');
					} else {
							console.log('Shipping_Rate errorFlag false~>' + errorFlag);
							this.ShowTimeInCostTab = false;
							this.WrapperMsg = '';
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	Shipping_Request() {
			console.log('Shipping_Request');
			try {
					this.isLoading = true;
					this.errorMsg = '';
					this.errorMsg1 = '';
					this.WrapperMsg = '';
					this.CP_Services.UPSErrorMsg = '';
					var today = new Date();
					var monthDigit = today.getMonth() + 1;
					if (monthDigit <= 9) {
							monthDigit = '0' + monthDigit;
					}
					var dayDigit = today.getDate();
					if (dayDigit <= 9) {
							dayDigit = '0' + dayDigit;
					}
					var todayDate = today.getFullYear() + '-' + monthDigit + '-' + dayDigit;
					var errorFlag = true;
					var errorMsg = '';
					var rateWrapper = '';
					/*var rateWrapperList = this.CP_Services;

					var rateWrapper = '';
					for (var x in rateWrapperList) {
							if (rateWrapperList[x].Selected == true) rateWrapper = JSON.stringify(rateWrapperList[x]);
					}*/

					var fromAddress = this.fromAddress.Id;
					var Toaddress = this.Toaddress.Id;
					var ShipService = this.selectedService;//this.shipment.ERP7__Services__c;var ShipService = this.shipment.ERP7__Services__c;
					var myConsVariable = JSON.stringify(this.myConsW);
						console.log('ShipService~>' + ShipService);

					if (this.shipment.ERP7__Status__c == 'Shipped' || this.shipment.ERP7__Status__c == 'Delivered') {
							errorFlag = false;
							errorMsg = 'This Package Has Already Been ' + this.shipment.ERP7__Status__c + '.';
					}

					if (this.shipment.ERP7__Shipment_Date__c < todayDate) {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'The Shipment Date Should Not Be In Past.';
					}

					/*if (rateWrapper == '' || rateWrapper == null) {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Service Is Unavailable, Please Select At Least One Service From Shipping Service And Cost.';
					}*/

					if (errorMsg != null || errorMsg != '') this.errorMsg1 = errorMsg;

					if (errorFlag) {
							console.log('Shipping_Request errorFlag true');
							console.log('Shipping_Request packList~>' + JSON.stringify(this.packages));
							console.log('Shipping_Request fromAdd~>' + fromAddress);
							console.log('Shipping_Request toAdd~>' + Toaddress);
							console.log('Shipping_Request ShipService~>' + ShipService);
							console.log('Shipping_Request myConsVar~>' + myConsVariable);
							console.log('Shipping_Request Shipment~>' + JSON.stringify(this.shipment));
							console.log('Shipping_Request rateWrapperSelected~>' + rateWrapper);

							Shipping_Request_Reply({
									packList: this.packages,
									fromAdd: fromAddress,
									tAddress: Toaddress,
									ShipService: ShipService,
									myConsVar: myConsVariable,
									Shipment: JSON.stringify(this.shipment),
									rateWrapperSelected: rateWrapper
							}).then(result => {
									console.log('Shipping_Request_Reply');
									try {
											//this.CP_Services = result;
											this.showSendReturnLabel = result.showreturnlabel;
											this.errorMsg1 = result.Error;
											this.shipment = result.Shipment;
											this.bufferLabel = result.bufferLabel;
											this.AttachId = result.AttachLabel.Id;
											this.ShowTimeInCostTab = false;
											this.CP_Services.showAndHideMap2= result.showAndHideMap2;
											this.CP_Services.showAndHideMap8=true;
											this.CP_Services.showAndHideMap11=true;
											this.bufferlbl = '/servlet/servlet.FileDownload?file=' + this.bufferLabel.Id;
											if (this.shipment.ERP7__Status__c == 'Shipped') {
													this.WrapperMsg = result.UPSErrorMsg;
													this.ShowGetRate = false;
											}
											if(result.Result == 'Shipment Created successfully'){
														//setTimeout(() => { this.isLoading = false;}, 4000);
					console.log('inside res equal 200');
					this.dispatchEvent(
						new ShowToastEvent({
							message: 'Shipment Created successfully',
							variant: "success"
							})
					); 
													setTimeout(() => { this.isLoading = false;}, 4000);

				}
											console.log('this.CP_Services' + JSON.stringify(this.CP_Services));
											console.log('this.showSendReturnLabel' + JSON.stringify(this.showSendReturnLabel));
											console.log('this.errorMsg' + this.errorMsg1);
											console.log('this.shipment' + this.shipment);
											console.log('this.bufferLabel' + this.bufferLabel);
									} catch (e) {
											console.log('error inside ' + e);
									}
									//setTimeout(() => { this.isLoading = false;}, 4000);
							})
									.catch(error => {
									console.log('error catch ' + JSON.stringify(error));
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							})
					} else {
							console.log('Shipping_Request errorFlag false~>' + errorFlag);
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	CreateCanadaPostLabel() {
			try {
					var attachId = this.AttachId;
					console.log('ShipId' + attachId);
					if (attachId != null && attachId != '') {
							var viewLabel = '/servlet/servlet.FileDownload?file=' + attachId;
							window.open(viewLabel, '_blank');
					}
			} catch (e) {
					console.log('error' + e);
			}
	}
	
			CreateManifestLabel() {
			try {
					var attachId = this.AttachId;
					console.log('ShipId' + attachId);
					if (attachId != null && attachId != '') {
							var viewLabel = '/servlet/servlet.FileDownload?file=' + attachId;
							window.open(viewLabel, '_blank');
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	PickupAvailability() {
			console.log('PickupAvailability');
			try {
					this.errorMsg = '';
					this.CP_Services.UPSErrorMsg = '';

					var fromAddress = this.fromAddress.Id;
					var myConsVariable = JSON.stringify(this.myConsW);

					var errorFlag = true;
					var errorMsg = '';

					if (this.shipment.ERP7__Pickup_Requested__c == true) {
							errorFlag = false;
							errorMsg = 'Shipment Pickup Is Already Active For This Package.';
					}

					if (this.shipment.ERP7__Status__c == 'Delivered') {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Shipment Delivered : Request Cannot Be Processed.';
					}

					if (this.shipment.ERP7__Status__c != 'Shipped') {
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Shipment Status Must Be shipped To Process, Pickup Rate Request.';
					}

					if (errorMsg != null || errorMsg != '') this.errorMsg = errorMsg;

					if (errorFlag) {
							console.log('PickupAvailability2');
							PickupAvailability_Reply({
									fromAdd: fromAddress,
									myConsVar: myConsVariable
							}).then(result => {
									this.CP_Services = result;
									this.errorMsg = result.Error;
									this.ShowGetRate = false;
									this.WrapperMsg = result.UPSErrorMsg;
									console.log('this.CP_Services' + this.CP_Services);
									console.log('this.errorMsg' + this.errorMsg);
							})
									.catch(error => {
									console.log('error catch ' + JSON.stringify(error));
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							})
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	CreatePickup(){
			try{
					this.errorMsg = '';
					this.CP_Services.UPSErrorMsg = '';

					var fromAddress = this.fromAddress.Id;
					var packId = this.packages;
					var startTime = this.shipment.ERP7__Preferred_Time__c;
					var closeTime = this.shipment.ERP7__Closing_Time__c;
					var PackageReadyTime = this.shipment.ERP7__Package_Ready_Time__c;
					var myConsVariable = JSON.stringify(this.myConsW);
					startTime = '"'+startTime.slice(-12,-7)+'"';
					closeTime = '"'+closeTime.slice(-12,-7)+'"';
					console.log('startTime'+typeof startTime);
					console.log('closeTime'+typeof closeTime);
					console.log('PackageReadyTime'+PackageReadyTime);
					var errorFlag = true;
					var errorMsg = '';

					if(this.shipment.ERP7__Pickup_Requested__c == true){
							errorFlag = false;
							errorMsg = 'Shipment Pickup Is Already Active For This Package.';
					}

					if(this.shipment.ERP7__Status__c == 'Delivered'){
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Shipment Delivered : Request Cannot Be Processed.';
					}

					if(this.shipment.ERP7__Status__c != 'Shipped'){
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Shipment Status Must Be shipped To Process, Pickup Rate Request.';
					}

					if(this.shipment.ERP7__Package_Ready_Time__c == null || this.shipment.ERP7__Package_Ready_Time__c == ''){
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Pickup Ready Time Unavailable.';
					}

					if(this.shipment.ERP7__Preferred_Time__c == null || this.shipment.ERP7__Preferred_Time__c == ''){
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Pickup Preferred Time Unavailable.';
					}

					if(this.shipment.ERP7__Closing_Time__c == null || this.shipment.ERP7__Closing_Time__c == ''){
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Pickup Closing Time Unavailable.';
					}

					if(this.shipment.ERP7__Closing_Time__c > this.shipment.ERP7__Preferred_Time__c == ''){
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Pickup Preferred Time is greater than Or Equal to Closing Time.';
					}

					if(errorMsg != null || errorMsg != '') this.errorMsg = errorMsg;

					if(errorFlag){
							CreatePickup_Reply({
									fromAdd: fromAddress,
									packList: packId,
									Shipment:JSON.stringify(this.shipment),
									PackageReadyTime: PackageReadyTime,
									startTime: startTime,
									closeTime: closeTime,
									myConsVar : myConsVariable
							})
									.then(result => {
									this.CP_Services = result;
									this.errorMsg = result.Error;
									this.shipment = result.Shipment;
									this.ShowGetRate = false;
							})
									.catch(error => {
									console.log('error catch ' + JSON.stringify(error));
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							})
					}else{
							console.log('Err : '+JSON.stringify(response.getError()));
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	CancelPickup(){
			try {
					this.errorMsg = '';
					this.CP_Services.UPSErrorMsg = '';

					var packId = this.packages;
					var myConsVariable = JSON.stringify(this.myConsW);

					var errorFlag = true;
					var errorMsg = '';

					if(this.shipment.ERP7__Pickup_Requested__c == false){
							errorFlag = false;
							errorMsg = 'Shipment Pickup Unavailable To Cancel.';
					}

					if(this.shipment.ERP7__Status__c == 'Delivered'){
							errorFlag = false;
							errorMsg = errorMsg + ' ' + 'Shipment Delivered : Request Cannot Be Processed.';
					}

					if(errorMsg != null || errorMsg != '') this.errorMsg = errorMsg;

					if(errorFlag){
							CancelPickup_Reply({
									Shipment: JSON.stringify(this.shipment),
									packList: packId,
									myConsVar: myConsVariable
							})
									.then(result => {
									this.CP_Services = result;
									this.errorMsg = result.Error;
									this.shipment = result.Shipment;
									this.WrapperMsg = result.UPSErrorMsg;
									this.ShowGetRate = false;
							})
									.catch(error => {
									console.log('error catch ' + JSON.stringify(error));
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							})
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	trackShipment(){
			console.log('trackShipment');
			try {
					this.errorMsg = '';
					this.CP_Services.UPSErrorMsg = '';

					var packId = this.packages;
					var myConsVariable = JSON.stringify(this.myConsW);

					var errorFlag = true;
					var errorMsg = '';

					if(this.shipment.ERP7__Status__c != 'Shipped'){
							errorFlag = false;
							errorMsg = 'Request To Track The Shipment Cannot Be Processed.';
					}

					if(errorMsg != null || errorMsg != '') this.errorMsg = errorMsg;

					if(errorFlag){
							console.log('trackShipment'+errorFlag);
							this.isLoading = true;
							Track_Request_Reply({
									Shipment: JSON.stringify(this.shipment),
									packList: packId,
									myConsVar: myConsVariable
							})
									.then(result => {
									this.CP_Services = result;
									//this.CP_Services.trackServices=result;//this.Toaddress.ERP7__Country__c;
									if(this.CP_Services.trackServices.length > 0){
											this.ShowTrackDetails = true;
									}
									if (result.Shipment.ERP7__Status__c == 'Shipped') {
											this.CP_Services.showAndHideMap11 = true;
											this.CP_Services.showAndHideMap3 = false;
									}else if(result.Shipment.ERP7__Status__c != 'Shipped' && result.Shipment.ERP7__Status__c != 'Cancelled'){
											this.CP_Services.showAndHideMap11 = false;
											this.CP_Services.showAndHideMap3 = true;
									}
									this.errorMsg = result.Error;
									this.WrapperMsg = result.UPSErrorMsg;
									this.ShowGetRate = false;
									setTimeout(() => { this.isLoading = false;}, 2000);
							})
									.catch(error => {
									console.log('error catch ' + JSON.stringify(error));
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							})
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	proofOfDelivery(){
			try {
					this.errorMsg = '';
					this.CP_Services.UPSErrorMsg = '';
					var myConsVariable = JSON.stringify(this.myConsW);

					var errorFlag = true;
					var errorMsg = '';

					if(this.shipment.ERP7__Status__c != 'Delivered'){
							errorFlag = false;
							errorMsg = 'Request To Get Signature Proof Of Delivery For This Shipment Cannot Be Processed.';
					}

					if(errorMsg != null || errorMsg != '') this.errorMsg = errorMsg;

					if(errorFlag){
							Signature_Proof_Reply({
									Shipment: JSON.stringify(this.shipment),
									myConsVar: myConsVariable
							})
									.then(result => {
									this.CP_Services = result;
									this.errorMsg = result.Error;
									this.SignatureProofId = result.spodLetter.Id;
									this.ShowGetRate = false;
									this.WrapperMsg = result.UPSErrorMsg;
							})
									.catch(error => {
									console.log('error catch ' + JSON.stringify(error));
									setTimeout(() => { this.isLoading = false;}, 2000);
									this.dispatchEvent(
											new ShowToastEvent({
													message: error.body.message + ' ' + error.stack + ' ' + error.name,
													variant: "error"
											})
									);
							})
					}
			} catch (e) {
					console.log('error' + e);
			}
	}

	podLetter(){
			try{
					var attachId = this.SignatureProofId;
					console.log('ShipId' + attachId);
					if (attachId != null && attachId != '') {
							var viewLabel = '/servlet/servlet.FileDownload?file=' + attachId;
							window.open(viewLabel, '_blank');
					}
			} catch (e) {
					console.log('error' + e);
			}
	}
	handlepostalChange(event) {
			this.fromAddress.ERP7__Postal_Code__c = event.target.value;
			console.log('this.fromAddress.ERP7__Postal_Code__c' + this.fromAddress.ERP7__Postal_Code__c);
	}
	handlepostalChangeTo(event) {
			this.Toaddress.ERP7__Postal_Code__c = event.target.value;
			console.log('this.Toaddress.ERP7__Postal_Code__c' + this.Toaddress.ERP7__Postal_Code__c);
	}
		handleCountryChange(event) {
			this.Toaddress.ERP7__Country__c = event.target.value;
			console.log('this.Toaddress.ERP7__Country__c' + this.Toaddress.ERP7__Country__c);
	}
}