updateInventory:
;	{
        LDA keyFlags
        AND8 #_keyInventory
        BEQ .checkWasPressed
        STA wasPressedFlagInventory
        RTS

.checkWasPressed:
        LDA wasPressedFlagInventory
        BNE .attemptChange
        RTS

* DJV attempt to change to next item in the inventory
.attemptChange:
        LDA playerUsingItem
        BEQ .inventoryOut ; quit if using nothing
        LDX #$0

* DJV search itemTable for item player is currently using        
.searchForBit:
        CMP8 itemTable,X
        BEQ .itemLookup
        INX
        INX
;        JMP .searchForBit
	CPX	#8		; DJV prevent infinite loop if playerUsingItem is invalid
	blt.s	.searchForBit
	bra.s	.inventoryOut

.rescan:
        LDX #$fe

* DJV search for next available item in player's inventory
.itemLookup:
	LDA	playerInventory	; DJV prevent infinite loop if playerInventory is invalid
	beq.s	.inventoryOut
        INX

.innerItemLookup:
        INX
        LDA itemTable,X
        BEQ .rescan; if this is zero, we've wrapped
        TAY ; Store the item in Y ready
        INX
        LDA itemTable,X
        AND8 playerInventory
        BNE .foundItem
        JMP .innerItemLookup

        ; Here we have found an item and it's in Y
.foundItem:
        STY playerUsingItem
        JSR drawItem 
       
.inventoryOut:
        LDA #0
        STA wasPressedFlagInventory
	    RTS
        
        
;	}
	
;PRINT "* Inventory size: ",P%-updateInventory
	
