<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess">
	<aura:attribute name="son" type="String" access="global"/>
    <c:OrderConsole SON="{!v.son}"/>
</aura:application>