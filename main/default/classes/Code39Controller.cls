Global With Sharing Class Code39Controller implements IBarcode {

private static Map<String,String> BrcdSymbol39EncoderTbl = new Map<String,String>{};
static{
    BrcdSymbol39EncoderTbl.put('*','bWbwBwBwb');
    BrcdSymbol39EncoderTbl.put('-','bWbwbwBwB');
    BrcdSymbol39EncoderTbl.put('$','bWbWbWbwb');
    BrcdSymbol39EncoderTbl.put('%','bwbWbWbWb');
    BrcdSymbol39EncoderTbl.put(' ','bWBwbwBwb');
    BrcdSymbol39EncoderTbl.put('.','BWbwbwBwb');
    BrcdSymbol39EncoderTbl.put('/','bWbWbwbWb');
    BrcdSymbol39EncoderTbl.put('+','bWbwbWbWb');
    BrcdSymbol39EncoderTbl.put('0','bwbWBwBwb');
    BrcdSymbol39EncoderTbl.put('1','BwbWbwbwB');
    BrcdSymbol39EncoderTbl.put('2','bwBWbwbwB');
    BrcdSymbol39EncoderTbl.put('3','BwBWbwbwb');
    BrcdSymbol39EncoderTbl.put('4','bwbWBwbwB');
    BrcdSymbol39EncoderTbl.put('5','BwbWBwbwb');
    BrcdSymbol39EncoderTbl.put('6','bwBWBwbwb');
    BrcdSymbol39EncoderTbl.put('7','bwbWbwBwB');
    BrcdSymbol39EncoderTbl.put('8','BwbWbwBwb');
    BrcdSymbol39EncoderTbl.put('9','bwBWbwBwb');
    BrcdSymbol39EncoderTbl.put('A','BwbwbWbwB');
    BrcdSymbol39EncoderTbl.put('B','bwBwbWbwB');
    BrcdSymbol39EncoderTbl.put('C','BwBwbWbwb');
    BrcdSymbol39EncoderTbl.put('D','bwbwBWbwB');
    BrcdSymbol39EncoderTbl.put('E','BwbwBWbwb');
    BrcdSymbol39EncoderTbl.put('F','bwBwBWbwb');
    BrcdSymbol39EncoderTbl.put('G','bwbwbWBwB');
    BrcdSymbol39EncoderTbl.put('H','BwbwbWBwb');
    BrcdSymbol39EncoderTbl.put('I','bwBwbWBwb');
    BrcdSymbol39EncoderTbl.put('J','bwbwBWBwb');
    BrcdSymbol39EncoderTbl.put('K','BwbwbwbWB');
    BrcdSymbol39EncoderTbl.put('L','bwBwbwbWB');
    BrcdSymbol39EncoderTbl.put('M','BwBwbwbWb');
    BrcdSymbol39EncoderTbl.put('N','bwbwBwbWB');
    BrcdSymbol39EncoderTbl.put('O','BwbwBwbWb');
    BrcdSymbol39EncoderTbl.put('P','bwBwBwbWb');
    BrcdSymbol39EncoderTbl.put('Q','bwbwbwBWB');
    BrcdSymbol39EncoderTbl.put('R','BwbwbwBWb');
    BrcdSymbol39EncoderTbl.put('S','bwBwbwBWb');
    BrcdSymbol39EncoderTbl.put('T','bwbwBwBWb');
    BrcdSymbol39EncoderTbl.put('U','BWbwbwbwB');
    BrcdSymbol39EncoderTbl.put('V','bWBwbwbwB');
    BrcdSymbol39EncoderTbl.put('W','BWBwbwbwb');
    BrcdSymbol39EncoderTbl.put('X','bWbwBwbwB');
    BrcdSymbol39EncoderTbl.put('Y','BWbwBwbwb');
    BrcdSymbol39EncoderTbl.put('Z','bWBwBwbwb');
}


public String Brcd{get; set;}
private Integer m_pxSize=0;
public String BrcdFooterText{get; set;}

public virtual Boolean isValid(String brcd){
try{
    String code39Format = '[0-9A-Z*+-/%$ .]+';
    return BrcdHelper.patterMatcher(code39Format, brcd);
    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
}

public virtual String drawBarcode(String brcd){
try{
    Brcd = brcd;
    return getEncodedBrcd( brcd);
    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
}

public String getEncodedBrcd(String brcdVal){
try{
    
    String encodedBrcd = getBarcode(brcdVal,40,2,4);
    Integer length = encodedBrcd.length();
    m_pxSize += 25;
    String topTbl = '<table cellpadding=0 cellspacing=0   style="height:50px; border-style:none;  border-color:#CCCCCC;  border-width:thin; width:' + String.valueOf(m_pxSize) + 'px; background-color: white;">';
    topTbl += '<tr ><td style="height:10%;" ><div><br/></div></td></tr> <tr ><td style="height:80%; width:90%" >';
    topTbl += encodedBrcd ;
    topTbl += '</td></tr><tr><td style="height:10%;text-align:center;font-family:"Times New Roman",Georgia,Serif;"><span>';
    topTbl +=  getformatBrcdName(brcdVal) + '</span></td></tr></table>';
    m_pxSize = 0;
    return topTbl;
    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
}

private String getformatBrcdName(String brcdVal){
try{
    String retVal='* ';
    for(Integer i=0; i<brcdVal.length(); ++i){
        retVal += brcdVal.substring(i,i+1) + ' ';       
    }
    retVal += ' *';
    return retVal;
    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
}

public String getBarcode(String brcdVal,Integer h,Integer  nw,Integer ww) {
try{
    String retBarcode;
    if (h == null) { 
        h = 40;
    } 
    if (nw == null) { 
        nw = 2;
    }
    if (ww == null) { 
        ww = 4;
    }
    
    retBarcode = '<table cellpadding=0 cellspacing=0 style="margin-left:auto;margin-right:auto;height:'+ String.valueOf(h) + 'px"><tr style="height:' + String.valueOf(h) + 'px">';
    retBarcode += getBC39('*', nw, ww);
    retBarcode += getBCSymbol('w', nw, ww);
    for (Integer i = 0; i < brcdVal.length(); ++i) { 
        retBarcode += getBC39(brcdVal.substring(i, i+1), nw, ww);
        retBarcode += getBCSymbol('w', nw, ww);
    }
    retBarcode += getBC39('*', nw, ww);
    retBarcode += '</tr></table>';
    return retBarcode;
    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
}


private String getBCSymbol(String sym,Integer nw,Integer ww) {
try{
    Integer w = nw;
     
    String clr = 'black';
    if (sym.equals('B')) {
        w = ww;     
    }
    else if (sym.equals('b')) {
    // defaults good
    }
    else if (sym.equals('W')) {
        w = ww;
        clr = 'white';
    }
    else if (sym.equals('w')) {
        clr = 'white';
    }
    m_pxSize += w;
    return '<td style="width:'+ String.valueOf(w) + 'px;background-color:' + clr + '"></td>';
    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
}


private String getBC39(String c,Integer nw,Integer ww) {
try{
    String bcData = BrcdSymbol39EncoderTbl.get(c); 
    if (bcData == null) { 
        return '<td>Illegal Char [' + c + ']</td>';
    }
    String retSymbol = '';
    for (Integer i = 0; i < bcData.length(); ++i) {
        String bar = bcData.substring(i, i+1); 
        retSymbol += getBCSymbol(bar, nw, ww);
    }
    return retSymbol;
    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
}

}