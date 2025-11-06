<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess">
	<aura:attribute name="loId" type="String" access="global"/>
    <c:Pick logisticIds="{!v.loId}"/>
</aura:application>