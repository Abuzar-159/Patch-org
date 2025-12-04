@IsTest public class uomTest {
    @IsTest public static void configSetupTest() {
        String fullName = 'UOM_Conversion.StripeConfig';
        String label = 'TEST_AQXOLT';
        Decimal fromval=1.00;
        String fromuom ='liter';
        Decimal toval =10.00;
        String touom='mililiter';
        Test.startTest();
        uomApex.createUOMConv(label,fromval,toval,fromuom,touom);
        uomApex.getAllUOMConversions();
        uomApex.updateUoM(fullName,label,fromval,toval,fromuom,touom);
        uomApex.searchMethod(label);
        uomApex.searchMethod('');
        Test.stopTest();
    }

}