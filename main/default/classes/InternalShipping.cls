public with sharing class InternalShipping {

    public Invoice__c currentInvoice                   { get; set; }  
    public Sales_Order__c currentSalesOrder            { get; set; }   
    public List<Sales_Order_Line_Item__c> currentItems { get; set; }
    public Channel__c currentSalepoint                 { get; set; }
    public Address__c billingAddress                   { get; set; }
    public Address__c shippingAddress                  { get; set; }
    public Contact currentContact                      { get; set; }
    public String customerName                         { get; set; }
    public String customerEmail                        { get; set; }    
    public String billAddress                          { get; set; }
    public String shipAddress                          { get; set; }
    public String fromAddress                          { get; set; }
    public Shipment__c Shipment                        { get; set; } 
    public List<wrapper> productLineItem               { get; set; }
    public String errorMsg1                            { get; set; }
    public String errorMsg                             { get; set; }
    public String rType                                { get; set; } 
    public List<Package__c> Packages                   { get; set; }
    public String Son                                  { get; set; } 
    public String sfId                                 { get; set; } 
    public List<Shipment_Flow__c> Shipflows            { get; set; } 
    public List<Package_List__c> packageLists          { get; set; }
    public Decimal ShippingAmount                      { get; set; }
    public Decimal AdminShippingAmount                 { get; set; }
    public Decimal TotalPrice                          { get; set; }
    
    public InternalShipping(){
       InternalShippingCustom();
    } 
    public Sales_Order__c getCurrentOrder(string Ord){
        currentInvoice = new ERP7__Invoice__c();
        currentSalesOrder = new Sales_Order__c();
        currentItems = new List<Sales_Order_Line_Item__c>();
        currentSalepoint = new Channel__c();
        billingAddress = new Address__c();
        shippingAddress = new Address__c();
        currentContact = new Contact();
        Shipment = new Shipment__c();
        productLineItem = new List<wrapper>();
        Packages = new List<Package__c>();
        Shipflows = new List<Shipment_Flow__c>();
        packageLists = new List<Package_List__c>();
        customerName = '';
        customerEmail = '';
        billAddress = '';
        shipAddress = '';
        fromAddress = '';
        errorMsg1 = '';
        errorMsg = '';
        rType = '';
        Son = '';
        sfId = '';
        ShippingAmount = 0;
        AdminShippingAmount = 0;
        TotalPrice = 0;
        
        return null;
    }
    public Invoice__c getCurrentInv(String soid){
        return null;
    }
    public Void InternalShippingCustom(){       
    } 
    public PageReference Back(){
        return null;
    }
    public PageReference SaveDetails() {
        return Null;
    }
    public PageReference NewShipmentFlow(){      
        return Null;
    }
    public PageReference deleteShipmentFlow() {
        return Null;
    }
    public class wrapper {
        public String Code                 { get; set; }
        public String Product              { get; set; }
        public Decimal BasePrice           { get; set; }
        public Decimal Discount            { get; set; }
        public Decimal Tax                 { get; set; }
        public Decimal TotalPrice          { get; set; }
        public Decimal quantity            { get; set; }
        public String packName             { get; set; }
        public Decimal totalShippingAmount { get; set; }
        
        public wrapper() {  code = ''; packName = '';  product = '';  BasePrice = 0;  Discount = 0;  Tax = 0;  TotalPrice = 0; quantity = 0;  totalShippingAmount = 0;
        }
    }
}