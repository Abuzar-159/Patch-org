public with sharing class Ean8ControllerLightning implements IBarcodeLightning {
    
    
    class Patterns{
        public String LhOdd{get;set;}
        public string LhEven{get;set;}
        public string Rh{get;set;}  
    }
    
    class Parity {
        private string par;
        Parity(string val){
            par = val;
        }
        
        public Boolean IsOdd(Integer index) {
            return par.substring(index,index+1).equals('o');
        }
        
        public Boolean IsEven(Integer index) {
            return par.substring(index,index+1).equals('e');
        }
    }
    private static Map<Integer, Patterns> codes = new Map<Integer, Patterns>{};
    private static Map<Integer, Parity> parity = new Map<Integer, Parity>{};
    @AuraEnabled public String BrcdFooterText{get; set;}
    
    private static final Integer START_INDEX = 38; 
    private static final Integer STOP_INDEX = 106;
    static{
        AddCode(0, '0001101', '1110010');   
        AddCode(1, '0011001', '1100110');
        AddCode(2, '0010011', '1101100');
        AddCode(3, '0111101', '1000010');
        AddCode(4, '0100011', '1011100');
        AddCode(5, '0110001', '1001110');
        AddCode(6, '0101111', '1010000');
        AddCode(7, '0111011', '1000100');
        AddCode(8, '0110111', '1001000');
        AddCode(9, '0001011', '1110100');
        
    }
    
    private static void AddCode(Integer digit, String lhOdd, String rh){
        Patterns p = new Patterns();
        p.LhOdd = lhOdd; p.Rh = rh;
        codes.put(digit, p);
    }
    
    private static void AddParity(Integer digit, String par){
        parity.put(digit, new Parity(par));
    }
    
    public virtual Boolean isValid(String brcd){
        if (brcd == null || brcd.length() != 8){
            return false;
        }
        if(!IsNumber(brcd)){
            return false;
        }
        String check = (String.valueOf(CalculateChecksum(brcd.substring(0, 7)) ));
        return true;
    }
    
    public virtual String drawBarcode(String brcd, String height, String barwidth, Boolean brcdValHide){
        return getBrcdFormat(brcd, brcdValHide);
    }
    
    private String getBrcdFormat(String brcd, Boolean brcdValHide){
        
        String retEncodedVal;
        String hideText = (brcdValHide)?'none':'';
        retEncodedVal = '<table cellpadding=0 cellspacing=0 border="0"  style="height:150px;   border-color:#CCCCCC;   width:136px; background-color: white;">';
        retEncodedVal += '<tr><td style="height:10%;" ><div><br/></div></td></tr> <tr><td style="height:80%;" >';
        retEncodedVal += '<table style="background-color: white" width="190" border="0" align="center" cellpadding="0" cellspacing="0">';
        retEncodedVal += '<tr>';
        retEncodedVal += '<td align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">';
        retEncodedVal += '<tr><td  align="center" valign="bottom"></td><td width="2"></td><td>' ;
        retEncodedVal += drawLeftGuard();
        retEncodedVal += '</td></tr></table></td><td align="left" valign="top">';
        retEncodedVal += drawLeftGroup(brcd);
        retEncodedVal += '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr style="display:'+hideText+'">';
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(0,1) + '</td>';
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(1,2) + '</td>';
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(2,3) + '</td>';
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(3,4) + '</td></tr></table>';
        
        retEncodedVal += '</td><td align="left" valign="top">';
        retEncodedVal += drawCenterGuard();
        retEncodedVal += '</td><td align="left" valign="top">';
        retEncodedVal += drawRightGroup(brcd);
        retEncodedVal += '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr style="display:'+hideText+'">';
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(4,5) + '</td>';
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(5,6) + '</td>';
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(6,7) + '</td>';   
        retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(7,8) + '</td></tr></table>';
        
        retEncodedVal += '</td><td align="left" valign="top">';
        retEncodedVal += drawRightGuard();
        retEncodedVal += '</td></tr></table>';
        retEncodedVal += '</td></tr></table>';
        return retEncodedVal;
    }
    
    private String drawLeftGroup(String brcd){
        
        String retEncodedVal='';
        Integer digit;
        
        for (Integer i = 0; i <4; i++) {
            digit = Integer.valueOf(brcd.substring(i,i+1));
            retEncodedVal += codes.get(digit).LhOdd;
        }
        return drawEncodedValue(retEncodedVal,'96');
    }
    
    private String drawRightGroup(String brcd){
        String retEncodedVal ='';
        Integer digit;  
        for (Integer i = 4; i <8; i++)   {
            digit = Integer.valueOf(brcd.substring(i,i+1));
            retEncodedVal += codes.get(digit).Rh;
        }
        return drawEncodedValue(retEncodedVal,'96');
    }
    
    private String drawEncodedValue(String encodedValue,String ht){
        String tbl='<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr>';
        for(Integer i=0; i< encodedValue.length(); ++i){
            if(encodedValue.substring(i,i+1).equals('0')){
                
                tbl += '<td width="2" height="'+ ht + '" align="left" valign="top" bgcolor="#ffffff"></td>';
            }else{
                tbl += '<td width="2" height="'+ ht + '" align="left" valign="top" bgcolor="#000000"></td>';
            }
        }
        
        tbl += '</tr></table>';
        return tbl;
    }
    
    private String drawLeftGuard(){
        return drawEncodedValue('101','110');
    }
    
    private String drawCenterGuard(){
        return drawEncodedValue('01010','110');
    }
    
    private String drawRightGuard(){
        return drawEncodedValue('101','110');
    }
    
    private Integer CalculateChecksum(String code) 
    {
        /*if (code == null || code.Length != 12)
throw new ArgumentException('Code length should be 12, i.e. excluding the checksum digit');
*/
        Integer sum=0,digit = 0;
        for (Integer i = code.length()-1; i > -1; i--){
            digit = Integer.valueOf(code.substring(i,i+1));
            sum += (math.mod(i, 2) == 0  ? 3 : 1)*digit;
        }
        return math.mod(10 - ( math.mod(sum , 10)) , 10); // redundant code chk it
    }
    
    private Boolean IsNumber(String brcd){
        String regExpCode='^[0-9]+$';
        return patterMatcher(regExpCode,brcd);
    }
    
    private Boolean patterMatcher(String regExp,String value){
        Pattern patObj = Pattern.compile(regExp);
        Matcher matObj = patObj.matcher(value);
        return matObj.matches();    
    }
}