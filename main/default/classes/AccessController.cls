public with sharing class AccessController {
    public Employees__c currentEmployee { get; set; }
    public User currentUser { get; set; }
    public string fullName { get; set; }
    public string address { get; set; }
    public Channel__c[] allSalePoints { get; set; }
    public List<String> salePointNames { get; set; }
    public string panelId { get; set; }
    public string panelName { get; set; }
    public string employee { get; set; }
    public List<Report> ReportDisplay { get; set; }
    public String userAgent { get; set; }
    public Boolean salesPointPP { get; set; }
    public Boolean salesPointiPad { get; set; }
    public Id currentUserId { get; set; }
    public String allFields { get; set; }
    public String query { get; set; }
    public String checkin { get; set; }

    //constructor
    public AccessController() {
        userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        salesPointPP = false;
        salesPointiPad = false;
        checkin = '';
        panelName = '';
        ReportDisplay = new List<Report>();
        employee = '';
    }

    public void iphoneSalesPoint() {
        salesPointPP = true;
        salesPointiPad = false;
    }

    public void ipadSalesPoint() {
        salesPointiPad = true;
        salesPointPP = false;
    }

    public void cancelIphSalesPoint() {
        salesPointiPad = false;
        salesPointPP = false;
    }
    //displays panel
    public string getViewPanel() {
        processPanel();
        return '';
    }

    public void processPanel() {
    }

    public string getEmployeePopup() {
        fetchEmployeeDetails();
        return '';
    }

    //Gets the current user details
    public void fetchEmployeeDetails() {
        try {
        currentUserId = UserInfo.getUserId();
        List<Expense_Line_Item__c> eliEditList;
        allFields = UtilClass.selectStarFromSObject('ERP7__Employees__c');
        UtilClass.FlSCheck(allFields.split(','), 'ERP7__Employees__c');

        query =
            'SELECT ' +
            String.escapeSingleQuotes(allFields) +
            ' , ERP7__Employee_Profiling__r.Name, ERP7__Organisation__r.Name, ERP7__Employee_User__r.phone, ERP7__Reporting_Manager__r.First_Name__c, ERP7__Organisation_Business_Unit__r.Name, ERP7__Channel__r.Name, ERP7__Channel__r.City__c, ERP7__Channel__r.Country__c, ERP7__Channel__r.State_Province__c, ERP7__Channel__r.Street__c, ERP7__Channel__r.Zip_Postal_Code__c, ERP7__Channel__r.id From ERP7__Employees__c Where ERP7__Employee_User__c = : currentUserId  ';
        try {
            if (Schema.sObjectType.Employees__c.isAccessible())
            currentEmployee = Database.query(query);
        } catch (Exception e) {
        }
        if (Schema.sObjectType.Employees__c.fields.First_Name__c.isAccessible() && Schema.sObjectType.Employees__c.fields.Last_Name__c.isAccessible()) fullName = currentEmployee.First_Name__c + ' ' + currentEmployee.Last_Name__c;
        if (Schema.sObjectType.Channel__c.isAccessible() && Schema.sObjectType.Channel__c.fields.Street__c.isAccessible() && Schema.sObjectType.Channel__c.fields.City__c.isAccessible() && Schema.sObjectType.Channel__c.fields.State_Province__c.isAccessible() && Schema.sObjectType.Channel__c.fields.Country__c.isAccessible() && Schema.sObjectType.Channel__c.fields.Zip_Postal_Code__c.isAccessible())
            address = currentEmployee.Channel__r.Street__c + ', ' + currentEmployee.Channel__r.City__c + ', ' +
            currentEmployee.Channel__r.State_Province__c +
            ', ' +
            currentEmployee.Channel__r.Country__c +
            ', ' +
            currentEmployee.Channel__r.Zip_Postal_Code__c;
        try {
            if (Schema.sObjectType.User.isAccessible())
            currentuser = [
                SELECT SmallPhotoUrl
                FROM User
                WHERE Id = :currentUserId
            ];
        } catch (Exception e) {
        }
        salePointNames = new List<String>{};
        allFields = UtilClass.selectStarFromSObject('ERP7__Channel__c');
        UtilClass.FlSCheck(allFields.split(','), 'ERP7__Channel__c');
        if (Schema.sObjectType.Employees__c.fields.Organisation__c.isAccessible())
            String organisation = currentEmployee.Organisation__c;
        if (
            Schema.sObjectType.Employees__c.fields.Organisation_Business_Unit__c.isAccessible()
        )
            String businessunit = currentEmployee.Organisation_Business_Unit__c;

        Boolean bol = true;
        query =
            'SELECT ' +
            String.escapeSingleQuotes(allFields) +
            ' From ERP7__Channel__c';
        try {
            if (Schema.sObjectType.Channel__c.isAccessible())
            allSalePoints = Database.query(query);
        } catch (Exception e) {
        }

        if (!allSalePoints.isEmpty()) {
            for (Channel__c sps : allSalePoints) {
            salePointNames.add(sps.Name);
            }
        }
        } catch (Exception e) {
        }
    }
    }