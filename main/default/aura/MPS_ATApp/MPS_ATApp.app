<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess">
	<aura:attribute name="mpsId" type="String" access="global"/>
    <c:MPS_AT MPSId="{!v.mpsId}"/>
</aura:application>