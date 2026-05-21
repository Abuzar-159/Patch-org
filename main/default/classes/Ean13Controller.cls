public With Sharing Class Ean13Controller implements IBarcode {


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
  
}
private static Map<Integer, Patterns> codes = new Map<Integer, Patterns>{};
private static Map<Integer, Parity> parity = new Map<Integer, Parity>{};
public String BrcdFooterText{get; set;}

private static final Integer START_INDEX = 38; 
private static final Integer STOP_INDEX = 106;
static{
   AddCode(0, '0001101', '0100111', '1110010');
   AddCode(1, '0011001', '0110011', '1100110');
   AddCode(2, '0010011', '0011011', '1101100');
   AddCode(3, '0111101', '0100001', '1000010');
   AddCode(4, '0100011', '0011101', '1011100');
   AddCode(5, '0110001', '0111001', '1001110');
   AddCode(6, '0101111', '0000101', '1010000');
   AddCode(7, '0111011', '0010001', '1000100');
   AddCode(8, '0110111', '0001001', '1001000');
   AddCode(9, '0001011', '0010111', '1110100');

   AddParity(0, 'ooooo');
   AddParity(1, 'oeoee');
   AddParity(2, 'oeeoe');
   AddParity(3, 'oeeeo');
   AddParity(4, 'eooee');
   AddParity(5, 'eeooe');
   AddParity(6, 'eeeoo');
   AddParity(7, 'eoeoe');
   AddParity(8, 'eoeeo');
   AddParity(9, 'eeoeo');

}

private static void AddCode(Integer digit, String lhOdd, String lhEven, String rh){
   Patterns p = new Patterns();
   p.LhOdd = lhOdd; p.LhEven = lhEven; p.Rh = rh;
   codes.put(digit, p);
}

private static void AddParity(Integer digit, String par){
   parity.put(digit, new Parity(par));
}


public virtual Boolean isValid(String brcd){
    
   if (brcd == null || brcd.length() != 13){
      return false;
   }
   
   if(!IsNumber(brcd)){
        return false;
   }
  
   String check = (String.valueOf(CalculateChecksum(brcd.substring(0, 12)) ));
    return (brcd.substring(12,13).equals(check));
}

public virtual String drawBarcode(String brcd){
    
    return getBrcdFormat(brcd);
}

private String getBrcdFormat(String brcd){
    
   String retEncodedVal;
   retEncodedVal = '<table cellpadding=0 cellspacing=0 border="0"  style="height:150px;   border-color:#CCCCCC;   width:100px; background-color: white;">';
   retEncodedVal += '<tr><td style="height:10%;" ><div><br/></div></td></tr> <tr><td style="height:80%;" >';
   retEncodedVal += '<table style="background-color: white" width="190" border="0" align="center" cellpadding="0" cellspacing="0">';
   retEncodedVal += '<tr>';
   retEncodedVal += '<td align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">';
   retEncodedVal += '<tr><td  align="center" valign="bottom">'+ Brcd.substring(0,1) + '</td><td width="2"></td><td>' ;
   retEncodedVal += drawLeftGuard();
   retEncodedVal += '</td></tr></table></td><td align="left" valign="top">';
   retEncodedVal += drawLeftGroup(brcd);
   retEncodedVal += '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(1,2) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(2,3) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(3,4) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(4,5) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(5,6) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(6,7) + '</td></tr></table>';
   
   retEncodedVal += '</td><td align="left" valign="top">';
   retEncodedVal += drawCenterGuard();
   retEncodedVal += '</td><td align="left" valign="top">';
   retEncodedVal += drawRightGroup(brcd);
   retEncodedVal += '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(7,8) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(8,9) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(9,10) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(10,11) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(11,12) + '</td>';
   retEncodedVal += '<td height="19" align="center" valign="middle">' + Brcd.substring(12,13) + '</td></tr></table>';
   
   retEncodedVal += '</td><td align="left" valign="top">';
   retEncodedVal += drawRightGuard();
   retEncodedVal += '</td></tr></table>';
   retEncodedVal += '</td></tr></table>';
   return retEncodedVal;
}
private String drawLeftGroup(String brcd){
    String retEncodedVal;   
    //Find out the left encoding schem
    Integer digit = Integer.valueOf(brcd.substring(0,1));
    Parity parObj = parity.get(digit);
    // Encode left group
    // first value will be always odd parity
    digit = Integer.valueOf(brcd.substring(1,2));
    retEncodedVal =  codes.get(digit).LhOdd;
   for (Integer i = 2; i <= 6; i++) {
      digit = Integer.valueOf(brcd.substring(i,i+1));
      retEncodedVal +=  parObj.IsOdd(i - 2) ?   codes.get(digit).LhOdd: codes.get(digit).LhEven;     
   }
   return drawEncodedValue(retEncodedVal,'96');
}

private String drawRightGroup(String brcd){
    String retEncodedVal ='';
    Integer digit;  
   for (Integer i = 7; i <= 12; i++)   {
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
   
   Integer sum = 0,digit = 0;
   for (Integer i = 0; i < 12; i++)
   {
      digit = Integer.valueOf(code.substring(i,i+1));
      sum += ( math.mod(i, 2) == 0 ? digit : digit * 3);
   }
   Integer check = 10 - ( math.mod(sum , 10)); // redundant code chk it
   return math.mod(check , 10);
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