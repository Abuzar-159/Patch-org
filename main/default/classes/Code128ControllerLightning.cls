Global With Sharing Class Code128ControllerLightning implements IBarcodeLightning{
    
    private static Map<String,Integer> ASCIIEncoderTbl = new Map<String,Integer>{};
    private static List<String> BrcdSymbol128EncoderTbl = new List<String>{};
    private static final Integer START_INDEX = 38; 
    private static final Integer STOP_INDEX = 106;
    
    static{
        // since apex lack of converting char into
        // we need to map each char into its correct ascii val
        ASCIIEncoderTbl.put(' ',32);
        ASCIIEncoderTbl.put('!',33);
        ASCIIEncoderTbl.put('"',34);
        ASCIIEncoderTbl.put('#',35);
        ASCIIEncoderTbl.put('$',36);
        ASCIIEncoderTbl.put('%',37);
        ASCIIEncoderTbl.put('&',38);
        ASCIIEncoderTbl.put('\'',39);
        ASCIIEncoderTbl.put('(',40);
        ASCIIEncoderTbl.put(')',41);
        ASCIIEncoderTbl.put('*',42);
        ASCIIEncoderTbl.put('+',43);
        ASCIIEncoderTbl.put(',',44);
        ASCIIEncoderTbl.put('-',45);
        ASCIIEncoderTbl.put('.',46);
        ASCIIEncoderTbl.put('/',47);
        ASCIIEncoderTbl.put('0',48);
        ASCIIEncoderTbl.put('1',49);
        ASCIIEncoderTbl.put('2',50);
        ASCIIEncoderTbl.put('3',51);
        ASCIIEncoderTbl.put('4',52);
        ASCIIEncoderTbl.put('5',53);
        ASCIIEncoderTbl.put('6',54);
        ASCIIEncoderTbl.put('7',55);
        ASCIIEncoderTbl.put('8',56);
        ASCIIEncoderTbl.put('9',57);
        ASCIIEncoderTbl.put(':',58);
        ASCIIEncoderTbl.put(';',59);
        ASCIIEncoderTbl.put('<',60);
        ASCIIEncoderTbl.put('=',61);
        ASCIIEncoderTbl.put('>',62);
        ASCIIEncoderTbl.put('?',63);
        ASCIIEncoderTbl.put('@',64);
        ASCIIEncoderTbl.put('A',65);
        ASCIIEncoderTbl.put('B',66);
        ASCIIEncoderTbl.put('C',67);
        ASCIIEncoderTbl.put('D',68);
        ASCIIEncoderTbl.put('E',69);
        ASCIIEncoderTbl.put('F',70);
        ASCIIEncoderTbl.put('G',71);
        ASCIIEncoderTbl.put('H',72);
        ASCIIEncoderTbl.put('I',73);
        ASCIIEncoderTbl.put('J',74);
        ASCIIEncoderTbl.put('K',75);
        ASCIIEncoderTbl.put('L',76);
        ASCIIEncoderTbl.put('M',77);
        ASCIIEncoderTbl.put('N',78);
        ASCIIEncoderTbl.put('O',79);
        ASCIIEncoderTbl.put('P',80);
        ASCIIEncoderTbl.put('Q',81);
        ASCIIEncoderTbl.put('R',82);
        ASCIIEncoderTbl.put('S',83);
        ASCIIEncoderTbl.put('T',84);
        ASCIIEncoderTbl.put('U',85);
        ASCIIEncoderTbl.put('V',86);
        ASCIIEncoderTbl.put('W',87);
        ASCIIEncoderTbl.put('X',88);
        ASCIIEncoderTbl.put('Y',89);
        ASCIIEncoderTbl.put('Z',90);
        ASCIIEncoderTbl.put('[',91);
        ASCIIEncoderTbl.put('\\',92);
        ASCIIEncoderTbl.put(']',93);
        ASCIIEncoderTbl.put('^',94);
        ASCIIEncoderTbl.put('_',95);
        ASCIIEncoderTbl.put('`',96);
        ASCIIEncoderTbl.put('a',97);
        ASCIIEncoderTbl.put('b',98);
        ASCIIEncoderTbl.put('c',99);
        ASCIIEncoderTbl.put('d',100);
        ASCIIEncoderTbl.put('e',101);
        ASCIIEncoderTbl.put('f',102);
        ASCIIEncoderTbl.put('g',103);
        ASCIIEncoderTbl.put('h',104);
        ASCIIEncoderTbl.put('i',105);
        ASCIIEncoderTbl.put('j',106);
        ASCIIEncoderTbl.put('k',107);
        ASCIIEncoderTbl.put('l',108);
        ASCIIEncoderTbl.put('m',109);
        ASCIIEncoderTbl.put('n',110);
        ASCIIEncoderTbl.put('o',111);
        ASCIIEncoderTbl.put('p',112);
        ASCIIEncoderTbl.put('q',113);
        ASCIIEncoderTbl.put('r',114);
        ASCIIEncoderTbl.put('s',115);
        ASCIIEncoderTbl.put('t',116);
        ASCIIEncoderTbl.put('u',117);
        ASCIIEncoderTbl.put('v',118);
        ASCIIEncoderTbl.put('w',119);
        ASCIIEncoderTbl.put('x',120);
        ASCIIEncoderTbl.put('y',121);
        ASCIIEncoderTbl.put('z',122);
        ASCIIEncoderTbl.put('{',123);
        ASCIIEncoderTbl.put('|',124);
        ASCIIEncoderTbl.put('}',125);
        ASCIIEncoderTbl.put('~',126);
        ASCIIEncoderTbl.put('DEL',127);
        ASCIIEncoderTbl.put('Ç',128);
        ASCIIEncoderTbl.put('ü',129);
        ASCIIEncoderTbl.put('é',130);
        ASCIIEncoderTbl.put('â',131);
        ASCIIEncoderTbl.put('ä',132);
        ASCIIEncoderTbl.put('à',133);
        ASCIIEncoderTbl.put('å',134);
        ASCIIEncoderTbl.put('‡',135);
        ASCIIEncoderTbl.put('ˆ',136);
        ASCIIEncoderTbl.put('‰',137);
        ASCIIEncoderTbl.put('Š',138);
        
        BrcdSymbol128EncoderTbl.add('212222');
        BrcdSymbol128EncoderTbl.add('222122');
        BrcdSymbol128EncoderTbl.add('222221');
        BrcdSymbol128EncoderTbl.add('121223');
        BrcdSymbol128EncoderTbl.add('121322');
        BrcdSymbol128EncoderTbl.add('131222');
        BrcdSymbol128EncoderTbl.add('122213');
        BrcdSymbol128EncoderTbl.add('122312');
        BrcdSymbol128EncoderTbl.add('132212');
        BrcdSymbol128EncoderTbl.add('221213');
        BrcdSymbol128EncoderTbl.add('221312');
        BrcdSymbol128EncoderTbl.add('231212');
        BrcdSymbol128EncoderTbl.add('112232');
        BrcdSymbol128EncoderTbl.add('122132');
        BrcdSymbol128EncoderTbl.add('122231');
        BrcdSymbol128EncoderTbl.add('113222');
        BrcdSymbol128EncoderTbl.add('123122');
        BrcdSymbol128EncoderTbl.add('123221');
        BrcdSymbol128EncoderTbl.add('223211');
        BrcdSymbol128EncoderTbl.add('221132');
        BrcdSymbol128EncoderTbl.add('221231');
        BrcdSymbol128EncoderTbl.add('213212');
        BrcdSymbol128EncoderTbl.add('223112');
        BrcdSymbol128EncoderTbl.add('312131');
        BrcdSymbol128EncoderTbl.add('311222');
        BrcdSymbol128EncoderTbl.add('321122');
        BrcdSymbol128EncoderTbl.add('321221');
        BrcdSymbol128EncoderTbl.add('312212');
        BrcdSymbol128EncoderTbl.add('322112');
        BrcdSymbol128EncoderTbl.add('322211');
        BrcdSymbol128EncoderTbl.add('212123');
        BrcdSymbol128EncoderTbl.add('212321');
        BrcdSymbol128EncoderTbl.add('232121');
        BrcdSymbol128EncoderTbl.add('111323');
        BrcdSymbol128EncoderTbl.add('131123');
        BrcdSymbol128EncoderTbl.add('131321');
        BrcdSymbol128EncoderTbl.add('112313');
        BrcdSymbol128EncoderTbl.add('132113');
        BrcdSymbol128EncoderTbl.add('132311');
        BrcdSymbol128EncoderTbl.add('211313');
        BrcdSymbol128EncoderTbl.add('231113');
        BrcdSymbol128EncoderTbl.add('231311');
        BrcdSymbol128EncoderTbl.add('112133');
        BrcdSymbol128EncoderTbl.add('112331');
        BrcdSymbol128EncoderTbl.add('132131');
        BrcdSymbol128EncoderTbl.add('113123');
        BrcdSymbol128EncoderTbl.add('113321');
        BrcdSymbol128EncoderTbl.add('133121');
        BrcdSymbol128EncoderTbl.add('313121');
        BrcdSymbol128EncoderTbl.add('211331');
        BrcdSymbol128EncoderTbl.add('231131');
        BrcdSymbol128EncoderTbl.add('213113');
        BrcdSymbol128EncoderTbl.add('213311');
        BrcdSymbol128EncoderTbl.add('213131');
        BrcdSymbol128EncoderTbl.add('311123');
        BrcdSymbol128EncoderTbl.add('311321');
        BrcdSymbol128EncoderTbl.add('331121');
        BrcdSymbol128EncoderTbl.add('312113');
        BrcdSymbol128EncoderTbl.add('312311');
        BrcdSymbol128EncoderTbl.add('332111');
        BrcdSymbol128EncoderTbl.add('314111');
        BrcdSymbol128EncoderTbl.add('221411');
        BrcdSymbol128EncoderTbl.add('431111');
        BrcdSymbol128EncoderTbl.add('111224');
        BrcdSymbol128EncoderTbl.add('111422');
        BrcdSymbol128EncoderTbl.add('121124');
        BrcdSymbol128EncoderTbl.add('121421');
        BrcdSymbol128EncoderTbl.add('141122');
        BrcdSymbol128EncoderTbl.add('141221');
        BrcdSymbol128EncoderTbl.add('112214');
        BrcdSymbol128EncoderTbl.add('112412');
        BrcdSymbol128EncoderTbl.add('122114');
        BrcdSymbol128EncoderTbl.add('122411');
        BrcdSymbol128EncoderTbl.add('142112');
        BrcdSymbol128EncoderTbl.add('142211');
        BrcdSymbol128EncoderTbl.add('241211');
        BrcdSymbol128EncoderTbl.add('221114');
        BrcdSymbol128EncoderTbl.add('413111');
        BrcdSymbol128EncoderTbl.add('241112');
        BrcdSymbol128EncoderTbl.add('134111');
        BrcdSymbol128EncoderTbl.add('111242');
        BrcdSymbol128EncoderTbl.add('121142');
        BrcdSymbol128EncoderTbl.add('121241');
        BrcdSymbol128EncoderTbl.add('114212');
        BrcdSymbol128EncoderTbl.add('124112');
        BrcdSymbol128EncoderTbl.add('124211');
        BrcdSymbol128EncoderTbl.add('411212');
        BrcdSymbol128EncoderTbl.add('421112');
        BrcdSymbol128EncoderTbl.add('421211');
        BrcdSymbol128EncoderTbl.add('212141');
        BrcdSymbol128EncoderTbl.add('214121');
        BrcdSymbol128EncoderTbl.add('412121');
        BrcdSymbol128EncoderTbl.add('111143');
        BrcdSymbol128EncoderTbl.add('111341');
        BrcdSymbol128EncoderTbl.add('131141');
        BrcdSymbol128EncoderTbl.add('114113');
        BrcdSymbol128EncoderTbl.add('114311');
        BrcdSymbol128EncoderTbl.add('411113');
        BrcdSymbol128EncoderTbl.add('411311');
        BrcdSymbol128EncoderTbl.add('113141');
        BrcdSymbol128EncoderTbl.add('114131');
        BrcdSymbol128EncoderTbl.add('311141');
        BrcdSymbol128EncoderTbl.add('411131');
        BrcdSymbol128EncoderTbl.add('211412');
        BrcdSymbol128EncoderTbl.add('211214');
        BrcdSymbol128EncoderTbl.add('211232');
        BrcdSymbol128EncoderTbl.add('23311120');
        
    }
    
    private Integer m_pxSize=0;
    private String m_encodedData;
    private Integer m_checkSum;
    
    public virtual Boolean isValid(String brcd){
        String code128Format = '[0-9A-Za-z!#$%&()*+-./_~:;<=>?@^\'\\\\ {}"`\\[\\]]+'; 
        return BrcdHelperLightning.patterMatcher(code128Format, brcd);
    }
    
    public virtual String drawBarcode(String Brcd, String barcdHeight, String barsWidth, Boolean brcdValHide){
        return getEncodedBrcd(Brcd, barcdHeight,barsWidth,brcdValHide);
    }
    
    public String getEncodedBrcd(String brcdVal, String barcdHeight, String barsWidth, Boolean brcdValHide){
        
        Integer barsW = Integer.valueOf(BarsWidth)>1?Integer.valueOf(BarsWidth):2;
        Integer divideByBars = barsW/2; 
        
        String brcdWidth = Integer.valueOf(BarsWidth)<=2? string.valueOf((brcdVal.length() - Integer.valueOf('110'))) :string.valueOf((brcdVal.length()*5)*Integer.valueOf(barsW));
        String encodedBrcd = getBrcdFormat(brcdVal,Integer.ValueOf(barcdHeight),divideByBars,barsW,  brcdWidth);
        String hideText = (brcdValHide)?'none':'';
        String BrcdFooterText = '';
        Integer length = encodedBrcd.length();
        String topTbl = '<table  cellpadding=0 cellspacing=0 style="height:50px; border-style:none;  border-color:#CCCCCC;  border-width:thin; width:' + String.valueOf(m_pxSize) + 'px; background-color: white;">';
        //topTbl += '<tr ><td style="height:10%;" ><div><br/></div></td></tr> <tr ><td style="height:80%; width:90%" >';
        topTbl += '<tr ><td style="height:10%;" ></td></tr> <tr ><td style="height:80%; width:90%" >';    
        topTbl += encodedBrcd ;
        topTbl += '</td></tr><tr style="display:'+hideText+'"><td style="height:10%;text-align:center;"><span>';
        topTbl +=  getformatBrcdName(brcdVal) + '</span></td></tr></table>';
        m_pxSize = 0;
        return topTbl;
    }
    
    private String getBrcdFormat(String brcdVal,Integer h,Integer  nw,Integer ww, String width){
        String encodedBrcd = parseBarcode(brcdVal);
        
        String retBarcode = '<table width="'+ width +'" cellpadding=0 cellspacing=0 style="margin-left:auto;margin-right:auto;height:'+ String.valueOf(h) + 'px"><tr style="height:' + String.valueOf(h) + 'px">';
        for (Integer i = 0; i < encodedBrcd.length(); ++i) { 
            retBarcode += getBCSymbol(encodedBrcd.substring(i, i+1),'black',nw);
            ++i;
            retBarcode += getBCSymbol(encodedBrcd.substring(i, i+1),'white',nw);
        }
        retBarcode += '</tr></table>';
        return retBarcode;
    }
    
    private String getBCSymbol(String sym,String clr, Integer w) { 
        m_pxSize += Integer.valueOf(sym);
        
        return '<td style="width:'+Integer.valueOf(sym)*w  + 'px;background-color:' + clr + '"></td>';
    }
    
    private String getformatBrcdName(String brcdVal){
        //String retVal='';
        String retVal='';    
        for(Integer i=0; i<brcdVal.length(); ++i){
            retVal += brcdVal.substring(i,i+1) + ' ';       
        }
        //retVal += ' *';
        return retVal;
    }
    
    private String parseBarcode(String barcode){
        Integer codeLength = 0;
        Long chkSum = 0;
        String codeType = detectCode128Type(barcode);
        
        Integer asciiCode  = getASCIICode(codeType.substring(0,1));
        if(asciiCode >= 38 && asciiCode < 127){
            m_encodedData = getSymbol(START_INDEX + asciiCode );
            chkSum = asciiCode + START_INDEX;
            ++codeLength;
        }
        Integer converted;
        for(Integer i=0; i< barcode.length(); ++i) {
            String code = barcode.substring(i, i+1);
            
            converted = fromType(codeType,code);
            if ( converted<0 || converted>106){ 
                //error
                m_encodedData = ''; return '';
            }
            m_encodedData += getSymbol(converted);
            // bars.add( converted );
            
            chkSum += converted*codeLength;
            ++codeLength;
            
        }
        Long div = 103;
        converted = (math.mod(chkSum , div)).intValue();
        m_encodedData += getSymbol(converted);
        
        m_encodedData += getSymbol(STOP_INDEX);
        return m_encodedData;
    }
    
    private Integer fromType(String codeType,String code){
        /* valueOf CodeType and code is  ' + codeType + ' ' + code */
        Integer charCode = getASCIICode(code);
        
        if(codeType.equals('A')) {
            if (charCode>=0 && charCode<32) return charCode+64;
            if (charCode>=32 && charCode<96) return charCode-32;
            return charCode;
        }
        
        if(codeType.equals('B'))  {    
            if (charCode>=32 && charCode<128) return charCode-32;
            return charCode;
        }
        return charCode;   
    }
    
    
    private String getSymbol(Integer index){
        return BrcdSymbol128EncoderTbl[index];
    }
    
    private Integer getASCIICode(String chara){
        return  ASCIIEncoderTbl.get(chara);
        
    }
    
    // need to check on this.
    private String detectCode128Type(String barcode){
        String regExpCodeB='^[0-9A-Za-z!#$%&()*+-./_~:;<=>?@^\'\\\\ {}"`\\[\\]]*$';
        if(patterMatcher(regExpCodeB,barcode)) return 'B';
        return 'A';
    }
    
    private Boolean patterMatcher(String regExp,String value){
        Pattern patObj = Pattern.compile(regExp);
        Matcher matObj = patObj.matcher(value);
        return matObj.matches();    
    }
}