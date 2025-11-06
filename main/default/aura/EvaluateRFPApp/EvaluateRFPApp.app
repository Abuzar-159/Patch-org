<aura:application  extends="ltng:outApp"> 
    <!--<aura:dependency resource="ERP7:RFPConsole"/>-->
    <aura:attribute name = "rsId" type="String" default="World"/>
    Hello {!v.rsId}!
    <!--<ERP7:OrderConsole />-->
</aura:application>