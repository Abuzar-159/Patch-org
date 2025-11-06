global With Sharing Class MOTraveller{ 
    global ManufacturingOrder.comWrap comW { get; set; }
    global String Id { 
        get{ return Id; } 
        set{ 
            try{ Id = value; comW = ManufacturingOrder.getAll(Id,false,true); } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        } 
    }
}